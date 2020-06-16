import 'dart:convert';

class JsonObjectMapper<T> {
  const JsonObjectMapper(this.fromJsonMap, this.toJsonMap);

  final T Function(Map<String, dynamic> map) fromJsonMap;
  final Map<String, dynamic> Function(T item) toJsonMap;
}

class JsonMapper {
  static final _mapper = <String, JsonObjectMapper<dynamic>>{};

  static void register<T>(JsonObjectMapper<T> mapper) {
    _mapper[T.toString()] = mapper;
  }

  static String serialize<T>(T item) {
    return json.encode(serializeToMap(item));
  }

  static Map<String, dynamic> serializeToMap<T>(T item) {
    return item != null
        ? (_mapper[T.toString()] as JsonObjectMapper<T>).toJsonMap(item)
        : null;
  }

  static T deserialize<T>(dynamic jsonVal) {
    return jsonVal != null
        ? (_mapper[T.toString()] as JsonObjectMapper<T>)
            .fromJsonMap(jsonVal is String ? json.decode(jsonVal) : jsonVal)
        : null;
  }
}
