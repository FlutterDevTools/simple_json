import 'package:simple_json_mapper/src/json_converter.dart';

class DefaultDurationConverter extends JsonConverter<String, Duration> {
  const DefaultDurationConverter();
  @override
  Duration fromJson(String value) {
    final durationParts = value.split(':');
    return Duration(
      hours: durationParts.length >= 1 ? int.tryParse(durationParts[0]) : 0,
      minutes: durationParts.length >= 2 ? int.tryParse(durationParts[1]) : 0,
      seconds: durationParts.length >= 3 ? int.tryParse(durationParts[2]) : 0,
    );
  }

  String format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

  @override
  String toJson(Duration value) {
    return format(value).toString();
  }
}
