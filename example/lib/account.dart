import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/product.dart';

@JsonObject()
class Account {
  const Account({
    this.name,
    this.number,
    this.amount,
    this.transactionCount,
    this.isActive,
    this.product,
  });
  final String name;
  final String number;
  final double amount;
  final int transactionCount;
  final bool isActive;
  final Product product;
}
