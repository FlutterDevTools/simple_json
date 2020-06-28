import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
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
  final usedElements = Set<Element>();

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
    final imports = _generateHeader([...classes, ...usedElements]);
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
  (CustomJsonMapper mapper, Map<String, dynamic> json) => ${elementName}(
    ${parameters.map(_generateFromMapItem).where((line) => line != null).join('\n    ')}
  ),
  (CustomJsonMapper mapper, ${elementName} instance) => <String, dynamic>{
    ${parameters.map(_generateToMapItem).where((line) => line != null).join('\n    ')}
  },
);
''';
  }

  String _generateFromMapItem(ParameterElement param) {
    final converterProp = getConverterProp(param);
    final prop = getProp(param);
    if (prop.ignore) return null;
    final name = param.displayName;
    final jsonName = prop.name ?? name;
    final accessorStr = "json['$jsonName']";
    final converterWrapper = (String val, [String type]) =>
        'mapper.applyFromJsonConverter${type != null ? '<$type>' : ''}($val${converterProp != null ? ', $converterProp' : ''})';
    final valFn = ([String asType]) {
      final accStr =
          asType == null ? converterWrapper(accessorStr) : accessorStr;
      return '''$accStr${asType != null ? ' as $asType' : ''}''';
    };
    var val;
    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      final firstTypeArg = typeArgs.isNotEmpty ? typeArgs.first : null;
      if (!isPrimitiveType(firstTypeArg)) {
        processedTypes.add(firstTypeArg);
        val =
            '''(${valFn('List')}).cast<Map<String, dynamic>>().map((item) => ${_generateDeserialize('item', firstTypeArg)}).toList()''';
      } else {
        val =
            '''(${valFn('List')}).cast<${firstTypeArg.toString()}>().map((item) => ${converterWrapper('item', firstTypeArg.toString())}).toList()''';
      }
    } else if (isParamFieldFormal(param) && isParamEnum(param)) {
      final enumProp = getEnumProp(param);
      final enumValueMap = cleanMap(getEnumValueMap(param, enumProp));
      val =
          converterWrapper(_generateEnumFromMap(param, enumProp, enumValueMap));
    } else if (!isPrimitiveType(param.type) &&
        !isSkippedType(param.type) &&
        val == null) {
      processedTypes.add(param.type);
      val = _generateDeserialize(valFn('Map<String, dynamic>'), param.type);
    }
    return '''$name: ${val ?? valFn()}${prop.defaultValue != null ? ' ?? ${prop.defaultValue.toString()}' : ''},''';
  }

  String _generateEnumFromMap(ParameterElement param, JsonEnumProperty enumProp,
      Map<dynamic, dynamic> enumValueMap) {
    final isIndex = enumProp.serializationType == SerializationType.Index;
    final value =
        isIndex ? 'item.index' : "item.toString().split('.')[1].toLowerCase()";
    return '''${param.type}.values.firstWhere(
        (item) => ${_generateMapLookup(enumValueMap, value)} == json['${param.displayName}']${!isIndex ? '.toLowerCase()' : ''},
        orElse: () => null)''';
  }

  String _generateToMapItem(ParameterElement param) {
    final converterProp = getConverterProp(param);
    final prop = getProp(param);
    if (prop.ignore) return null;
    final name = param.displayName;
    final jsonName = prop.name ?? name;
    final converterWrapper = (String val, [String type]) =>
        'mapper.applyFromInstanceConverter${type != null ? '<$type>' : ''}($val${converterProp != null ? ', $converterProp' : ''})';
    final valFn = () => 'instance.${name}';
    var val;
    var useTransform = converterProp != null;

    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      final firstTypeArg = typeArgs.isNotEmpty ? typeArgs.first : null;
      if (!isPrimitiveType(firstTypeArg)) {
        processedTypes.add(firstTypeArg);
        val =
            '''${valFn()}.map((item) => ${_generateSerialize('item', firstTypeArg)}).toList()''';
      }
    } else if (isParamFieldFormal(param) && isParamEnum(param)) {
      final enumProp = getEnumProp(param);
      final enumValueMap = cleanMap(getEnumValueMap(param, enumProp));
      val = _generateMapLookup(
          enumValueMap, '${valFn()}${_generateEnumToMap(param, enumProp)}');
      useTransform = true;
    } else if (!isPrimitiveType(param.type) &&
        !isSkippedType(param.type) &&
        val == null) {
      processedTypes.add(param.type);
      val = _generateSerialize(valFn(), param.type);
    }
    if (val == null) useTransform = true;
    val =
        "${val ?? valFn()}${prop.defaultValue != null ? ' ?? ${prop.defaultValue.toString()}' : ''}";
    return ''''$jsonName': ${useTransform ? converterWrapper(val) : val},''';
  }

  String _generateEnumToMap(ParameterElement param, JsonEnumProperty enumProp) {
    return '''${enumProp.serializationType == SerializationType.Index ? '.index' : ".toString().split('.')[1]"}''';
  }

  String _generateMapLookup(Map<dynamic, dynamic> map, String val) {
    return map.isNotEmpty ? '''(${map.toString()}[${val}] ?? ${val})''' : val;
  }

  FieldElement getMatchingSuperProp(ParameterElement param) {
    var superElement = (param.enclosingElement as ConstructorElement)
        .enclosingElement
        .supertype
        ?.element;
    while (superElement != null) {
      final field = superElement?.fields
          ?.firstWhere((f) => f.displayName == param.name, orElse: () => null);
      if (field != null)
        return field;
      else
        superElement = superElement.supertype?.element;
    }
    return null;
  }

  DartObject getPropObject(ParameterElement param, Type annotationType,
      {bool getBase = true}) {
    final propChecker = TypeChecker.fromRuntime(annotationType);
    final field = param.isInitializingFormal
        ? (param as FieldFormalParameterElement).field
        : getMatchingSuperProp(param);
    final jsonPropType =
        field != null ? propChecker.firstAnnotationOf(field) : null;
    DartObject obj = jsonPropType;
    if (getBase) {
      while (true) {
        final newObj = obj?.getField('(super)');
        if (newObj != null)
          obj = newObj;
        else
          break;
      }
    }
    return obj;
  }

  JsonProperty getProp(ParameterElement param) {
    final fieldMap = getPropObject(param, JsonProperty);
    final jsonProp = JsonProperty(
      ignore: fieldMap?.getField('ignore')?.toBoolValue() ?? false,
      name: fieldMap?.getField('name')?.toStringValue(),
      defaultValue:
          ConstantReader(fieldMap?.getField('defaultValue'))?.literalValue,
    );
    return jsonProp;
  }

  String getConverterProp(ParameterElement param, [DartObject obj]) {
    final obj = getPropObject(param, JsonConverter, getBase: false);
    if (obj == null) return null;
    final element = (obj.type?.element as ClassElement);
    if (element == null) return null;
    usedElements.add(element);
    final params = element.unnamedConstructor?.parameters;
    final getValue = (ParameterElement p) => obj.getField(p.displayName);
    final valueFn = (ParameterElement p) =>
        p != null ? ConstantReader(getValue(p)).literalValue : null;
    final positionalParams = params
        .where((p) => p.isPositional && getValue(p) != null)
        .map((p) => valueFn(p))
        .toList();
    final namedParams = params
        .where((p) => p.isNamed && getValue(p) != null)
        .map((p) => '${p.displayName}: ${valueFn(p)}')
        .toList();
    return '${element.name}(${[
      ...positionalParams,
      ...namedParams
    ].join(', ')})';
  }

  JsonEnumProperty getEnumProp(ParameterElement param) {
    final fieldMap = getPropObject(param, JsonEnumProperty);
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
      final valField = enumValProps[fieldEntry.key]?.getField('value');
      final value =
          valField != null ? ConstantReader(valField).literalValue : null;
      map[key] = value ?? key;
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
    return 'mapper.serializeToMap($val)';
  }

  String _generateDeserialize(String val, DartType type) {
    return 'mapper.deserialize<${type}>($val)';
  }

  bool isPrimitiveType(DartType type) {
    return type != null &&
        (type.isDartCoreBool ||
            type.isDartCoreDouble ||
            type.isDartCoreInt ||
            type.isDartCoreNum ||
            type.isDartCoreString);
  }

  bool isSkippedType(DartType type) {
    return type != null && {'DateTime'}.contains(type.toString());
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

  String _generateHeader(List<Element> elements) {
    return [
      '''// GENERATED CODE - DO NOT MODIFY BY HAND''',
      '''// Generated and consumed by 'simple_json' ''',
      '',
      '''import 'package:simple_json_mapper/simple_json_mapper.dart';''',
      Utils.dedupe(elements.map(_generateImport).toList()).join('\n')
    ].join('\n');
  }

  String _generateImport(Element element) {
    return '''import '${element.library.identifier}';''';
  }

  // T toObjectOfType<T>(DartObject dartObject, ParameterizedType type) {
  //   type.con
  //   return
  // }

}
