import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/test.dart';

@JsonObject()
class Product {
  const Product({this.name, this.expiry, this.sizes, this.tests});
  final String name;
  final DateTime expiry;
  final List<int> sizes;
  final List<Test> tests;
}
