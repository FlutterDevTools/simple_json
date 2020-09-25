import 'package:simple_json_mapper/simple_json_mapper.dart';

class UriConverter extends JsonConverter<String, Uri> {
  const UriConverter();

  @override
  Uri fromJson(String value) {
    return Uri.parse(value);
  }

  @override
  String toJson(Uri value) => value.toString();
}
