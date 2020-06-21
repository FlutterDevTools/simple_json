// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated and consumed by 'simple_json' 

import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/account.dart';
import 'package:simple_json_example/product.dart';
import 'package:simple_json_example/test.dart';

final _accountMapper = JsonObjectMapper(
  (Map<String, dynamic> json) => Account(
    type: AccountType.values.firstWhere(
        (item) => ({0: 25, 1: 10}[item.index] ?? item.index) == json['type'],
        orElse: () => null),
    name: json['name'] as String,
    number: json['number'] as String,
    amount: json['amount'] as double,
    transactionCount: (json['tranCount'] ?? 11) as int,
    isActive: json['isActive'] as bool,
    product: JsonMapper.deserialize<Product>(json['product'] as Map<String, dynamic>),
    openDate: DateTime.parse(json['openDate'] as String),
  ),
  (Account instance) => <String, dynamic>{
    'type': ({0: 25, 1: 10}[instance.type.index] ?? instance.type.index),
    'name': instance.name,
    'number': instance.number,
    'amount': instance.amount,
    'tranCount': instance.transactionCount ?? 11,
    'isActive': instance.isActive,
    'product': JsonMapper.serializeToMap(instance.product),
    'openDate': instance.openDate.toIso8601String(),
  },
);


final _productMapper = JsonObjectMapper(
  (Map<String, dynamic> json) => Product(
    name: json['name'] as String,
    expiry: DateTime.parse(json['expiry'] as String),
    sizes: (json['sizes'] as List).cast(),
    tests: (json['tests'] as List).cast<Map<String, dynamic>>().map((item) => JsonMapper.deserialize<Test>(item)).toList(),
  ),
  (Product instance) => <String, dynamic>{
    'name': instance.name,
    'expiry': instance.expiry.toIso8601String(),
    'sizes': instance.sizes,
    'tests': instance.tests.map((item) => JsonMapper.serializeToMap(item)).toList(),
  },
);


final _testMapper = JsonObjectMapper(
  (Map<String, dynamic> json) => Test(
    name: json['name'] as String,
  ),
  (Test instance) => <String, dynamic>{
    'name': instance.name,
  },
);

void init() {
  JsonMapper.register(_accountMapper);
  JsonMapper.register(_productMapper);
  JsonMapper.register(_testMapper); 
}
    