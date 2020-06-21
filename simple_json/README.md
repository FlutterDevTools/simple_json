# simple_json
Simple way to dynamically convert from and to JSON using build-time generators given a type.

### How?
1. A single `mapper.g.dart` is generated at build-time when the `build_runner build` command is executed. [View example of generated file](example/lib/mapper.g.dart). [Advanced example](../example/lib/mapper.g.dart)
2. This generated file contains the necessary code (serialization and de-serialization logic) to map from and to JSON. 
3. These object mappers are registered with the JSON Mapper in the init function.
4. The init function is the first line of code that should be executed in your `main.dart` file.
5. At runtime, all of the mappers are registered (using the aforementioned `init` method) and can then be looked up using the class type parameter passed into the `serialize<T>` or `deserialize<T>` generic methods.

### Why?
- Simple
- No messy `.g.dart` files for each serializable file (single root-level file which contains all of the generated code)
- Dynamic serialization and de-serialization without caring about the actual type
- Model files stay clean (no extra generated code) and don't care about the serialization logic (SRP)
- No need to specify custom object and iterable type casting
- No bloated reflection on the entire type with linting/analyzer issues

## Quick Start

<u>pubspec.yaml</u> (**Note**: `simple_json` must be added under `dev_dependencies`)
```yaml
dependencies:
  simple_json_mapper: ^0.1.6

dev_dependencies:
  simple_json: ^0.1.1
  build_runner: ^1.10.0
```

### Setup
<u>main.dart</u>
```dart
// Generated file. Can be added to .gitignore
import 'mapper.g.dart' as mapper;

void main() {
  mapper.init();
  ...
}
```

### Usage
**Model**
```dart
import 'package:simple_json_mapper/simple_json_mapper.dart';

// Required annotation/decorator to opt-in model for json setup. Alias for [JsonObject]
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
  // Specify the enum serialization type (index or value based). Alias for [JsonEnumProperty]
  // SerializationType.Index: Savings = 0, Checking = 1
  // SerializationType.Value: Savings = 'Savings', Checking = 'Checking'
  // Enum fields can be annotated with [EnumValue] to provide a custom value.
  @JEnumProp(serializationType: SerializationType.Index)
  final AccountType type;
  final String name;
  final String number;
  final double amount;

  @JsonProperty(name: 'tranCount', defaultValue: 11)
  final int transactionCount;

  final bool isActive;

  // Alias for [JsonProperty]
  @JProp(ignore: true)
  final String localText;

  final Product product;
}

@JsonObject()
class Product {
  const Product({this.name, this.expiry, this.sizes, this.tests});
  final String name;
  final DateTime expiry;
  final List<int> sizes;
  final List<Test> tests;
}

// Linked models don't require the annotation but it is recommended.
class Test {
  const Test({this.name});
  final String name;
}

enum AccountType {
  // Override serialization enum value
  @EnumValue(value: 25)
  Savings,
  @EnumValue(value: 10)
  Checking
}

```

#### Serialization
```dart
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
    type: AccountType.Checking,
    name: 'Test',
    number: 'xxx12414',
    amount: 100.50,
    transactionCount: 10,
    isActive: true,
    product: product,
    localText: 'ignored text',
  );
  final accountJson = JsonMapper.serialize(account);
```

#### De-serialization

```dart
  final account = JsonMapper.deserialize<Account>(accountJson);
```

### Generating Mapper File

*build*
```bash
# dart
pub get
pub run build_runner build
# flutter
flutter pub get
flutter packages pub run build_runner build
```

*watch*
```bash
# dart
pub get
pub run build_runner watch
# flutter
flutter pub get
flutter packages pub run build_runner watch
```
