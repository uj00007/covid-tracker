import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/ViewContactPerson/view_contact_persons.dart';
import 'package:covid_tracker/screens/addContact/add_contact.dart';
import 'package:covid_tracker/screens/adminHomescreen/admin_homescreen.dart';
import 'package:covid_tracker/screens/homescreen/homescreen.dart';
import 'package:covid_tracker/screens/login/login.dart';
import 'package:covid_tracker/screens/map_screen.dart';
import 'package:covid_tracker/screens/splash/splash.dart';
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
  static Handler _splashScreenHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          SplashScreen());
  static Handler _mapScreen = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          MapScreen(
            key: UniqueKey(),
          ));
  static Handler _loginScreenHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          LoginScreen());
  static Handler _addContactScreenHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AddContactScreen());
  static Handler _viewContactPersonScreenHandler =
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return ViewContactPersonsScreen(
      userId: params['id'][0],
    );
  });

  static void setupRouter() {
    router.define(
      Routes.homeScreenRoute,
      handler: _homeScreenHandler,
    );
    router.define(
      Routes.adminHomeScreenRoute,
      handler: _adminHomeScreenHandler,
    );
    router.define(
      Routes.loginRoute,
      handler: _loginScreenHandler,
    );
    router.define(
      Routes.addContactPersonRoute,
      handler: _addContactScreenHandler,
    );
    router.define(
      '${Routes.viewContactPersons}/:id',
      handler: _viewContactPersonScreenHandler,
    );
    router.define(
      Routes.viewContactPersons,
      handler: _viewContactPersonScreenHandler,
    );
    router.define(
      Routes.mapScreen,
      handler: _mapScreen,
    );
    router.define(Routes.splashRoute, handler: _splashScreenHandler);
  }
}
