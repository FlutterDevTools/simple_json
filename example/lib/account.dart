import 'package:simple_json_example/converters/special_datetime.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/product.dart';

class BaseAccount {
  const BaseAccount({this.openDate, this.closedDate});
  @JProp(name: 'openingDate')
  final DateTime openDate;

  // Converter directly applied to a field. Takes precedence over all converter configurations
  @SpecialDateTimeConverter(true)
  final DateTime closedDate;
}

class Account extends BaseAccount {
  const Account(
      {this.id,
      this.type,
      this.name,
      this.number,
      this.amount,
      this.transactionCount,
      this.isActive,
      this.product,
      this.localText,
      DateTime closedDate,
      DateTime openDate})
      : super(openDate: openDate, closedDate: closedDate);

  final String id;
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
