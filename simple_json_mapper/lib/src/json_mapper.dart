import 'dart:convert';

import 'converters/datetime.dart';
import 'json_converter.dart';

class JsonObjectMapper<T> {
  const JsonObjectMapper(this.fromJsonMap, this.toJsonMap);

  final T Function(CustomJsonMapper mapper, Map<String, dynamic> map)
      fromJsonMap;
  final Map<String, dynamic> Function(CustomJsonMapper mapper, T item)
      toJsonMap;
}

class JsonMapper {
  static CustomJsonMapper _instance = CustomJsonMapper();
  static bool isRegistered<T>() => _instance.isRegistered<T>();

  static bool isRegisteredByType(String type) =>
      _instance.isRegisteredByType(type);

  static void register<T>(JsonObjectMapper<T> mapper) =>
      _instance.register(mapper);

  static String serialize<T>(T item) => _instance.serialize(item);

  static Map<String, dynamic> serializeToMap<T>(T item) =>
      _instance.serializeToMap(item);

  static T deserialize<T>(dynamic jsonVal) => _instance.deserialize(jsonVal);

  static void registerConverter<T>(JsonConverter<dynamic, T> transformer) =>
      _instance.registerConverter(transformer);

  static dynamic applyFromInstanceConverter<T>(T value) =>
      _instance.applyFromInstanceConverter(value);

  static T applyFromJsonConverter<T>(dynamic value) =>
      _instance.applyFromJsonConverter(value);
}

class CustomJsonMapper {
  CustomJsonMapper({List<JsonConverter<dynamic, dynamic>> converters}) {
    if (converters != null)
      _converters.addAll(converters
          .fold(<String, JsonConverter<dynamic, dynamic>>{}, (map, converter) {
        map[converter.toType] = converter;
        return map;
      }));
  }

  static final _mapper = <String, JsonObjectMapper<dynamic>>{};

  final _converters = <String, JsonConverter<dynamic, dynamic>>{
    (DateTime).toString(): const DefaultISO8601DateConverter(),
  };

  bool isRegistered<T>() {
    return isRegisteredByType(T.toString());
  }

  bool isRegisteredByType(String type) {
    return _mapper.containsKey(type);
  }

  void register<T>(JsonObjectMapper<T> mapper) {
    _mapper[T.toString()] = mapper;
  }

  String serialize<T>(T item) {
    return json.encode(serializeToMap(item));
  }

  Map<String, dynamic> serializeToMap<T>(T item) {
    return item != null
        ? (_mapper[T.toString()] as JsonObjectMapper<T>).toJsonMap(this, item)
        : null;
  }

  T deserialize<T>(dynamic jsonVal) {
    return jsonVal != null
        ? (_mapper[T.toString()] as JsonObjectMapper<T>).fromJsonMap(
            this, jsonVal is String ? json.decode(jsonVal) : jsonVal)
        : null;
  }

  void registerConverter<T>(JsonConverter<dynamic, T> transformer) {
    _converters[T.toString()] = transformer;
  }

  dynamic applyFromInstanceConverter<T>(T value,
      [JsonConverter<dynamic, T> converter]) {
    if (value == null) return value;
    final effectiveConverter =
        converter ?? _converters[T.toString()] as JsonConverter<dynamic, T>;
    return effectiveConverter != null
        ? effectiveConverter.toJson(value)
        : value;
  }

  T applyFromJsonConverter<T>(dynamic value,
      [JsonConverter<dynamic, T> converter]) {
    if (value == null) return value;
    final effectiveConverter =
        converter ?? _converters[T.toString()] as JsonConverter<dynamic, T>;
    return effectiveConverter != null
        ? effectiveConverter.fromJson(value)
        : value;
  }

  // static bool _isPrimitveType<T>() {
  //   return T is bool || T is double || T is int || T is num || T is String;
  // }
}
