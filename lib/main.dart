import 'package:covid_tracker/routing/router.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:flutter/material.dart';

void main() {
  FluroRouter.setupRouter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid Tracker',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      initialRoute: Routes.splashRoute,
      onGenerateRoute: FluroRouter.router.generator,
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
