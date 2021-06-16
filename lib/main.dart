import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todolist/data/notification.dart';
import 'package:todolist/ui/HomeScreen.dart';
import 'package:todolist/ui/onboardingScreen.dart';
import 'package:todolist/utils/onboardingCheck.dart';
import 'package:todolist/utils/sizeConfig.dart';


bool? onBoardingCheck;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //To persist Orientation to potrait 
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

      //To check onboarding status
       onBoardingCheck = await OnboardingCheck.checkOnboarding();
       
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(builder: (context, orientation) {
          SizeConfig().init(constraints, orientation);
          return MultiProvider(
            providers: [
               ChangeNotifierProvider(create: (_) => NotificationService())
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'To-Do List',
              theme: ThemeData(
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: onBoardingCheck! ? OnboardingScreen() : HomeScreen(),
            ),
          );
        });
      },
    );
  }
}
