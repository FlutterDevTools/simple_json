import 'package:simple_json_example/test.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';

// @JObj()
class Wrapper<T> {
  Wrapper({required this.data, required this.test});
  final T data;
  final Test test;
}
