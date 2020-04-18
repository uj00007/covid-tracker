import 'package:covid_tracker/screens/admin_homescreen.dart';
import 'package:covid_tracker/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class FluroRouter {
  static Router router = Router();
  static Handler _homeScreenHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          HomeScreen());
  static Handler _adminHomeScreenHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminHomeScreen());
  static void setupRouter() {
    router.define(
      'homescreen',
      handler: _homeScreenHandler,
    );
    router.define(
      'adminhomescreen',
      handler: _adminHomeScreenHandler,
    );
  }
}
