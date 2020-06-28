# simple_json
Simple way to dynamically convert from and to JSON using build-time generators given a type.

**Note**: Ignore the warning and tags indicating that this package is no compatible with the Flutter and other SDKs. This is reported because this generator package uses `dart:mirrors` library which is not supported by those SDKs. In this case, it will all work fine as this package is supposed to be just build-time generators. This package should **ONLY** be added under `dev_dependencies` to work correctly. The supporting [simple_json_mapper](https://pub.dev/packages/simple_json_mapper) package also needs to be included but as a regular dependency under `dependencies`. 

### How?
1. A single `mapper.g.dart` is generated at build-time when the `build_runner build` command is executed. [View example of generated file](example/lib/mapper.g.dart). [Advanced example](../example/lib/mapper.g.dart)
2. This generated file contains the necessary code (serialization and de-serialization logic) to map from and to JSON. 
3. These object mappers are registered with the JSON Mapper in the init function.
4. The init function is the first line of code that should be executed in your `main.dart` file.
5. At runtime, all of the mappers are registered (using the aforementioned `init` method) and can then be looked up using the class type parameter passed into the `serialize<T>` or `deserialize<T>` generic methods.

### Why?
- Simple
- No messy `.g.dart` files for each serializable file (single root-level file which contains all of the generated code)
- Dynamic serialization and de-serialization without using the actual type directly while still maintaining type-safety. i.e. `JsonMapper.serialize(account)` vs `account.toJson()` (account does not need to have any logic and it is not used directly for the actual serialization)
- Model files stay clean (no extra generated code) and don't care about the serialization logic (SRP)
- No need to specify custom object and iterable type casting
- No bloated reflection on the entire type with linting/analyzer issues

Dynamic serialization and de-serialization allows for allow for creating great type-safe APIs. A good example is a simple storage service in flutter.

<details>
  <summary>storage_service.dart</summary>

```dart
class StorageService implements IStorageService {
  const StorageService(this.preferences);
  final SharedPreferences preferences;

  @override
  Future<T> get<T>({T Function() defaultFn, bool private = false}) async {
    return getWithKey(T.toString(), defaultFn: defaultFn, private: private);
  }

  @override
  Future<T> getWithKey<T>(String key,
      {T Function() defaultFn, bool private = false}) async {
    return JsonMapper.deserialize<T>(
            await getProvider(private).getString(key)) ??
        defaultFn();
  }

  @override
  Future<bool> set<T>(T value, [bool private = false]) {
    return setWithKey(T.toString(), value, private);
  }

  @override
  Future<bool> setWithKey<T>(String key, T value, [bool private = false]) {
    return getProvider(private).setString(key, JsonMapper.serialize(value));
  }

  IStorageProvider getProvider(bool private) {
    return private && !AppUtils.isWeb
        ? SecureStorage()
        : SharedPreferencesStorage(preferences);
  }
}

```
</details>

Using `simple_json`, this `StorageService` has a simple generic type-safe API that can store serialize the models classes before storing them as string making it really simple and boilerplate-free.

## Quick Start

pubspec.yaml (**Note**: `simple_json` must be added under `dev_dependencies`)
```yaml
dependencies:
  simple_json_mapper: ^0.2.2

dev_dependencies:
  simple_json: ^0.2.3
  build_runner: ^1.10.0
```

### Setup
main.dart
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

### Converters

```dart
  // Convert all deserialized strings to lowercase and all serialized strings to uppercase.
  JsonMapper.registerConverter(
    JsonConverter<String, String>.fromFunction(
      fromJson: (value) => value.toLowerCase(),
      toJson: (value) => value.toUpperCase(),
    ),
  );

  // Converter for transforming all DateTime string values to a special format defined by the given class.
  JsonMapper.registerConverter(SpecialDateTimeConverter());
```

#### Custom JsonMapper

```dart
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
```

**Refer to the [advanced example](../example/lib/main.dart) for advanced usage of functionalities.**

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
