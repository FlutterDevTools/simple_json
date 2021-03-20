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
  final obj = JsonMapper.deserialize<Test>(jsonStr);
  print(obj != null ? JsonMapper.serialize(obj) : obj);
}

@JsonObject()
class Test {
  const Test({required this.name});
  final String name;
}
