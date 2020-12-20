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

  final implicitlyOptedTypes = Set<DartType>();
  final usedElements = Set<Element>();
  final converterTypes = {'$DateTime', '$Duration'};

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
    final annotatedClassesInLibrary = <ClassElement>[];
    final converterClasses = <ClassElement>[];
    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      if (!await buildStep.resolver.isLibrary(input)) continue;
      final library = await buildStep.resolver.libraryFor(input);
      final reader = LibraryReader(library);
      converterClasses.addAll(reader.classes.where((c) =>
          TypeChecker.fromRuntime(JsonConverter)
              .isSuperOf(reader.classes.toList()[0])));

      annotatedClassesInLibrary.addAll(reader
          .annotatedWith(TypeChecker.fromRuntime(JsonObject))
          .where((match) => match.element is ClassElement)
          .map((match) => match.element as ClassElement)
          .toList());
    }

    converterTypes.addAll(converterClasses
        .map((c) => c.supertype.typeArguments[1])
        .where((type) => !isPrimitiveType(type))
        .map((t) => t.getDisplayString(withNullability: false))
        .toList());
    final annotatedClasses = annotatedClassesInLibrary.toSet();
    final aliases = annotatedClasses.where((libClass) {
      final redirectedCtor = libClass.unnamedConstructor?.redirectedConstructor;
      final superTypeCtor = libClass.supertype?.element?.unnamedConstructor;
      return redirectedCtor != null &&
          superTypeCtor != null &&
          redirectedCtor == superTypeCtor;
    }).toList();
    aliases.forEach((alias) {
      annotatedClasses.remove(alias);
      annotatedClasses.add(alias.supertype.element);
    });

    final mappers = annotatedClasses.map((c) => _generateMapper(c)).toList();

    final allImplicitlyOptedClasses = Set<ClassElement>();
    while (true) {
      final implicitlyOptedClassTypes = implicitlyOptedTypes
          .where((match) => match.element is ClassElement)
          .map((match) => match.element as ClassElement)
          .toSet()
          .difference(annotatedClasses.toSet())
          .difference(allImplicitlyOptedClasses);
      if (implicitlyOptedClassTypes.isEmpty) break;
      allImplicitlyOptedClasses.addAll(implicitlyOptedClassTypes);
      implicitlyOptedTypes.clear();
      mappers.addAll(implicitlyOptedClassTypes.map((c) => _generateMapper(c)));
    }

    print(
        'WARNING: Generated mappings for the following unannotated types: ${allImplicitlyOptedClasses.map((t) => t.toString()).join(', ')}');

    final classes = [...annotatedClasses, ...allImplicitlyOptedClasses];
    final imports =
        _generateHeader([...classes, ...converterClasses, ...usedElements]);
    final registrations = _generateInit(
        classes
            .where((c) =>
                c.unnamedConstructor != null && !c.isEnum && !c.isAbstract)
            .toList(),
        classes,
        converterClasses);

    lines.add(imports);
    lines.addAll(mappers);
    lines.add(registrations);

    await buildStep.writeAsString(_allFileOutput(buildStep), lines.join('\n'));
  }

  String _generateMapper(ClassElement element) {
    if (element.unnamedConstructor == null ||
        element.isEnum ||
        element.isAbstract) return '';

    final elementName = element.name;
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
    final name = param.name;
    final jsonName = prop.name ?? name;
    final accessorStr = "json['$jsonName']";
    final converterWrapper = (String val, [String type]) =>
        'mapper.applyFromJsonConverter${type != null ? '<$type>' : ''}($val${converterProp != null ? ', $converterProp' : ''})';
    final valFn = ([String asType]) {
      final accStr = asType == null
          ? converterWrapper(
              accessorStr, param.type.isDynamic ? 'dynamic' : null)
          : accessorStr;
      return '''$accStr${asType != null ? ' as $asType' : ''}''';
    };
    final _genEnum = (ParameterElement param, {DartType type, String name}) {
      implicitlyOptedTypes.add(param.type);
      final enumProp = getEnumProp(param);
      final enumValueMap = cleanMap(getEnumValueMap(enumProp,
          param: param, enumClassEl: type?.element as ClassElement));
      return converterWrapper(_generateEnumFromMap(
          type ?? param.type, name ?? param.name, enumProp, enumValueMap));
    };
    var val;
    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      final firstTypeArg = typeArgs.isNotEmpty ? typeArgs.first : null;
      if (!isPrimitiveType(firstTypeArg) && !isSkippedType(firstTypeArg)) {
        implicitlyOptedTypes.add(firstTypeArg);
        final isEnum = firstTypeArg.element is ClassElement &&
            (firstTypeArg.element as ClassElement).isEnum;
        final mapBody = isEnum
            ? _genEnum(param,
                type: firstTypeArg,
                name: firstTypeArg.getDisplayString(withNullability: false))
            : _generateDeserialize('item', firstTypeArg);
        val =
            '''(${valFn('List')})?.cast<Map<String, dynamic>>()?.map((item) => $mapBody)?.toList()''';
      } else {
        final isConverter = isConverterType(firstTypeArg);
        val =
            '''(${valFn('List')})?${isConverter ? '' : '.cast<${firstTypeArg.element.name}>()?'}.map((${isConverter ? 'dynamic ' : ''}item) => ${converterWrapper('item', firstTypeArg.element.name)})?.toList()''';
      }
    } else if (param.type.isDartCoreMap) {
      // TODO(D10100111001): Handle non primitive types
      final typeArgs = (param.type as InterfaceType).typeArguments;
      final firstTypeArg = typeArgs.isNotEmpty ? typeArgs.first : null;
      final secondTypeArg = typeArgs.isNotEmpty ? typeArgs[1] : null;
      if (!isPrimitiveType(firstTypeArg))
        implicitlyOptedTypes.add(firstTypeArg);
      if (!isPrimitiveType(secondTypeArg))
        implicitlyOptedTypes.add(secondTypeArg);
      val =
          '(${valFn('Map<String, dynamic>')})?.cast<${firstTypeArg.element.name}, ${secondTypeArg.element.name}>()';
    } else if (isParamFieldFormal(param) && isParamEnum(param)) {
      val = _genEnum(param);
    } else if (!isPrimitiveType(param.type) &&
        !isSkippedType(param.type) &&
        val == null) {
      implicitlyOptedTypes.add(param.type);
      val = _generateDeserialize(valFn('Map<String, dynamic>'), param.type);
    }
    return '''$name: ${val ?? valFn()}${prop.defaultValue != null ? ' ?? ${prop.defaultValue.toString()}' : ''},''';
  }

  String _generateEnumFromMap(DartType type, String name,
      JsonEnumProperty enumProp, Map<dynamic, dynamic> enumValueMap) {
    final isIndex = enumProp.serializationType == SerializationType.Index;
    final value =
        isIndex ? 'item.index' : "item.toString().split('.')[1].toLowerCase()";
    return '''${type.element.name}.values.firstWhere(
        (item) => ${_generateMapLookup(enumValueMap, value)} == json['$name']${!isIndex ? '?.toLowerCase()' : ''},
        orElse: () => null)''';
  }

  String _generateToMapItem(ParameterElement param) {
    final converterProp = getConverterProp(param);
    final prop = getProp(param);
    if (prop.ignore) return null;
    final name = param.name;
    final jsonName = prop.name ?? name;
    final converterWrapper = (String val, [String type]) =>
        'mapper.applyFromInstanceConverter${type != null ? '<$type>' : ''}($val${converterProp != null ? ', $converterProp' : ''})';
    final valFn = () => 'instance.${name}';
    var val;
    var useTransform = converterProp != null;

    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      final firstTypeArg = typeArgs.isNotEmpty ? typeArgs.first : null;
      final isConverter = isConverterType(firstTypeArg);
      if (!isPrimitiveType(firstTypeArg)) {
        if (!isSkippedType(firstTypeArg))
          implicitlyOptedTypes.add(firstTypeArg);
        val =
            '''${valFn()}?.map${isConverter ? '<dynamic>' : ''}((item) => ${isConverter ? converterWrapper('item') : _generateSerialize('item', firstTypeArg)})?.toList()''';
      }
    } else if (param.type.isDartCoreMap) {
      // TODO(D10100111001): Handle non primitive types
      final typeArgs = (param.type as InterfaceType).typeArguments;
      final firstTypeArg = typeArgs.isNotEmpty ? typeArgs.first : null;
      final secondTypeArg = typeArgs.isNotEmpty ? typeArgs[1] : null;
      if (!isPrimitiveType(firstTypeArg))
        implicitlyOptedTypes.add(firstTypeArg);
      if (!isPrimitiveType(secondTypeArg))
        implicitlyOptedTypes.add(secondTypeArg);
    } else if (isParamFieldFormal(param) && isParamEnum(param)) {
      final enumProp = getEnumProp(param);
      final enumValueMap = cleanMap(getEnumValueMap(enumProp, param: param));
      val = _generateMapLookup(
          enumValueMap, '${valFn()}${_generateEnumToMap(param, enumProp)}');
      useTransform = true;
    } else if (!isPrimitiveType(param.type) &&
        !isSkippedType(param.type) &&
        val == null) {
      implicitlyOptedTypes.add(param.type);
      val = _generateSerialize(valFn(), param.type);
    }
    if (val == null) useTransform = true;
    val =
        "${val ?? valFn()}${prop.defaultValue != null ? ' ?? ${prop.defaultValue.toString()}' : ''}";
    return ''''$jsonName': ${useTransform ? converterWrapper(val, param.type.isDynamic ? 'dynamic' : null) : val},''';
  }

  String _generateEnumToMap(ParameterElement param, JsonEnumProperty enumProp) {
    return '''${enumProp.serializationType == SerializationType.Index ? '?.index' : "?.toString()?.split('.')?.elementAt(1)"}''';
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
          ?.firstWhere((f) => f.name == param.name, orElse: () => null);
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
    final getValue = (ParameterElement p) => obj.getField(p.name);
    final valueFn = (ParameterElement p) =>
        p != null ? ConstantReader(getValue(p)).literalValue : null;
    final positionalParams = params
        .where((p) => p.isPositional && getValue(p) != null)
        .map((p) => valueFn(p))
        .toList();
    final namedParams = params
        .where((p) => p.isNamed && getValue(p) != null)
        .map((p) => '${p.name}: ${valueFn(p)}')
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
    JsonEnumProperty enumProp, {
    ParameterElement param,
    ClassElement enumClassEl,
  }) {
    final propChecker = TypeChecker.fromRuntime(EnumValue);
    final enumElement = enumClassEl ??
        ((param as FieldFormalParameterElement).field.type.element
            as ClassElement);
    final enumFields =
        enumElement.fields.where((e) => e.isEnumConstant).toList();
    final enumValProps = enumFields
        .map((field) => propChecker.firstAnnotationOf(field))
        .toList();
    return enumFields.asMap().entries.fold(<dynamic, dynamic>{},
        (map, fieldEntry) {
      final displayName = fieldEntry.value.name;
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
    return 'mapper.deserialize<${type.getDisplayString(withNullability: false)}>($val)';
  }

  bool isPrimitiveType(DartType type) {
    return type != null &&
        (type.isDartCoreBool ||
            type.isDartCoreDouble ||
            type.isDartCoreInt ||
            type.isDartCoreNum ||
            type.isDartCoreString);
  }

  bool isConverterType(DartType type) =>
      converterTypes.contains(type.element.name);

  bool isSkippedType(DartType type) {
    return type != null && (isConverterType(type) || type.isDynamic);
  }

  bool isParamFieldFormal(ParameterElement param) {
    return param.isInitializingFormal;
  }

  bool isParamEnum(FieldFormalParameterElement param) {
    return param.field.type.element is ClassElement &&
        (param.field.type.element as ClassElement).isEnum;
  }

  String _generateInit(
      List<ClassElement> registrationElements,
      List<ClassElement> listCastElements,
      List<ClassElement> converterClassElements) {
    return '''
void init() {
  ${registrationElements.map(_generateRegistration).join('\n  ')} 

  ${converterClassElements.map(_generateConverter).join('\n  ')}

  ${listCastElements.map(_generateListCast).join('\n  ')}
}
    ''';
  }

  String _generateListCast(ClassElement element) {
    return '''JsonMapper.registerListCast((value) => value?.cast<${element.name}>()?.toList());''';
  }

  String _generateConverter(ClassElement element) {
    return '''JsonMapper.registerConverter(${element.name}());''';
  }

  String _generateRegistration(ClassElement element) {
    return '''JsonMapper.register(_${element.name.toLowerCase()}Mapper);''';
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
