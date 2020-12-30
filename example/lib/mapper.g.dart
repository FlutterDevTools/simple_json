// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated and consumed by 'simple_json' 

import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:simple_json_example/product.dart';
import 'package:simple_json_example/test.dart';
import 'package:simple_json_example/account.dart';
import 'package:simple_json_example/converters/regex.dart';
import 'package:simple_json_example/converters/special_datetime.dart';
import 'package:simple_json_example/converters/uri.dart';

final _productMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => Product(
    name: mapper.applyFromJsonConverter(json['name']),
    type: mapper.applyFromJsonConverter(ProductType.values.firstWhere(
        (item) => item.toString().split('.')[1].toLowerCase() == json['type']?.toLowerCase(),
        orElse: () => null)),
    expiry: mapper.applyFromJsonConverter(json['expiry']),
    productDetails: mapper.applyFromJsonConverter(json['productDetails']),
    sizes: (json['sizes'] as List)?.cast<double>()?.map((item) => mapper.applyFromJsonConverter<double>(item))?.toList(),
    tests: (json['tests'] as List)?.cast<Map<String, dynamic>>()?.map((item) => mapper.deserialize<Test>(item))?.toList(),
    productMatchPattern: mapper.applyFromJsonConverter(json['productMatchPattern']),
    attributes: (json['attributes'] as Map<String, dynamic>)?.cast<String, String>(),
    parent: mapper.deserialize<Product>(json['parent'] as Map<String, dynamic>),
    timeline: (json['timeline'] as List)?.map((dynamic item) => mapper.applyFromJsonConverter<DateTime>(item))?.toList(),
  ),
  (CustomJsonMapper mapper, Product instance) => <String, dynamic>{
    'name': mapper.applyFromInstanceConverter(instance.name),
    'type': mapper.applyFromInstanceConverter(instance.type?.toString()?.split('.')?.elementAt(1)),
    'expiry': mapper.applyFromInstanceConverter(instance.expiry),
    'productDetails': mapper.applyFromInstanceConverter(instance.productDetails),
    'sizes': mapper.applyFromInstanceConverter(instance.sizes),
    'tests': instance.tests?.map((item) => mapper.serializeToMap(item))?.toList(),
    'productMatchPattern': mapper.applyFromInstanceConverter(instance.productMatchPattern),
    'attributes': mapper.applyFromInstanceConverter(instance.attributes),
    'parent': mapper.serializeToMap(instance.parent),
    'timeline': instance.timeline?.map<dynamic>((item) => mapper.applyFromInstanceConverter(item))?.toList(),
  },
);


final _nestedtestMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => NestedTest(
    ze: mapper.applyFromJsonConverter(json['ze']),
    data: mapper.applyFromJsonConverter<dynamic>(json['data']),
  ),
  (CustomJsonMapper mapper, NestedTest instance) => <String, dynamic>{
    'ze': mapper.applyFromInstanceConverter(instance.ze),
    'data': mapper.applyFromInstanceConverter<dynamic>(instance.data),
  },
);


final _jsonapiresponseMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => JsonApiResponse(
    errorData: mapper.applyFromJsonConverter<dynamic>(json['errorData']),
    errorMessage: mapper.applyFromJsonConverter(json['errorMessage']),
    fieldErrors: (json['fieldErrors'] as List)?.cast<Map<String, dynamic>>()?.map((item) => mapper.deserialize<FieldKeyValuePair>(item))?.toList(),
    data: mapper.applyFromJsonConverter<dynamic>(json['data']),
  ),
  (CustomJsonMapper mapper, JsonApiResponse instance) => <String, dynamic>{
    'errorData': mapper.applyFromInstanceConverter<dynamic>(instance.errorData),
    'errorMessage': mapper.applyFromInstanceConverter(instance.errorMessage),
    'fieldErrors': instance.fieldErrors?.map((item) => mapper.serializeToMap(item))?.toList(),
    'data': mapper.applyFromInstanceConverter<dynamic>(instance.data),
  },
);


final _accountMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => Account(
    id: mapper.applyFromJsonConverter(json['id']),
    type: mapper.applyFromJsonConverter(AccountType.values.firstWhere(
        (item) => ({0: 25, 1: 10}[item.index] ?? item.index) == json['type'],
        orElse: () => null)),
    name: mapper.applyFromJsonConverter(json['name']),
    number: mapper.applyFromJsonConverter(json['number']),
    amount: mapper.applyFromJsonConverter(json['amount']),
    transactionCount: mapper.applyFromJsonConverter(json['tranCount']) ?? 11,
    isActive: mapper.applyFromJsonConverter(json['isActive']),
    product: mapper.deserialize<Product>(json['product'] as Map<String, dynamic>),
    refreshFrequeuncy: mapper.applyFromJsonConverter(json['refreshFrequeuncy']),
    ownerType: mapper.applyFromJsonConverter(AccountOwnerType.values.firstWhere(
        (item) => item.toString().split('.')[1].toLowerCase() == json['ownerType']?.toLowerCase(),
        orElse: () => null)),
    closedDate: mapper.applyFromJsonConverter(json['closedDate'], SpecialDateTimeConverter(true)),
    openDate: mapper.applyFromJsonConverter(json['openingDate']),
  ),
  (CustomJsonMapper mapper, Account instance) => <String, dynamic>{
    'id': mapper.applyFromInstanceConverter(instance.id),
    'type': mapper.applyFromInstanceConverter(({0: 25, 1: 10}[instance.type?.index] ?? instance.type?.index)),
    'name': mapper.applyFromInstanceConverter(instance.name),
    'number': mapper.applyFromInstanceConverter(instance.number),
    'amount': mapper.applyFromInstanceConverter(instance.amount),
    'tranCount': mapper.applyFromInstanceConverter(instance.transactionCount ?? 11),
    'isActive': mapper.applyFromInstanceConverter(instance.isActive),
    'product': mapper.serializeToMap(instance.product),
    'refreshFrequeuncy': mapper.applyFromInstanceConverter(instance.refreshFrequeuncy),
    'ownerType': mapper.applyFromInstanceConverter(instance.ownerType?.toString()?.split('.')?.elementAt(1)),
    'closedDate': mapper.applyFromInstanceConverter(instance.closedDate, SpecialDateTimeConverter(true)),
    'openingDate': mapper.applyFromInstanceConverter(instance.openDate),
  },
);



final _testMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => Test(
    name: mapper.applyFromJsonConverter(json['name']),
    nestedTest: mapper.deserialize<NestedTest>(json['nestedTest'] as Map<String, dynamic>),
  ),
  (CustomJsonMapper mapper, Test instance) => <String, dynamic>{
    'name': mapper.applyFromInstanceConverter(instance.name),
    'nestedTest': mapper.serializeToMap(instance.nestedTest),
  },
);


final _fieldkeyvaluepairMapper = JsonObjectMapper(
  (CustomJsonMapper mapper, Map<String, dynamic> json) => FieldKeyValuePair(
    key: mapper.applyFromJsonConverter(json['key']),
    value: mapper.applyFromJsonConverter(json['value']),
  ),
  (CustomJsonMapper mapper, FieldKeyValuePair instance) => <String, dynamic>{
    'key': mapper.applyFromInstanceConverter(instance.key),
    'value': mapper.applyFromInstanceConverter(instance.value),
  },
);



void init() {
  JsonMapper.register(_productMapper);
  JsonMapper.register(_nestedtestMapper);
  JsonMapper.register(_jsonapiresponseMapper);
  JsonMapper.register(_accountMapper);
  JsonMapper.register(_testMapper);
  JsonMapper.register(_fieldkeyvaluepairMapper); 

  JsonMapper.registerConverter(RegExpConverter());
  JsonMapper.registerConverter(SpecialDateTimeConverter());
  JsonMapper.registerConverter(UriConverter());

  JsonMapper.registerListCast((value) => value?.cast<Product>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<NestedTest>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<JsonApiResponse>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<Account>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<ProductType>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<Test>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<FieldKeyValuePair>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<AccountType>()?.toList());
  JsonMapper.registerListCast((value) => value?.cast<AccountOwnerType>()?.toList());
}
    