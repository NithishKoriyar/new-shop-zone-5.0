//here it save the user as currentUser and remember it
//so easily so simple
import 'package:get/get.dart';
import 'package:shopzone/rider/ridersPreferences/riders_preferences.dart';
import '../riders_model/riders_user.dart';
class CurrentRider extends GetxController
{
  Rx<Rider> _currentRider = Rider(0,'','','','','','').obs;

  Rider get rider => _currentRider.value;
// this function as all Riders data we can call when ever we need it
  getUserInfo() async
  {
    Rider? getRiderInfoFromLocalStorage = await RememberRiderPrefs.readRiderInfo();
    _currentRider.value = getRiderInfoFromLocalStorage!;
  }
}