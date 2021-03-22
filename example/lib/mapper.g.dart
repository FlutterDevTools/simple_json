// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated and consumed by 'simple_json' 

import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/product.dart';
import 'package:simple_json_example/test.dart';
import 'package:simple_json_example/account.dart';
import 'dart:core';
import 'package:simple_json_example/converters/regex.dart';
import 'package:simple_json_example/converters/special_datetime.dart';
import 'package:simple_json_example/converters/uri.dart';

final _productMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => Product(
    name: mapper.applyDynamicFromJsonConverter(json['name'])!,
    type: mapper.applyDynamicFromJsonConverter(ProductType.values.cast<ProductType?>().firstWhere(
        (value) => value!.toString().split('.').elementAt(1).toLowerCase() == json['type'].toLowerCase(),
        orElse: () => null)),
    expiry: mapper.applyDynamicFromJsonConverter(json['expiry'])!,
    productDetails: mapper.applyDynamicFromJsonConverter(json['productDetails'])!,
    sizes: (json['sizes'] as List?)?.cast<double>().map((item) => mapper.applyDynamicFromJsonConverter<double>(item)!).toList(),
    tests: (json['tests'] as List).cast<Map<String, dynamic>>().map((item) => mapper.deserialize<Test>(item)!).toList(),
    productMatchPattern: mapper.applyDynamicFromJsonConverter(json['productMatchPattern'])!,
    attributes: (json['attributes'] as Map<String, dynamic>).cast<String, String>(),
    parent: mapper.deserialize<Product>(json['parent'] as Map<String, dynamic>?),
    timeline: (json['timeline'] as List?)?.map((dynamic item) => mapper.applyDynamicFromJsonConverter<DateTime>(item)!).toList(),
  ),
  (CustomJsonMapper mapper, Product instance) => <String, dynamic>{
    'name': mapper.applyDynamicFromInstanceConverter(instance.name),
    'type': mapper.applyDynamicFromInstanceConverter(instance.type?.toString().split('.').elementAt(1)),
    'expiry': mapper.applyDynamicFromInstanceConverter(instance.expiry),
    'productDetails': mapper.applyDynamicFromInstanceConverter(instance.productDetails),
    'sizes': mapper.applyDynamicFromInstanceConverter(instance.sizes),
    'tests': instance.tests.map((item) => mapper.serializeToMap(item)).toList(),
    'productMatchPattern': mapper.applyDynamicFromInstanceConverter(instance.productMatchPattern),
    'attributes': mapper.applyDynamicFromInstanceConverter(instance.attributes),
    'parent': mapper.serializeToMap(instance.parent),
    'timeline': instance.timeline?.map<dynamic>((item) => mapper.applyDynamicFromInstanceConverter(item)).toList(),
  },
);


final _basetestMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => BaseTest(
    name: mapper.applyDynamicFromJsonConverter(json['name'])!,
    nestedTest: mapper.deserialize<NestedTest>(json['nestedTest'] as Map<String, dynamic>)!,
  ),
  (CustomJsonMapper mapper, BaseTest instance) => <String, dynamic>{
    'name': mapper.applyDynamicFromInstanceConverter(instance.name),
    'nestedTest': mapper.serializeToMap(instance.nestedTest),
  },
);


final _testMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => Test(
    name: mapper.applyDynamicFromJsonConverter(json['name'])!,
    nestedTest: mapper.deserialize<NestedTest>(json['nestedTest'] as Map<String, dynamic>)!,
    extraProp: mapper.applyDynamicFromJsonConverter(json['extraProp']),
  ),
  (CustomJsonMapper mapper, Test instance) => <String, dynamic>{
    'name': mapper.applyDynamicFromInstanceConverter(instance.name),
    'nestedTest': mapper.serializeToMap(instance.nestedTest),
    'extraProp': mapper.applyDynamicFromInstanceConverter(instance.extraProp),
  },
);


final _nestedtestMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => NestedTest(
    ze: mapper.applyDynamicFromJsonConverter(json['ze'])!,
    data: mapper.applyDynamicFromJsonConverter<dynamic>(json['data']),
  ),
  (CustomJsonMapper mapper, NestedTest instance) => <String, dynamic>{
    'ze': mapper.applyDynamicFromInstanceConverter(instance.ze),
    'data': mapper.applyDynamicFromInstanceConverter<dynamic>(instance.data),
  },
);


final _jsonapiresponseMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => JsonApiResponse(
    errorData: mapper.applyDynamicFromJsonConverter<dynamic>(json['errorData']),
    errorMessage: mapper.applyDynamicFromJsonConverter(json['errorMessage'])!,
    fieldErrors: (json['fieldErrors'] as List).cast<Map<String, dynamic>>().map((item) => mapper.deserialize<FieldKeyValuePair>(item)!).toList(),
    data: mapper.applyDynamicFromJsonConverter<dynamic>(json['data']),
  ),
  (CustomJsonMapper mapper, JsonApiResponse instance) => <String, dynamic>{
    'errorData': mapper.applyDynamicFromInstanceConverter<dynamic>(instance.errorData),
    'errorMessage': mapper.applyDynamicFromInstanceConverter(instance.errorMessage),
    'fieldErrors': instance.fieldErrors.map((item) => mapper.serializeToMap(item)).toList(),
    'data': mapper.applyDynamicFromInstanceConverter<dynamic>(instance.data),
  },
);


final _accountMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => Account(
    id: mapper.applyDynamicFromJsonConverter(json['id'])!,
    type: mapper.applyDynamicFromJsonConverter(AccountType.values.cast<AccountType?>().firstWhere(
        (value) => value!.index == json['type'],
        orElse: () => null))!,
    features: (json['features'] as List).map((dynamic item) => mapper.applyDynamicFromJsonConverter<AccountFeature>(AccountFeature.values.cast<AccountFeature?>().firstWhere(
        (value) => value!.toString().split('.').elementAt(1).toLowerCase() == item?.toString().toLowerCase(),
        orElse: () => null))!).toList(),
    name: mapper.applyDynamicFromJsonConverter(json['name']),
    number: mapper.applyDynamicFromJsonConverter(json['number'])!,
    amount: mapper.applyDynamicFromJsonConverter(json['amount'])!,
    transactionCount: mapper.applyDynamicFromJsonConverter(json['tranCount'])!,
    isActive: mapper.applyDynamicFromJsonConverter(json['isActive'])!,
    product: mapper.deserialize<Product>(json['product'] as Map<String, dynamic>)!,
    refreshFrequeuncy: mapper.applyDynamicFromJsonConverter(json['refreshFrequeuncy']) ?? const Duration(minutes: 30),
    ownerType: mapper.applyDynamicFromJsonConverter(AccountOwnerType.values.cast<AccountOwnerType?>().firstWhere(
        (value) => value!.toString().split('.').elementAt(1).toLowerCase() == json['ownerType'].toLowerCase(),
        orElse: () => null))!,
    closedDate: mapper.applyDynamicFromJsonConverter(json['closedDate'], SpecialDateTimeConverter(true))!,
    openDate: mapper.applyDynamicFromJsonConverter(json['openingDate'])!,
  ),
  (CustomJsonMapper mapper, Account instance) => <String, dynamic>{
    'id': mapper.applyDynamicFromInstanceConverter(instance.id),
    'type': mapper.applyDynamicFromInstanceConverter(instance.type.index),
    'features': instance.features.map((item) => item.toString().split('.').elementAt(1)).toList(),
    'name': mapper.applyDynamicFromInstanceConverter(instance.name),
    'number': mapper.applyDynamicFromInstanceConverter(instance.number),
    'amount': mapper.applyDynamicFromInstanceConverter(instance.amount),
    'tranCount': mapper.applyDynamicFromInstanceConverter(instance.transactionCount),
    'isActive': mapper.applyDynamicFromInstanceConverter(instance.isActive),
    'product': mapper.serializeToMap(instance.product),
    'refreshFrequeuncy': mapper.applyDynamicFromInstanceConverter(instance.refreshFrequeuncy),
    'ownerType': mapper.applyDynamicFromInstanceConverter(instance.ownerType.toString().split('.').elementAt(1)),
    'closedDate': mapper.applyDynamicFromInstanceConverter(instance.closedDate, SpecialDateTimeConverter(true)),
    'openingDate': mapper.applyDynamicFromInstanceConverter(instance.openDate),
  },
);



final _fieldkeyvaluepairMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => FieldKeyValuePair(
    key: mapper.applyDynamicFromJsonConverter(json['key'])!,
    value: mapper.applyDynamicFromJsonConverter(json['value'])!,
  ),
  (CustomJsonMapper mapper, FieldKeyValuePair instance) => <String, dynamic>{
    'key': mapper.applyDynamicFromInstanceConverter(instance.key),
    'value': mapper.applyDynamicFromInstanceConverter(instance.value),
  },
);





void init() {
  JsonMapper.register(_productMapper);
  JsonMapper.register(_basetestMapper);
  JsonMapper.register(_testMapper);
  JsonMapper.register(_nestedtestMapper);
  JsonMapper.register(_jsonapiresponseMapper);
  JsonMapper.register(_accountMapper);
  JsonMapper.register(_fieldkeyvaluepairMapper); 

  JsonMapper.registerConverter(RegExpConverter());
  JsonMapper.registerConverter(SpecialDateTimeConverter());
  JsonMapper.registerConverter(UriConverter());

  JsonMapper.registerListCast((value) => value?.cast<Product>().toList());
  JsonMapper.registerListCast((value) => value?.cast<BaseTest>().toList());
  JsonMapper.registerListCast((value) => value?.cast<Test>().toList());
  JsonMapper.registerListCast((value) => value?.cast<NestedTest>().toList());
  JsonMapper.registerListCast((value) => value?.cast<JsonApiResponse>().toList());
  JsonMapper.registerListCast((value) => value?.cast<Account>().toList());
  JsonMapper.registerListCast((value) => value?.cast<ProductType>().toList());
  JsonMapper.registerListCast((value) => value?.cast<FieldKeyValuePair>().toList());
  JsonMapper.registerListCast((value) => value?.cast<AccountType>().toList());
  JsonMapper.registerListCast((value) => value?.cast<AccountFeature>().toList());
  JsonMapper.registerListCast((value) => value?.cast<List>().toList());
  JsonMapper.registerListCast((value) => value?.cast<AccountOwnerType>().toList());
}
    