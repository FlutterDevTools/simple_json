```dart
import 'package:simple_json/builder.dart';

final _personMapper = JsonObjectMapper(
  (Map<String, dynamic> json) => Person(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  ),
  (Person instance) => <String, dynamic>{
    'firstName': instance.firstName,
    'lastName': instance.lastName,
    'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  },
);

void init() {
  JsonMapper.register(_personMapper);
}
```