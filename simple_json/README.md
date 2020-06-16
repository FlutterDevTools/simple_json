# simple_json
Simple way to dynamically convert from and to JSON using build-time generators given a type.

### Why?
- Simple
- No messy `.g.dart` files for each serializable file
- Dynamic serialization and de-serialization without caring about the actual type
- Model files stay clean and don't care about the serialization logic (SRP)

## Quick Start

*pubspec.yaml* (_Note_: `simple_json` must be added under `dev_dependencies`)
```yaml
dependencies:
  simple_json_mapper: ^0.1.0

dev_dependencies:
  simple_json: ^0.1.0
  build_runner: ^1.10.0
```

### Setup
*main.dart*
```dart
// Generated file. Can be added to .gitignore
import 'mapper.g.dart' as mapper;

void main() {
  mapper.init();
  ...
}
```

### Usage
*Model*
```dart
import 'package:simple_json/annotations.dart';

// Required annotation/decorator to opt-in model for json setup.
@JsonObject()
class Account {
  const Account({this.name, this.number, this.amount, this.transactionCount, this.isActive});
  final String name;
  final String number;
  final double amount;
  final int transactionCount;
  final bool isActive;
}
```

*Serialization*
```dart
  final account = Account(
    name: 'Test',
    number: 'xxx12414',
    amount: 100.50,
    transactionCount: 10,
    isActive: true,
  );
  final serializedAccount = JsonMapper.serialize(account);
```

*De-serialization*

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
flutter packages pub run build_runner watch
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
