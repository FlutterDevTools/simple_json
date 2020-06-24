import 'package:simple_json_mapper/simple_json_mapper.dart';

class SpecialDateTimeConverter extends JsonConverter<String, DateTime> {
  const SpecialDateTimeConverter([this.shouldPad = false]);
  final bool shouldPad;

  @override
  DateTime fromJson(String value) {
    final dateParts = value.split('-').map((s) => int.parse(s)).toList();
    return DateTime(dateParts[0], dateParts[1], dateParts[2]);
  }

  @override
  String toJson(DateTime value) =>
      '${value.year}-${_leftPad(value.month, shouldPad)}-${_leftPad(value.day, shouldPad)}';

  String _leftPad(int value, bool shouldPad) {
    return shouldPad && value.abs().toString().length == 1
        ? '0$value'
        : value.toString();
  }
}
