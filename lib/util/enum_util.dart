class EnumUtil {
  static String nameOf(Object? o) => o.toString().split('.').last;
  static T? valueOf<T>(List<T> values, String? value) {
    if(value == null)
      return null;
    return values.firstWhere((element) => nameOf(element) == value, orElse: null);
  }
}