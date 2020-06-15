import 'package:simple_json/simple_json.dart';

@JsonObject()
class Test {
  const Test({this.name});
  final String name;
}
