import 'package:simple_json_mapper/simple_json_mapper.dart';

import 'account.dart';

class Alias {}

// This can be useful for when the types are defined in a package outside of your code.
@JObj()
class ExternalAccountAlias = Account with Alias;
