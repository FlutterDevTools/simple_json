class JObj extends JsonObject {
  const JObj() : super();
}

class JsonObject {
  const JsonObject();
}

class JProp extends JsonProperty {
  const JProp({
    bool? ignore,
    String? name,
    dynamic? defaultValue,
  }) : super(
          ignore: ignore,
          name: name,
          defaultValue: defaultValue,
        );
}

class JsonProperty {
  const JsonProperty({
    this.ignore,
    this.name,
    this.defaultValue,
  });
  final bool? ignore;
  final String? name;
  final dynamic? defaultValue;
}

enum SerializationType {
  Value,
  Index,
}

class JsonEnumProperty {
  const JsonEnumProperty({this.serializationType = SerializationType.Value});
  final SerializationType serializationType;
}

class JEnumProp extends JsonEnumProperty {
  const JEnumProp(
      {SerializationType serializationType = SerializationType.Value})
      : super(serializationType: serializationType);
}

class EnumValue {
  const EnumValue({this.value});
  final dynamic value;
}
