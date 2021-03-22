import 'package:simple_json_mapper/simple_json_mapper.dart';

@JObj()
class BaseTest {
  const BaseTest({required this.name, required this.nestedTest});
  final String name;
  final NestedTest nestedTest;
}

@JObj()
class Test extends BaseTest {
  const Test({
    required String name,
    required NestedTest nestedTest,
    this.extraProp,
  }) : super(name: name, nestedTest: nestedTest);
  final String? extraProp;
}

@JObj()
class NestedTest {
  const NestedTest({required this.ze, this.data});
  final dynamic data;
  final String ze;
}

@JObj()
class JsonApiResponse {
  const JsonApiResponse({
    this.errorData,
    required this.errorMessage,
    required this.fieldErrors,
    this.data,
  });

  final dynamic data;
  final dynamic errorData;
  final String errorMessage;
  final List<FieldKeyValuePair> fieldErrors;
}

class FieldKeyValuePair {
  const FieldKeyValuePair({required this.key, required this.value});
  final String key;
  final String value;
}
