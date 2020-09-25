import 'package:simple_json_mapper/simple_json_mapper.dart';

class RegExpConverter extends JsonConverter<String, RegExp> {
  const RegExpConverter();

  @override
  RegExp fromJson(String value) {
    return RegExp(value);
  }

  @override
  String toJson(RegExp value) => value.pattern;
}
