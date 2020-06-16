import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class Test {
  const Test({this.name});
  final String name;
}
