import 'package:simple_json_mapper/simple_json_mapper.dart';

void main() {
  // The registration is normally done automatically by the generator (simple_json package)
  JsonMapper.register(JsonObjectMapper<Test>(
    (mapper, map) => Test(
      name: map['name'] as String,
    ),
    (mapper, instance) => {
      'name': instance.name,
    },
  ));

  final jsonStr = JsonMapper.serialize(Test(name: 'Blah'));
  print('Serialized JSON:');
  print(jsonStr);
  print('\nDeserialized and re-serialized JSON:');
  print(JsonMapper.serialize(JsonMapper.deserialize<Test>(jsonStr)));
}

@JsonObject()
class Test {
  const Test({this.name});
  final String name;
}
