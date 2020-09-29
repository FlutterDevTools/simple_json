import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/test.dart';

enum ProductType { Shoe, Shirt, Bottom }

@JsonObject()
class Product {
  const Product({
    this.name,
    this.type,
    this.expiry,
    this.productDetails,
    this.sizes,
    this.tests,
    this.productMatchPattern,
    this.attributes,
    this.parent,
    this.timeline,
  });
  final String name;
  final ProductType type;
  final DateTime expiry;
  final Uri productDetails;
  final RegExp productMatchPattern;
  final List<double> sizes;
  final List<Test> tests;
  final Map<String, String> attributes;
  final Product parent;
  final List<DateTime> timeline;
}
