library simple_json;

import 'package:simple_json/src/json_mapper_builder.dart';

export 'src/json_mapper.dart' show JsonMapper, JsonObjectMapper;
export 'src/annotations.dart' show JsonObject;

JsonMapperBuilder jsonMapperBuilder(_) => const JsonMapperBuilder();
