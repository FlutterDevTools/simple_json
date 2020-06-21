import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as p;

import 'utils.dart';

class JsonMapperBuilder implements Builder {
  JsonMapperBuilder();

  static final _allFilesInLib = new Glob('lib/**');

  final processedTypes = Set<DartType>();

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['mapper.g.dart']
    };
  }

  static AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'mapper.g.dart'),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final lines = <String>[];
    final classesInLibrary = <ClassElement>[];
    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      final library = await buildStep.resolver.libraryFor(input);
      classesInLibrary.addAll(LibraryReader(library)
          .annotatedWith(TypeChecker.fromRuntime(JsonObject))
          .where((match) => match.element is ClassElement)
          .map((match) => match.element as ClassElement)
          .toList());
    }

    final mappers = classesInLibrary.map((c) => _generateMapper(c)).toList();
    final unmappedTypes = processedTypes
        .where((t) => t.element is ClassElement)
        .toSet()
        .difference(classesInLibrary
            .map((optedClasses) => optedClasses.thisType)
            .toSet());
    print(
        'WARNING: Generated mappings for the following unannotated types: ${unmappedTypes.map((t) => t.toString()).join(', ')}');
        
    final unmappedElements =
        unmappedTypes.map((t) => t.element as ClassElement).toList();
    mappers.addAll(unmappedElements.map((c) => _generateMapper(c)));

    final classes = [...classesInLibrary, ...unmappedElements];
    final imports = _generateHeader(classes);
    final registrations = _generateInit(classes);

    lines.add(imports);
    lines.addAll(mappers);
    lines.add(registrations);

    await buildStep.writeAsString(_allFileOutput(buildStep), lines.join('\n'));
  }

  String _generateMapper(ClassElement element) {
    final elementName = element.displayName;
    final parameters = element.unnamedConstructor.parameters;
    return '''

final _${elementName.toLowerCase()}Mapper = JsonObjectMapper(
  (Map<String, dynamic> json) => ${elementName}(
    ${parameters.map(_generateFromMapItem).where((line) => line != null).join('\n    ')}
  ),
  (${elementName} instance) => <String, dynamic>{
    ${parameters.map(_generateToMapItem).where((line) => line != null).join('\n    ')}
  },
);
''';
  }

  String _generateFromMapItem(ParameterElement param) {
    final prop = getProp(param);
    if (prop.ignore) return null;
    final name = param.displayName;
    final jsonName = prop.name ?? name;
    final type = param.type.toString();
    final valFn = ([String asType]) {
      var accessorStr = "json['$jsonName']";
      if (prop.defaultValue != null) {
        accessorStr = '($accessorStr ?? ${prop.defaultValue.toString()})';
      }
      return '''$accessorStr as ${asType ?? type}''';
    };
    var val;
    switch (type) {
      case 'DateTime':
        val = 'DateTime.parse(${valFn('String')})';
        break;
      default:
        break;
    }
    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      if (typeArgs.isNotEmpty && !isPrimitiveType(typeArgs.first)) {
        processedTypes.add(typeArgs.first);
        val =
            '''(${valFn('List')}).cast<Map<String, dynamic>>().map((item) => ${_generateDeserialize('item', typeArgs.first)}).toList()''';
      } else {
        val = '''(${valFn('List')}).cast()''';
      }
    } else if (isParamFieldFormal(param) && isParamEnum(param)) {
      final enumProp = getEnumProp(param);
      final enumValueMap = cleanMap(getEnumValueMap(param, enumProp));
      val = _generateEnumFromMap(param, enumProp, enumValueMap);
    } else if (!isPrimitiveType(param.type) && val == null) {
      processedTypes.add(param.type);
      val = _generateDeserialize(valFn('Map<String, dynamic>'), param.type);
    }
    return '''$name: ${val ?? valFn()},''';
  }

  String _generateEnumFromMap(ParameterElement param, JsonEnumProperty enumProp,
      Map<dynamic, dynamic> enumValueMap) {
    final value = enumProp.serializationType == SerializationType.Index
        ? 'item.index'
        : "item.toString().split('.')[1]";
    return '''${param.type}.values.firstWhere(
        (item) => ${_generateMapLookup(enumValueMap, value)} == json['${param.displayName}'],
        orElse: () => null)''';
  }

  String _generateToMapItem(ParameterElement param) {
    final prop = getProp(param);
    if (prop.ignore) return null;
    final name = param.displayName;
    final jsonName = prop.name ?? name;
    final valFn = () => 'instance.${name}';
    var val;
    switch (param.type.toString()) {
      case 'DateTime':
        val = '${valFn()}.toIso8601String()';
        break;
      default:
        break;
    }
    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      if (typeArgs.isNotEmpty && !isPrimitiveType(typeArgs.first)) {
        processedTypes.add(typeArgs.first);
        val =
            '''${valFn()}.map((item) => ${_generateSerialize('item', typeArgs.first)}).toList()''';
      }
    } else if (isParamFieldFormal(param) && isParamEnum(param)) {
      final enumProp = getEnumProp(param);
      final enumValueMap = cleanMap(getEnumValueMap(param, enumProp));
      val = _generateMapLookup(
          enumValueMap, '${valFn()}${_generateEnumToMap(param, enumProp)}');
    } else if (!isPrimitiveType(param.type) && val == null) {
      processedTypes.add(param.type);
      val = _generateSerialize(valFn(), param.type);
    }
    return ''''$jsonName': ${val ?? valFn()}${prop.defaultValue != null ? ' ?? ${prop.defaultValue.toString()}' : ''},''';
  }

  String _generateEnumToMap(ParameterElement param, JsonEnumProperty enumProp) {
    return '''${enumProp.serializationType == SerializationType.Index ? '.index' : ".toString().split('.')[1]"}''';
  }

  String _generateMapLookup(Map<dynamic, dynamic> map, String val) {
    return map.isNotEmpty ? '''(${map.toString()}[${val}] ?? ${val})''' : val;
  }

  JsonProperty getProp(ParameterElement param) {
    final propChecker = TypeChecker.fromRuntime(JsonProperty);
    final jsonPropType = param.isInitializingFormal
        ? propChecker
            .firstAnnotationOf((param as FieldFormalParameterElement).field)
        : null;
    final fieldMap = jsonPropType?.getField('(super)') ?? jsonPropType;
    final jsonProp = JsonProperty(
      ignore: fieldMap?.getField('ignore')?.toBoolValue() ?? false,
      name: fieldMap?.getField('name')?.toStringValue(),
      defaultValue:
          ConstantReader(fieldMap?.getField('defaultValue'))?.literalValue,
    );
    return jsonProp;
  }

  JsonEnumProperty getEnumProp(ParameterElement param) {
    final propChecker = TypeChecker.fromRuntime(JsonEnumProperty);
    final jsonPropType = param.isInitializingFormal
        ? propChecker
            .firstAnnotationOf((param as FieldFormalParameterElement).field)
        : null;
    final fieldMap = jsonPropType?.getField('(super)') ?? jsonPropType;
    final jsonProp = JsonEnumProperty(
      serializationType: fieldMap != null
          ? SerializationType.values.firstWhere((val) =>
              fieldMap
                  ?.getField('serializationType')
                  ?.getField(Utils.enumToString(val)) !=
              null)
          : SerializationType.Value,
    );
    return jsonProp;
  }

  Map<dynamic, dynamic> getEnumValueMap(
      ParameterElement param, JsonEnumProperty enumProp) {
    final propChecker = TypeChecker.fromRuntime(EnumValue);
    final enumElement = ((param as FieldFormalParameterElement)
        .field
        .type
        .element as ClassElement);
    final enumFields =
        enumElement.fields.where((e) => e.isEnumConstant).toList();
    final enumValProps = enumFields
        .map((field) => propChecker.firstAnnotationOf(field))
        .toList();
    return enumFields.asMap().entries.fold(<dynamic, dynamic>{},
        (map, fieldEntry) {
      final displayName = fieldEntry.value.displayName;
      final key = enumProp.serializationType == SerializationType.Index
          ? ConstantReader(enumElement
                  .getField(displayName)
                  .computeConstantValue()
                  .getField(displayName))
              .intValue
          : displayName;
      final value =
          ConstantReader(enumValProps[fieldEntry.key].getField('value'))
                  .literalValue ??
              key;
      map[key] = value;
      return map;
    });
  }

  Map<dynamic, dynamic> cleanMap(Map<dynamic, dynamic> valueMap) {
    return valueMap.entries.fold(<dynamic, dynamic>{}, (map, entry) {
      if (entry.key != entry.value) map[entry.key] = entry.value;
      return map;
    });
  }

  String _generateSerialize(String val, DartType type) {
    return 'JsonMapper.serializeToMap($val)';
  }

  String _generateDeserialize(String val, DartType type) {
    return 'JsonMapper.deserialize<${type}>($val)';
  }

  bool isPrimitiveType(DartType type) {
    return type.isDartCoreBool ||
        type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isDartCoreNum ||
        type.isDartCoreString;
  }

  bool isParamFieldFormal(ParameterElement param) {
    return param.isInitializingFormal;
  }

  bool isParamEnum(FieldFormalParameterElement param) {
    return (param.field.type.element as ClassElement).isEnum;
  }

  String _generateInit(List<ClassElement> elements) {
    return '''
void init() {
  ${elements.map(_generateRegistration).join('\n  ')} 
}
    ''';
  }

  String _generateRegistration(ClassElement element) {
    return '''JsonMapper.register(_${element.displayName.toLowerCase()}Mapper);''';
  }

  String _generateHeader(List<ClassElement> elements) {
    return [
      '''// GENERATED CODE - DO NOT MODIFY BY HAND''',
      '''// Generated and consumed by 'simple_json' ''',
      '',
      '''import 'package:simple_json_mapper/simple_json_mapper.dart';''',
      Utils.dedupe(elements.map(_generateImport).toList()).join('\n')
    ].join('\n');
  }

  String _generateImport(ClassElement element) {
    return '''import '${element.library.identifier}';''';
  }

  // T toObjectOfType<T>(DartObject dartObject, ParameterizedType type) {
  //   type.con
  //   return
  // }

}
