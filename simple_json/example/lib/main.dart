import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'mapper.g.dart' as mapper;

void main() {
  mapper.init();
  // Be sure to run these commands before running this example
  // pub get
  // pub run build_runner build
  final jsonStr = JsonMapper.serialize(Test(name: 'Blah'));
  print('Serialized JSON:');
  print(jsonStr);
  print('\nDeserialized and re-serialized JSON:');
  print(JsonMapper.serialize(JsonMapper.deserialize<Test>(jsonStr)));
}

@JObj()
class Test {
  const Test({this.name});
  final String name;
}
