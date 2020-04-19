import 'package:covid_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null)
      Navigator.of(context).pushNamed(Routes.homeScreenRoute);
    else
      Navigator.of(context).pushNamed(Routes.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Color(0xff1e252c),
        child: Image.asset(
          'assets/images/Untitled_Artwork.png',
          alignment: Alignment.center,
          fit: BoxFit.scaleDown,
          height: 100,
        ),
      ),
    );
  }
}
