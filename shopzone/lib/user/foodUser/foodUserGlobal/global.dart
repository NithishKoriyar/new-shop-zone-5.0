import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopzone/user/foodUser/foodUserAssistantMethods/cart_methods.dart';

SharedPreferences? sharedPreferences;

final itemsImagesList = [
  "sliderFood/0.jpg",
  "sliderFood/1.jpg",
  "sliderFood/2.jpg",
  "sliderFood/3.jpg",
  "sliderFood/4.jpg",
  "sliderFood/5.jpg",
  "sliderFood/6.jpg",
  "sliderFood/7.jpg",
  "sliderFood/8.jpg",
  "sliderFood/9.jpg",
  "sliderFood/10.jpg",
  "sliderFood/11.jpg",
  "sliderFood/12.jpg",
  "sliderFood/13.jpg",
  "sliderFood/14.jpg",
  "sliderFood/15.jpg",
  "sliderFood/16.jpg",
  "sliderFood/17.jpg",
  "sliderFood/18.jpg",
  "sliderFood/19.jpg",
  "sliderFood/20.jpg",
  "sliderFood/21.jpg",
  "sliderFood/22.jpg",
  "sliderFood/23.jpg",
  "sliderFood/24.jpg",
  "sliderFood/25.jpg",
  "sliderFood/26.jpg",
  "sliderFood/27.jpg",
];

CartMethods cartMethods = CartMethods();

double countStarsRating = 0.0;
String titleStarsRating = "";

String fcmServerToken =
    "key=AAAAa1XgZKs:APA91bGOjNln-fOcthmvGaaUn5pfH9etNORZESpsLvvtvBwfavLZZ0iEz7b9pj2PtbpK2k6u4IKZRCL697S7A3pbQiZ8Ej4BNEhRUhzqoS6HHgJ2quY7R4Plc4TMgszq87GvGq2mVX9E";
