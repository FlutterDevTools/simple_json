import 'package:simple_json_mapper/src/json_converter.dart';

class DefaultISO8601DateConverter extends JsonConverter<String, DateTime> {
  const DefaultISO8601DateConverter();
  @override
  DateTime fromJson(String value) {
    return DateTime.parse(value);
  }

  @override
  String toJson(DateTime value) {
    return value?.toIso8601String();
  }
}
