## 1.2.0 - 12/20/2020
* Update dependencies and support nullability language changes.

## 1.1.8 - 12/20/2020
* Update dependency versions

## 1.1.7 - 10/15/2020
* Fix bug to allow null enum values.

## 1.1.6 - 09/29/2020
* Fix bug with converter types.

## 1.1.5 - 09/29/2020
* Fix list converter types.

## 1.1.4 - 09/29/2020
* Fix list skipped types.

## 1.1.3 - 09/24/2020
* Add support for automatic registration of custom converters that use the `JsonConvert<TFrom, TTo>` class as the super type.

## 1.1.2 - 08/31/2020
* Support `Duration` class serialization.

## 1.1.1 - 07/09/2020
* Bug fix with dynamic type.

## 1.1.0 - 07/09/2020
* Bug fix and keep version in sync.

## 1.0.2 - 07/06/2020
* Fix bug by adding null aware operators.

## 1.0.0 - 07/01/2020
* Fix bugs and remove generic type parameter from the `serialize` and related methods.

## 0.4.4 - 07/01/2020
* Fix generated code that uses `dynamic` type.

## 0.4.3 - 07/01/2020
* Skip `dynamic` type processing.

## 0.4.2 - 07/01/2020
* Add nullable checks to prevent exceptions.

## 0.4.1 - 07/01/2020
* Fix infinite loop bug.

## 0.4.0 - 07/01/2020
* Support list casting for list de-serialization.

## 0.3.5 - 07/01/2020
* Fix bugs with abstract and enum class registrations and importing of implicitly opted enums.

## 0.3.4 - 07/01/2020
* Support `Map` with primitive type arguments.

## 0.3.3 - 07/01/2020
* Fix another bug with missing `unnamedConstructor` for types.

## 0.3.2 - 07/01/2020
* Fix bug with missing `unnamedConstructor` for types.

## 0.3.1 - 07/01/2020
* Fix bug with non-dart library file causing no output.

## 0.3.0 - 07/01/2020
* Fix generator failure when a non-dart library file is found.
* Use explicit types for generated serialization code.

## 0.2.6 - 06/28/2020
* Fix bug with nested implicitly opted types

## 0.2.5 - 06/28/2020
* Ignore external alias type when revealing other supertype.

## 0.2.4 - 06/28/2020
* Added external type serialization support.

## 0.2.3 - 06/28/2020
* Fix bug with `EnumValue` annotation.

## 0.2.2 - 06/24/2020
* Update README. 

## 0.2.1 - 06/24/2020
* Update README. 

## 0.2.0 - 06/24/2020
* Add support for custom json mappers, converters, and super classes.
* Edge case bug fixes.

## 0.1.5 - 06/21/2020
* Update README.

## 0.1.4 - 06/21/2020
* Update README.

## 0.1.3 - 06/21/2020
* Update README links.

## 0.1.2 - 06/21/2020
* Update README links.

## 0.1.1 - 06/21/2020
* Update README and unannotated, linked class warning message.

## 0.1.0 - 06/20/2020
* Initial release.
