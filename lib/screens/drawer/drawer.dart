import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/screens/drawer/drawer_controller.dart';
import 'package:flutter/material.dart';
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
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                    color: CommonColors.tilePurple,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        // height: 200,
                        )
                  ],
                ),
              ),
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
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ..._drawerController.drawersectionwidgets,
                  ],
                ),
              ),
            ),
            // SizedBox(
            //   height: 20,
            // ),
            // ..._drawerController.lowerSectionwidgets,
          ],
        ));
  }
}
