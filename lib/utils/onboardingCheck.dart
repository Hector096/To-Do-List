import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCheck {


  //check if the personal is new to app
  static Future<bool> checkOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isNew = prefs.getBool("isNew");
    print(isNew);
    if (isNew != null || isNew == false) {
      return false;
    } else {
      return true;
    }
  }
 // to update onboarding check to false
  static updateOnboardingCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isNew", false);
  }
}
