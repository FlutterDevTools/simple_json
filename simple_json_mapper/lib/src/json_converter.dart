abstract class JsonConverter<TFrom, TTo> {
  const JsonConverter();

  factory JsonConverter.fromFunction(
      {required TTo Function(TFrom value) fromJson,
      required TFrom Function(TTo value) toJson}) {
    return JsonObjectConverter<TFrom, TTo>(
        fromJsonFn: fromJson, toJsonFn: toJson);
  }

  String get toType => TTo.toString();
  String get fromType => TFrom.toString();

  TTo fromJson(TFrom value);
  TFrom toJson(TTo value);
}

class JsonObjectConverter<TFrom, TTo> extends JsonConverter<TFrom, TTo> {
  const JsonObjectConverter({required this.fromJsonFn, required this.toJsonFn});
  final TTo Function(TFrom value) fromJsonFn;
  final TFrom Function(TTo value) toJsonFn;

  @override
  TTo fromJson(TFrom value) {
    return fromJsonFn(value);
  }

  @override
  TFrom toJson(TTo value) {
    return toJsonFn(value);
  }
}
