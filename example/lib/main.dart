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
    type: ProductType.Shoe,
    expiry: DateTime.now(),
    sizes: [10, 8, 5.5],
    tests: [
      Test(name: 'hello', nestedTest: NestedTest(ze: 'ok')),
      Test(name: 'blah', nestedTest: NestedTest(ze: 'he')),
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
  final productSerialized = JsonMapper.serialize([product]);
  print(productSerialized);
  print('\nRe-serialize Product:');
  print(JsonMapper.serialize(
      JsonMapper.deserializeList<Product>(productSerialized)));

  // OUTPUT:
  /*
  Serialized Account:
  {"id":"B4FECC31-2429-4631-BA57-DADA21C3D6E0","type":10,"name":"TEST","number":"XXX12414","amount":100.5,
  "tranCount":10,"isActive":true,"product":{"name":"TEST","type":"SHOE","expiry":"2020-6-28","sizes":[10.0,8.0,5.5],
  "tests":[{"name":"HELLO","nestedTest":{"ze":"OK"}},{"name":"BLAH","nestedTest":{"ze":"HE"}}]},"closedDate":
  "2020-05-16","openingDate":"2010-4-2"}

  Re-serialized Account:
  {"id":"B4FECC31-2429-4631-BA57-DADA21C3D6E0","type":10,"name":"TEST","number":"XXX12414","amount":100.5,
  "tranCount":10,"isActive":true,"product":{"name":"TEST","type":"SHOE","expiry":"2020-6-28","sizes":[10.0,8.0,5.5],
  "tests":[{"name":"HELLO","nestedTest":{"ze":"OK"}},{"name":"BLAH","nestedTest":{"ze":"HE"}}]},"closedDate":
  "2020-05-16","openingDate":"2010-4-2"}


  Serialized with Custom Mapper and converters:
  {"id":"b4fecc31-2429-4631-ba57-dada21c3d6e0","type":10,"name":"Test","number":"xxx12414","amount":100.5,
  "tranCount":10,"isActive":1,"product":{"name":"Test","type":"Shoe","expiry":"2020-06-28T02:15:21.412538",
  "sizes":[10.0,8.0,5.5],"tests":[{"name":"hello","nestedTest":{"ze":"ok"}},{"name":"blah","nestedTest":{"ze":"he"}}]},
  "closedDate":"2020-05-16","openingDate":"2010-04-02T00:00:00.000"}


  Serialized Product:
  {"name":"TEST","type":"SHOE","expiry":"2020-6-28","sizes":[10.0,8.0,5.5],"tests":[{"name":"HELLO","nestedTest":
  {"ze":"OK"}},{"name":"BLAH","nestedTest":{"ze":"HE"}}]}

  Re-serialize Product:
  {"name":"TEST","type":"SHOE","expiry":"2020-6-28","sizes":[10.0,8.0,5.5],"tests":[{"name":"HELLO","nestedTest":
  {"ze":"OK"}},{"name":"BLAH","nestedTest":{"ze":"HE"}}]}
  */
}
