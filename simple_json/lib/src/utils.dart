class Utils {
  static List<T> dedupe<T>(List<T> items) {
    return [...Set()..addAll(items)];
  }

  static String enumToString<T>(T enumVal) {
    return enumVal.toString().split('.')[1];
  }
}
