import 'package:simple_json_mapper/simple_json_mapper.dart';

import 'account.dart';

class Alias {}

@JObj()
class ExternalAccountAlias = Account with Alias;
