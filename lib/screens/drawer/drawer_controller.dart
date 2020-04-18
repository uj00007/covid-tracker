import 'dart:convert';
import 'dart:io';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer_default.dart';
import 'package:covid_tracker/utils/render_image.dart';
import 'package:flutter/material.dart';

class SideDrawerController {
  List<Widget> drawersectionwidgets = [];
  static Map position;
  var activeColor = CommonColors.moderateCyan;
  var inactiveColor = CommonColors.watermelon;
  BuildContext drawerContext;
  // renderProfileSection() {
  //   // var profilePic = utilities.getStringPreference('profilePic') != null &&
  //   //         utilities.getStringPreference('profilePic') != ''
  //   //     ? File(utilities.getStringPreference('profilePic'))
  //   //     : null;
  //   var width =
  //       drawerContext != null ? MediaQuery.of(drawerContext).size.width : 200;
  //   return Container(
  //       width: width / 1.5,
  //       decoration: BoxDecoration(
  //           color: CommonColors.tilePurple,
  //           borderRadius: BorderRadius.only(
  //             topRight: Radius.circular(16),
  //           )),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: <Widget>[
  //           Padding(
  //             padding: const EdgeInsets.only(left: 30.0, top: 20),
  //             child: Row(
  //               children: <Widget>[
  //                 InkWell(
  //                   onTap: () async {
  //                     AppPermission getPermission = AppPermission();
  //                     bool permissionStatus =
  //                         await getPermission.permissionHandler(drawerContext,
  //                             permissionName: 'camera');
  //                     if (permissionStatus) {
  //                       var _selected = await ImagePicker.pickImage(
  //                           source: ImageSource.camera, imageQuality: 50);
  //                       if (_selected != null) {
  //                         await utilities.getInstance();
  //                         utilities.setStringPreference(
  //                             'profilePic', _selected.path);
  //                         profilePic = _selected;
  //                       }
  //                     } else {
  //                       return;
  //                     }
  //                     // Navigator.of(context).pushNamed(Routes.profileScreen);
  //                   },
  //                   child: profilePic != null
  //                       ? Container(
  //                           height: 56,
  //                           width: 56,
  //                           decoration: BoxDecoration(
  //                             color: CommonColors.dullGrey,
  //                             shape: BoxShape.circle,
  //                             image: DecorationImage(
  //                                 fit: BoxFit.cover,
  //                                 image: FileImage(profilePic)),
  //                           ),
  //                         )
  //                       : renderAssetSvg(
  //                           'assets/svg/profile.svg',
  //                           height: 56,
  //                           width: 56,
  //                           fit: BoxFit.cover,
  //                         ),
  //                 ),
  //                 SizedBox(
  //                   width: 16,
  //                 ),
  //                 SizedBox(
  //                   height: getAdjustedSizeHeight(54),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: <Widget>[
  //                       SizedBox(
  //                         height: 22,
  //                         width: getAdjustedSizeWidth(130),
  //                         child: Text(
  //                           user.name ?? CommonStrings.name,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: TextStyle(
  //                               color: CommonColors.white, fontSize: 14.0),
  //                         ),
  //                       ),
  //                       Text(
  //                         user.mobileNumber ?? '',
  //                         style: TextStyle(
  //                             color: CommonColors.grey, fontSize: 14.0),
  //                       ),
  //                       user.userPermissions[UserPermissions.AGENT_RATING]
  //                           ? Row(
  //                               children: <Widget>[
  //                                 Text(
  //                                   user.agentId != null &&
  //                                           user.agentRating != null
  //                                       ? '${user.agentRating.toStringAsFixed(2)}'
  //                                       : '',
  //                                   style: TextStyle(
  //                                       color: CommonColors.grey,
  //                                       fontSize: 14.0),
  //                                 ),
  //                                 renderAssetSvg('assets/svg/star.svg',
  //                                     height: 14, width: 14)
  //                               ],
  //                             )
  //                           : SizedBox(),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ],
  //       ));
  // }

  renderStatusSection() {
    var height =
        drawerContext != null ? MediaQuery.of(drawerContext).size.height : 500;
    return Container(
      height: height * 0.12,
      child: Text('Safe'),
    );
  }

  Widget seperator(context) {
    return Container(
      margin: EdgeInsets.only(right: 0),
      color: Color(0x19eeeeee),
      height: 1.5,
      width: MediaQuery.of(context).size.width / 1.8,
    );
  }

  Widget drawerListTile(String imageLink, String tileText,
      {Function onPressed}) {
    return Center(
      child: InkWell(
        onTap: () {
          onPressed();
        },
        child: ListTile(
          leading: Container(
              padding: EdgeInsets.only(left: 10),
              child: renderAssetSvg(
                imageLink,
                height: 22,
                width: 22,
              )),
          title: Text(
            tileText,
            style: TextStyle(
                color: CommonColors.offwhite,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget drawerListTileWithBorder(String imageLink, String tileText,
      {Function onPressed}) {
    return Center(
      child: InkWell(
          onTap: () {
            onPressed();
          },
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(left: 24, right: 24, bottom: 32),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: Colors.white)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    renderAssetSvg(
                      imageLink,
                      height: 22,
                      width: 22,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        tileText,
                        style: TextStyle(
                            color: CommonColors.offwhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ]))),
    );
  }

  widgetBuilder() {
    // var jsonObj = user.agentManagerDisplay;
    var jsonObj = json.decode(drawerJsonString);
    // var jsonObj = json.decode(agentManagerDisplayDefaultString);
    // print(jsonObj);
    // var agent = user.agentType != null ? user.agentType : AgentType.BOUCE_AGENT;
    var drawerData;
    // if (jsonObj[agent] != null) {
    //   drawerData = jsonObj[agent];
    // } else {
    //   drawerData = jsonObj[AgentType.BOUCE_AGENT];
    // }
    drawerData = jsonObj['user'];
    drawerData['drawer'].forEach((item) {
      getWidgets(item);
    });
  }

  getWidgets(var item) {
    Widget widgetToAdd;
    switch (item['tile']) {
      // case 'PROFILE':
      //   widgetToAdd = renderProfileSection();
      //   break;
      case 'STATUS':
        widgetToAdd = renderStatusSection();
        break;
      case 'FAQ':
        widgetToAdd = drawerListTile('assets/svg/FAQ.svg', 'FAQ',
            onPressed: () =>
                Navigator.of(drawerContext).pushNamed(Routes.faqScreenRoute));
        break;
      case 'HEALTH_CHECKER':
        widgetToAdd = widgetToAdd = drawerListTile('', 'Health Check',
            onPressed: () => Navigator.of(drawerContext)
                .pushNamed(Routes.healthCheckerScreenRoute));
        break;
      case 'TRACKER_HOME':
        widgetToAdd = widgetToAdd = drawerListTile('', 'Tracker Home',
            onPressed: () =>
                Navigator.of(drawerContext).pushNamed(Routes.homeScreenRoute));
        break;

      default:
        widgetToAdd = SizedBox();
        break;
    }
    switch (item['render_section']) {
      // we can add different sections here based on the UI
      case 'DRAWER_SECTION':
        drawersectionwidgets.add(widgetToAdd);
        drawersectionwidgets.add(seperator(drawerContext));

        break;
      default:
        break;
    }
  }

  widgetClear() {
    drawersectionwidgets.clear();
  }
}
