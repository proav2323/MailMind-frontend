import 'package:shared_preferences/shared_preferences.dart';

Future<void> addItem(String key, dynamic value) async {
  var sharedPref = await SharedPreferences.getInstance();

  switch (value.runtimeType) {
    case int:
      await sharedPref.setInt(key, value);
      break;
    case bool:
      await sharedPref.setBool(key, value);
      break;
    case double:
      await sharedPref.setDouble(key, value);
      break;
    case String:
      await sharedPref.setString(key, value);
      break;
    default:
      print("You cannot set other types to Shared Preferance");
  }
}

Future<void> deleteItem(String key) async {
  var sharedPref = await SharedPreferences.getInstance();
  await sharedPref.remove(key);
}

Future<Object?> getItem(String key) async {
  var sharedPref = await SharedPreferences.getInstance();
  Object? data = sharedPref.get(key);
  return data;
}
