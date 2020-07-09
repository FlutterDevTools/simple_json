import 'dart:convert';

import 'package:simple_json_mapper/simple_json_mapper.dart';

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
  static bool isMapperRegistered<T>() => _instance.isMapperRegistered<T>();
  static bool isConverterRegistered<T>() =>
      _instance.isConverterRegistered<T>();

  static void register<T>(JsonObjectMapper<T> mapper) =>
      _instance.register(mapper);

  static void registerListCast<T>(ListCastFunction<T> castFn) =>
      _instance.registerListCast(castFn);

  static String serialize(Object item) => _instance.serialize(item);

  static Map<String, dynamic> serializeToMap<T>(T item) =>
      _instance.serializeToMap(item);

  static T deserialize<T>(dynamic jsonVal) => _instance.deserialize(jsonVal);

  static T deserializeFromMap<T>(dynamic jsonVal) =>
      _instance.deserializeFromMap(jsonVal);

  static void registerConverter<T>(JsonConverter<dynamic, T> transformer) =>
      _instance.registerConverter(transformer);
}

typedef ListCastFunction<T> = List<T> Function(List<dynamic> list);

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
  static final _listCasts = <String, ListCastFunction>{};

  final _converters = <String, JsonConverter<dynamic, dynamic>>{
    (DateTime).toString(): const DefaultISO8601DateConverter(),
  };

  bool isMapperRegistered<T>() {
    return _isMapperRegisteredByType(T.toString());
  }

  bool _isMapperRegisteredByType(String type) {
    return _mapper.containsKey(type);
  }

  bool isConverterRegistered<T>() {
    return _isConverterRegisteredByType(T.toString());
  }

  bool _isConverterRegisteredByType(String type) {
    return _converters.containsKey(type);
  }

  void register<T>(JsonObjectMapper<T> mapper) {
    _mapper[T.toString()] = mapper;
  }

  void registerListCast<T>(ListCastFunction<T> castFn) {
    _listCasts[_typeOf<List<T>>()] = castFn;
  }

  String _typeOf<T>() {
    return T.toString();
  }

  String serialize(Object item) {
    if (item == null) return null;
    final typeName = item.runtimeType.toString();
    return json.encode(_isListWithType(typeName)
        ? (item as List)
            .map((i) => _serializeToMapWithType(typeName, i))
            .toList()
        : serializeToMap(item));
  }

  Map<String, dynamic> serializeToMap(Object item) {
    if (item == null) return null;
    final typeName = item.runtimeType.toString();
    return _serializeToMapWithType(typeName, item);
  }

  Map<String, dynamic> _serializeToMapWithType(String typeName, Object item) {
    if (item == null) return null;
    final typeMap = _getTypeMapWithType(typeName) as dynamic;
    return typeMap?.toJsonMap(this, item);
  }

  T deserialize<T>(dynamic jsonVal) {
    if (jsonVal == null) return null;
    final decodedJson = jsonVal is String ? json.decode(jsonVal) : jsonVal;
    final isList = _isList<T>();
    assert(!isList || (isList && decodedJson is List));
    if (isList) {
      final listCastFn = _listCasts[T.toString()];
      assert(listCastFn != null);
      final deserializedList = (decodedJson as List)
          .map((json) => _deserializeFromMapWithType(T.toString(), json))
          .toList();
      return listCastFn(deserializedList) as T;
    }

    return deserializeFromMap(decodedJson);
  }

  T deserializeFromMap<T>(dynamic jsonVal) {
    return _deserializeFromMapWithType(T.toString(), jsonVal) as T;
  }

  dynamic _deserializeFromMapWithType(String typeName, dynamic jsonVal) {
    final typeMap = _getTypeMapWithType(typeName) as dynamic;
    return jsonVal != null ? typeMap?.fromJsonMap(this, jsonVal) : null;
  }

  static const _ListNameTypeMarker = 'List<';

  bool _isList<T>() {
    return _isListWithType(T.toString());
  }

  bool _isListWithType(String typeName) {
    return typeName.startsWith(_ListNameTypeMarker);
  }

  JsonObjectMapper<dynamic> _getTypeMap<T>() {
    var typeName = T.toString();
    final isList = _isList<T>();
    return isList
        ? _getTypeMapWithType(typeName)
        : _getTypeMapWithType(typeName) as JsonObjectMapper<T>;
  }

  JsonObjectMapper<dynamic> _getTypeMapWithType(String originalTypeName) {
    final typeName = _getTypeNameWithName(originalTypeName);
    final typeMap = _mapper[typeName];
    assert(typeMap != null, 'The type ${typeName} is not registered.');
    return typeMap;
  }

  String _getTypeName<T>() {
    var typeName = T.toString();
    return _getTypeNameWithName(typeName);
  }

  String _getTypeNameWithName(String typeName) {
    final isList = _isListWithType(typeName);
    if (isList) {
      typeName =
          typeName.substring(_ListNameTypeMarker.length, typeName.length - 1);
    }
    return typeName;
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
