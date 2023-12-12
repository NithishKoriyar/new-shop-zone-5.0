
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopzone/foodSeller/assistantMethods/food_seller_cart_methods.dart';



SharedPreferences? sharedPreferences;
CartMethods cartMethods = CartMethods();
String previousEarning = "";
String fcmServerToken = "key=AAAAzMdWIus:APA91bHAqLTUqTY3Udd141mCbaNVrJPqZKIiyG2voba8QS5ZgO4ZiuVwBYrCkf3xNQKlR74tCNVcMMiWPbjfNDdMF7P4X-Lb__b9X8YmCplV2nPLBtwdK771e4Zdrq2hKeZa6r6m-TRa";