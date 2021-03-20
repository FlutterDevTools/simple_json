import 'package:simple_json_example/converters/special_datetime.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/product.dart';

abstract class BaseAccount {
  const BaseAccount({this.ownerType, this.openDate, this.closedDate});
  final AccountOwnerType ownerType;
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
      this.features,
      this.name,
      this.number,
      this.amount,
      this.transactionCount,
      this.isActive,
      this.product,
      this.localText,
      this.refreshFrequeuncy = const Duration(minutes: 30),
      AccountOwnerType ownerType,
      DateTime closedDate,
      DateTime openDate})
      : super(ownerType: ownerType, openDate: openDate, closedDate: closedDate);

  final String id;
  @JEnumProp(serializationType: SerializationType.Index)
  final AccountType type;
  final List<AccountFeature> features;
  final String name;
  final String number;
  final double amount;
  final Duration refreshFrequeuncy;

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

enum AccountFeature {
  Cashback,
  Rewards,
}

enum AccountOwnerType { Individual, Business }
