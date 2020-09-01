import 'package:simple_json_mapper/simple_json_mapper.dart';

class Test {
  const Test({this.name, this.nestedTest});
  final String name;
  final NestedTest nestedTest;
}

@JObj()
class NestedTest {
  const NestedTest({this.ze, this.data});
  final dynamic data;
  final String ze;
}

@JObj()
class JsonApiResponse {
  const JsonApiResponse({
    this.errorData,
    this.errorMessage,
    this.fieldErrors,
    this.data,
  });

  final dynamic data;
  final dynamic errorData;
  final String errorMessage;
  final List<FieldKeyValuePair> fieldErrors;
}

class FieldKeyValuePair {
  const FieldKeyValuePair({this.key, this.value});
  final String key;
  final String value;
}
