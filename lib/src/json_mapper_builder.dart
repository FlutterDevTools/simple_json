import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as p;

import '../annotations.dart';

class JsonMapperBuilder implements Builder {
  const JsonMapperBuilder();

  static final _allFilesInLib = new Glob('lib/**');

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
          .annotatedWithExact(TypeChecker.fromRuntime(JsonObject))
          .where((match) => match.element is ClassElement)
          .map((match) => match.element as ClassElement)
          .toList());
    }

    lines.add(_generateHeader(classesInLibrary));
    lines.addAll(classesInLibrary.map((c) => _generateMapper(c)));
    lines.add(_generateInit(classesInLibrary));

    await buildStep.writeAsString(_allFileOutput(buildStep), lines.join('\n'));
  }

  String _generateMapper(ClassElement element) {
    final elementName = element.displayName;
    final parameters = element.unnamedConstructor.parameters;
    return '''

final _${elementName.toLowerCase()}Mapper = JsonObjectMapper(
  (Map<String, dynamic> json) => ${elementName}(
    ${parameters.map(_generateFromMapParameter).join('\n    ')}
  ),
  (${elementName} instance) => <String, dynamic>{
    ${parameters.map(_generateToMapItem).join('\n    ')}
  },
);
''';
  }

  String _generateFromMapParameter(ParameterElement param) {
    final name = param.displayName;
    final type = param.type.toString();
    final valueFn = (String type) => '''json['$name'] as ${type}''';
    var val;
    switch (type) {
      case 'DateTime':
        val = 'DateTime.parse(${valueFn('String')})';
        break;
      default:
        val = valueFn(type);
        break;
    }
    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      if (typeArgs.isNotEmpty && !isPrimitiveType(typeArgs.first)) {
        val = '''(${valueFn('List')}).cast<Map<String, dynamic>>().map((item) => JsonMapper.deserialize<${typeArgs.first}>(item)).toList()''';
      } else {
        val = '''(${valueFn('List')}).cast()''';
      }
    }
    return '''$name: $val,''';
  }

  String _generateToMapItem(ParameterElement param) {
    final name = param.displayName;
    final valFn = () => 'instance.${name}';
    var val;
    switch (param.type.toString()) {
      case 'DateTime':
        val = '${valFn()}.toIso8601String()';
        break;
      default:
        val = valFn();
        break;
    }
    if (param.type.isDartCoreList) {
      final typeArgs = (param.type as InterfaceType).typeArguments;
      if (typeArgs.isNotEmpty && !isPrimitiveType(typeArgs.first)) {
        val += '''.map((item) => JsonMapper.serializeToMap(item)).toList()''';
      }
    }
    return ''''$name': $val,''';
  }

  bool isPrimitiveType(DartType type) {
    return type.isDartCoreBool ||
        type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isDartCoreNum ||
        type.isDartCoreString;
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
      '''import 'package:simple_json/builder.dart';''',
      elements.map(_generateImport).join('\n')
    ].join('\n');
  }

  String _generateImport(ClassElement element) {
    return '''import '${element.library.identifier}';''';
  }
}
