import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopzone/user/normalUser/assistantMethods/cart_methods.dart';



SharedPreferences? sharedPreferences;

final itemsImagesList =
[
  "slider/0.jpg",
  "slider/1.jpg",
  "slider/2.jpg",
  "slider/3.jpg",
  "slider/4.jpg",
  "slider/5.jpg",
  "slider/6.jpg",
  "slider/7.jpg",
  "slider/8.jpg",
  "slider/9.jpg",
  "slider/10.jpg",
  "slider/11.jpg",
  "slider/12.jpg",
  "slider/13.jpg",
];

CartMethods cartMethods = CartMethods();

double countStarsRating = 0.0;
String titleStarsRating = "";

String fcmServerToken = "key=AAAAa1XgZKs:APA91bGOjNln-fOcthmvGaaUn5pfH9etNORZESpsLvvtvBwfavLZZ0iEz7b9pj2PtbpK2k6u4IKZRCL697S7A3pbQiZ8Ej4BNEhRUhzqoS6HHgJ2quY7R4Plc4TMgszq87GvGq2mVX9E";
