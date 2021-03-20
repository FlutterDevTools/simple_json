import 'package:simple_json_mapper/src/json_converter.dart';

class DefaultISO8601DateConverter extends JsonConverter<String?, DateTime?> {
  const DefaultISO8601DateConverter();
  @override
  DateTime? fromJson(String? value) {
    return value != null ? DateTime.parse(value) : null;
  }

  @override
  String? toJson(DateTime? value) {
    return value?.toIso8601String();
  }
}
