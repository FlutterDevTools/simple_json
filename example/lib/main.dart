import 'package:simple_json_example/converters/special_datetime.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/account.dart';
import 'package:simple_json_example/product.dart';
import 'package:simple_json_example/test.dart';
import 'package:uuid/uuid.dart';

import 'mapper.g.dart' as mapper;

void main() {
  mapper.init();
  // Convert all deserialized strings to lowercase and all serialized strings to uppercase.
  JsonMapper.registerConverter(
    JsonConverter<String, String>.fromFunction(
      fromJson: (value) => value.toLowerCase(),
      toJson: (value) => value.toUpperCase(),
    ),
  );

  // Converter for transforming all DateTime string values to a special format defined by the given class.
  JsonMapper.registerConverter(SpecialDateTimeConverter());
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
    id: Uuid().v4(),
    type: AccountType.Checking,
    name: 'Test',
    number: 'xxx12414',
    amount: 100.50,
    transactionCount: 10,
    isActive: true,
    product: product,
    localText: 'ignored text',
    closedDate: DateTime(2020, 5, 16),
    openDate: DateTime(2010, 4, 2),
  );
  print('Serialized Account:');
  final serializedAccount = JsonMapper.serialize(account);
  print(serializedAccount);
  print('\nRe-serialized Account:');
  print(
      JsonMapper.serialize(JsonMapper.deserialize<Account>(serializedAccount)));

  print('\n\nSerialized with Custom Mapper and converters:');
  // Custom mapper that has it own set of converters. Useful for encapsulating for special, adhoc serializations
  // e.g. SQLite
  final customMapper = CustomJsonMapper(
    converters: [
      // Converter for changing all boolean values from boolean to int and vice versa on serialization.
      JsonConverter<int, bool>.fromFunction(
        fromJson: (value) => value == 1 ? true : false,
        toJson: (value) => value ? 1 : 0,
      ),
    ],
  );
  // Note the usage of [customerMapper] here.
  print(customMapper.serialize(account));

  print('\n\nSerialized Product:');
  final productSerialized = JsonMapper.serialize(product);
  print(productSerialized);
  print('\nRe-serialize Product:');
  print(
      JsonMapper.serialize(JsonMapper.deserialize<Product>(productSerialized)));

  // OUTPUT:
  /*
  Serialized Account:
  {"id":"b352196c-2192-4ec8-97fe-94d9ab7f9d78","type":10,"name":"Test","number":"xxx12414","amount":100.5,"tranCount":10,
  "isActive":1,"product":{"name":"Test","expiry":"2020-6-24","sizes":[10,20,40],"tests":[{"name":"hello"},{"name":"blah"}]},
  "closedDate":"2020-05-16","openingDate":"2010-4-2"}

  Re-serialized Account:
  {"id":"b352196c-2192-4ec8-97fe-94d9ab7f9d78","type":10,"name":"Test","number":"xxx12414","amount":100.5,"tranCount":10,
  "isActive":1,"product":{"name":"Test","expiry":"2020-6-24","sizes":[10,20,40],"tests":[{"name":"hello"},{"name":"blah"}]},
  "closedDate":"2020-05-16","openingDate":"2010-4-2"}


  Serialized with Custom Mapper and converters:
  {"id":"B352196C-2192-4EC8-97FE-94D9AB7F9D78","type":10,"name":"TEST","number":"XXX12414","amount":100.5,"tranCount":10,
  "isActive":true,"product":{"name":"TEST","expiry":"2020-06-24T01:56:31.942252","sizes":[10,20,40],"tests":[{"name":"HELLO"},
  {"name":"BLAH"}]},"closedDate":"2020-05-16","openingDate":"2010-04-02T00:00:00.000"}


  Serialized Product:
  {"name":"Test","expiry":"2020-6-24","sizes":[10,20,40],"tests":[{"name":"hello"},{"name":"blah"}]}

  Re-serialize Product:
  {"name":"Test","expiry":"2020-6-24","sizes":[10,20,40],"tests":[{"name":"hello"},{"name":"blah"}]}
  */
}
