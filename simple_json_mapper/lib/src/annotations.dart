class JObj extends JsonObject {
  const JObj() : super();
}

class JsonObject {
  const JsonObject();
}

class JProp extends JsonProperty {
  const JProp({
    required bool ignore,
    required String name,
    dynamic defaultValue,
  }) : super(
          ignore: ignore,
          name: name,
          defaultValue: defaultValue,
        );
}

class JsonProperty {
  const JsonProperty({
    required this.ignore,
    required this.name,
    this.defaultValue,
  });
  final bool ignore;
  final String name;
  final dynamic defaultValue;
}

enum SerializationType {
  Value,
  Index,
}

class JsonEnumProperty {
  const JsonEnumProperty({required this.serializationType});
  final SerializationType serializationType;
}

class JEnumProp extends JsonEnumProperty {
  const JEnumProp({required SerializationType serializationType})
      : super(serializationType: serializationType);
}

class EnumValue {
  const EnumValue({this.value});
  final dynamic value;
}
