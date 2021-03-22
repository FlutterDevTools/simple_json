import 'dart:convert';

import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_mapper/src/converters/duration.dart';

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
  static bool verbose = false;
  static CustomJsonMapper _instance = CustomJsonMapper(verbose: verbose);
  static bool isMapperRegistered<T>() => _instance.isMapperRegistered<T>();
  static bool isConverterRegistered<T>() =>
      _instance.isConverterRegistered<T>();

  static void register<T>(JsonObjectMapper<T> mapper) =>
      _instance.register(mapper);

  static void registerListCast<T>(ListCastFunction<T> castFn) =>
      _instance.registerListCast(castFn);

  static String? serialize<T>(T item) => _instance.serialize<T>(item);

  static Map<String, dynamic>? serializeToMap<T>(T? item) =>
      _instance.serializeToMap<T>(item);

  static T? deserialize<T>(dynamic jsonVal, [String? typeName]) =>
      _instance.deserialize<T>(jsonVal, typeName);

  static T? deserializeFromMap<T>(dynamic jsonVal, [String? typeName]) =>
      _instance.deserializeFromMap<T>(jsonVal, typeName);

  static void registerConverter<TFrom, TTo>(
          JsonConverter<TFrom, TTo> transformer) =>
      _instance.registerConverter<TFrom, TTo>(transformer);
}

typedef ListCastFunction<T> = List<T>? Function(List<dynamic>? list);

class CustomJsonMapper {
  CustomJsonMapper({this.verbose = false, List<JsonConverter>? converters}) {
    if (converters != null)
      _toTypeConverterMap
          .addAll(converters.fold(<String, JsonConverter>{}, (map, converter) {
        map[converter.toType] = converter;
        return map;
      }));
  }

  final bool verbose;

  static final _mapper = <String, JsonObjectMapper<dynamic>>{};
  static final _listCasts = <String, ListCastFunction>{};

  final _toTypeConverterMap = <String, JsonConverter>{
    (DateTime).toString(): const DefaultISO8601DateConverter(),
    (Duration).toString(): const DefaultDurationConverter(),
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

  bool _isConverterRegisteredByType(String toType) {
    return _toTypeConverterMap.containsKey(toType);
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

  String? serialize<T>(T? item) {
    if (item == null) return null;
    final typeName = item.runtimeType.toString();
    if (verbose) print(typeName);
    return json.encode(_isListWithType(typeName)
        ? (item as List)
            .map((i) => _serializeToMapWithType(typeName, i))
            .toList()
        : serializeToMap<T>(item));
  }

  Map<String, dynamic>? serializeToMap<T>(T? item) {
    if (item == null) return null;
    final typeName = item.runtimeType.toString();
    return _serializeToMapWithType<T>(typeName, item);
  }

  Map<String, dynamic>? _serializeToMapWithType<T>(String typeName, T? item) {
    if (item == null) return null;
    final typeMap = _getTypeMapWithType<T>(typeName) as dynamic;
    if (verbose) print(typeMap);
    return typeMap?.toJsonMap(this, item);
  }

  T? deserialize<T>(dynamic jsonVal, [String? typeName]) {
    if (jsonVal == null) return null;
    final decodedJson = jsonVal is String ? json.decode(jsonVal) : jsonVal;
    final isList = _isList<T>(typeName);
    assert(!isList || (isList && decodedJson is List));
    if (isList) {
      final listCastFn = _listCasts[typeName ?? T.toString()];
      assert(listCastFn != null);
      final deserializedList = (decodedJson as List)
          .map((json) =>
              _deserializeFromMapWithType(typeName ?? T.toString(), json))
          .toList();
      return listCastFn != null ? listCastFn(deserializedList) as T : null;
    }

    return deserializeFromMap(decodedJson, typeName);
  }

  T? deserializeFromMap<T>(dynamic jsonVal, [String? typeName]) {
    return _deserializeFromMapWithType(typeName ?? T.toString(), jsonVal) as T?;
  }

  T? _deserializeFromMapWithType<T>(String typeName, dynamic jsonVal) {
    final typeMap = _getTypeMapWithType<T>(typeName);
    return jsonVal != null ? typeMap?.fromJsonMap(this, jsonVal) : null;
  }

  static const _ListNameTypeMarker = 'List<';
  static const _ArrayNameTypeMarker = 'Array<';

  bool _isList<T>([String? typeName]) {
    return _isListWithType(typeName ?? T.toString());
  }

  bool _isListWithType(String typeName) {
    return typeName.contains(_ListNameTypeMarker) ||
        typeName.contains(_ArrayNameTypeMarker);
  }

  // JsonObjectMapper<T>? _getTypeMap<T>() {
  //   var typeName = T.toString();
  //   final isList = _isList<T>();
  //   return isList
  //       ? _getTypeMapWithType<T>(typeName)
  //       : _getTypeMapWithType<T>(typeName) as JsonObjectMapper<T>;
  // }

  JsonObjectMapper<T>? _getTypeMapWithType<T>(String originalTypeName) {
    final typeName = _getInnerTypeFromName(originalTypeName);
    final typeMap = _mapper[typeName] as JsonObjectMapper<T>?;
    assert(typeMap != null, 'The type ${typeName} is not registered.');
    return typeMap;
  }

  // String _getTypeName<T>() {
  //   var typeName = T.toString();
  //   return _getInnerTypeFromName(typeName);
  // }

  String _getInnerTypeFromName(String typeName) {
    final isList = _isListWithType(typeName);
    if (isList) {
      var index;
      if (typeName.contains(_ListNameTypeMarker))
        index =
            typeName.indexOf(_ListNameTypeMarker) + _ListNameTypeMarker.length;
      else if (typeName.contains(_ArrayNameTypeMarker))
        index = typeName.indexOf(_ArrayNameTypeMarker) +
            _ArrayNameTypeMarker.length;

      if (index != null)
        typeName = typeName.substring(index, typeName.length - 1);
    }
    return typeName;
  }

  void registerConverter<TFrom, TTo>(JsonConverter<TFrom, TTo> transformer) {
    _toTypeConverterMap[TTo.toString()] = transformer;
  }

  TFrom? applyFromInstanceConverter<TFrom, TTo>(TTo value,
      [JsonConverter<TFrom, TTo>? converter]) {
    if (value == null) return null;
    final effectiveConverter = converter ?? _toTypeConverterMap[TTo.toString()];
    return effectiveConverter != null
        ? effectiveConverter.toJson(value)
        : value;
  }

  dynamic? applyDynamicFromInstanceConverter<TTo>(TTo value,
      [JsonConverter<dynamic, TTo>? converter]) {
    return applyFromInstanceConverter(value, converter);
  }

  TTo? applyFromJsonConverter<TFrom, TTo>(TFrom value,
      [JsonConverter<TFrom, TTo>? converter]) {
    if (value == null) return null;
    final effectiveConverter = converter ?? _toTypeConverterMap[TTo.toString()];
    return effectiveConverter != null
        ? effectiveConverter.fromJson(value)
        : value;
  }

  TTo? applyDynamicFromJsonConverter<TTo>(dynamic value,
      [JsonConverter<dynamic, TTo>? converter]) {
    return applyFromJsonConverter(value, converter);
  }

  // static bool _isPrimitveType<T>() {
  //   return T is bool || T is double || T is int || T is num || T is String;
  // }
}
