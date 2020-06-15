import 'package:simple_json/annotations.dart';

@JsonObject()
class Account {
  const Account({this.name, this.number, this.amount, this.transactionCount, this.isActive});
  final String name;
  final String number;
  final double amount;
  final int transactionCount;
  final bool isActive;
}
