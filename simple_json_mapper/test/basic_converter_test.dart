import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:test/test.dart';

import 'test_data/test.dart';

void main() {
  const serializedTest = '{"name":"Blah"}';
  setUpAll(() {
    // The registration is normally done automatically by the generator (`simple_json package`)
    JsonMapper.register(JsonObjectMapper<Test>(
      (mapper, map) => Test(
        name: map['name'] as String,
      ),
      (mapper, instance) => {
        'name': instance.name,
      },
    ));
  });

  group('Serialize', () {
    test('Simple model', () {
      final jsonStr = JsonMapper.serialize(Test(name: 'Blah'));
      expect(jsonStr, equals(serializedTest));
    });
  });
  group('Deserialize', () {
    test('Simple model', () {
      final obj = JsonMapper.deserialize<Test>(serializedTest);
      expect(obj, isNotNull);
      expect(obj!.name, equals('Blah'));
    });
  });
}
