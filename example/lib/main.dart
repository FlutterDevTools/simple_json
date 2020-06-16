import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/account.dart';
import 'package:simple_json_example/product.dart';
import 'package:simple_json_example/test.dart';

import 'mapper.g.dart' as mapper;

void main() {
  mapper.init();
  final product = Product(
    name: 'Test',
    expiry: DateTime.now(),
    sizes: [10, 20, 40],
    tests: [
      Test(name: 'hello'),
      Test(name: 'blah'),
    ],
  );
  final account = Account(
    name: 'Test',
    number: 'xxx12414',
    amount: 100.50,
    transactionCount: 10,
    isActive: true,
    product: product,
  );
  final serializedAccount = JsonMapper.serialize(account);
  print(serializedAccount);
  print(
      JsonMapper.serialize(JsonMapper.deserialize<Account>(serializedAccount)));

  final productSerialized = JsonMapper.serialize(product);
  print(productSerialized);
  print(
      JsonMapper.serialize(JsonMapper.deserialize<Product>(productSerialized)));
}
