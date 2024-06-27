import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzone/user/foodUser/foodUserAssistantMethods/address_changer.dart';
import 'package:shopzone/user/normalUser/assistantMethods/address_changer.dart';
import 'package:shopzone/user/splashScreen/my_splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();    

  try {
    // Initialize Firebase  ``
    //await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Handle the error e.g., by showing an error message to the user
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => AddressChanger()),
        ChangeNotifierProvider(create: (c) => NormalUserAddressChanger()),
      ],
      child: MaterialApp(
        title: 'Shop Zone',
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
        debugShowCheckedModeBanner: false,
        home: const MySplashScreen(),
        // home: const FoodSellerSplashScreen(),
      ),
    );
  }
}
