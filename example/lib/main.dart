import 'package:simple_json/simple_json.dart';
import 'package:simple_json_usage/account.dart';
import 'package:simple_json_usage/product.dart';

import 'mapper.g.dart' as mapper;

void main() {
  mapper.init();
  final account = Account(
    name: 'Test',
    number: 'xxx12414',
    amount: 100.50,
    transactionCount: 10,
    isActive: true,
  );
  final serializedAccount = JsonMapper.serialize(account);
  print(serializedAccount);
  print(
      JsonMapper.serialize(JsonMapper.deserialize<Account>(serializedAccount)));

  final productSerialized = JsonMapper.serialize(
    Product(
      name: 'Test',
      expiry: DateTime.now(),
      sizes: [10, 20, 40],
      tests: [
        Test(name: 'hello'),
        Test(name: 'blah'),
      ],
    ),
  );
  print(productSerialized);
  print(
      JsonMapper.serialize(JsonMapper.deserialize<Product>(productSerialized)));
}

@JsonObject()
class Test {
  const Test({this.name});
  final String name;
}
