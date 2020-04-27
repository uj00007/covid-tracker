import 'dart:convert';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hawkeye_app/screens/drawer/drawer_controller.dart';

class DrawerWidget extends StatefulWidget {
  final BuildContext context;

  DrawerWidget({this.context});

  _DrawerWidgetState createState() => new _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool switchEvent;
  // SharedPreferenceService utilities = locator<SharedPreferenceService>();
  SideDrawerController _drawerController = SideDrawerController();
  String version = '';

  @override
  void initState() {
    super.initState();
    getUser();
    compareAppVersion();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null) {
      _drawerController.user = User.fromJson(json.decode(stringValue), '');
      // _drawerController.widgetBuilder();
      this.setState(() {});
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushNamed(Routes.loginRoute);
  }

  compareAppVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    // print('versionCode: $versionCode');
    // print('buildNumber: ${info.buildNumber}');
    this.setState(() {
      this.version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    _drawerController.drawerContext = context;
    _drawerController.widgetClear();
    _drawerController.widgetBuilder();

    // utilities.getInstance();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
        width: width / 1.5,
        height: height,
        decoration: BoxDecoration(
            color: CommonColors.offPurple,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0))),
        child: Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          direction: Axis.vertical,
          children: <Widget>[
            // Expanded(
            //   flex: 3,
            //   child: Container(
            //     decoration: BoxDecoration(
            //         color: CommonColors.tilePurple,
            //         borderRadius: BorderRadius.only(
            //           topRight: Radius.circular(16),
            //         )),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: <Widget>[
            //         Container(
            //           // height: 200,
            //           child: Image.asset(
            //             'assets/images/splash.png',
            //             alignment: Alignment.center,
            //             fit: BoxFit.fitWidth,
            //             // height: 100,
            //             // width: 100,
            //             scale: 20,
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            Column(
              children: <Widget>[
                Container(
                    child: Image.asset(
                  'assets/images/splash.png',
                  alignment: Alignment.center,
                  // fit: BoxFit.contain,
                  // height: 100,
                  width: MediaQuery.of(context).size.width,
                  // scale: 20,
                )),
                _drawerController.user != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Icon(
                              Icons.person,
                              color: CommonColors.grey,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                _drawerController.user.name,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                _drawerController.user.emailId,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox()
              ],
            ),
            Expanded(
              flex: 11,
              child: Container(
                width: width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                )),
                child:
                    //  Container()
                    Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ..._drawerController.drawersectionwidgets,
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () => logout(),
                      child: Container(
                        child: Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Version: ${this.version}',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                          color: CommonColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
