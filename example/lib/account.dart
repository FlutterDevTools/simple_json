import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/product.dart';

@JObj()
class Account {
  const Account({
    this.type,
    this.name,
    this.number,
    this.amount,
    this.transactionCount,
    this.isActive,
    this.product,
    this.localText,
  });
  @JEnumProp(serializationType: SerializationType.Index)
  final AccountType type;
  final String name;
  final String number;
  final double amount;

  @JsonProperty(name: 'tranCount', defaultValue: 11)
  final int transactionCount;

  final bool isActive;

  @JProp(ignore: true)
  final String localText;

  final Product product;
}

enum AccountType {
  @EnumValue(value: 25)
  Savings,
  @EnumValue(value: 10)
  Checking
}
