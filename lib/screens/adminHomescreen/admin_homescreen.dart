import 'dart:convert';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/components/flashing_button.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:covid_tracker/utils/exter_link_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covid_tracker/models/user.dart';

class AdminHomeScreen extends StatefulWidget {
  AdminHomeScreen({Key key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  FirebaseApp app;
  FirebaseDatabase database;
  List users = [];
  int blueCount = 0;
  int redCount = 0;
  int yellowCount = 0;
  bool isLoading = true;
  User user;
  String _name = "";
  Map userMap = {};
  String selectedSorting = "all";

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void setupdatabase() async {
    app = await FirebaseApp.configure(
        name: 'covid-tracker-85a72',
        options: const FirebaseOptions(
            googleAppID: '1:614988993013:android:e03932f4df5f75e28fd0bc',
            apiKey: '614988993013',
            databaseURL: 'https://covid-tracker-85a72.firebaseio.com'));
    database = FirebaseDatabase(app: app);
    getUsers();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null) {
      this.user = User.fromJson(json.decode(stringValue), '');
      setupdatabase();
    }
  }

  getUsers() {
    this.setState(() {
      this.isLoading = true;
    });
    database.reference().child('users').once().then((DataSnapshot snapshot) {
      // print('value ${snapshot.value}');
      if (snapshot.value != null) {
        if (!this.user.isSuperAdmin) {
          List validUsers = [];
          for (var user in snapshot.value) {
            if (user['group_code'] != null &&
                user['email_id'] != this.user.emailId &&
                user['group_code'] == this.user.groupCode) {
              validUsers.add(user);
            }
          }

          this.setState(() {
            this.users = validUsers;
            this.isLoading = false;
          });
        } else {
          this.setState(() {
            this.users = snapshot.value;
            this.isLoading = false;
          });
        }

        getCounts();
      }
    });
  }

  getCounts() {
    var blue = 0, red = 0, yellow = 0;
    this.userMap['all'] = [];
    this.userMap['blue'] = [];

    this.userMap['yellow'] = [];

    this.userMap['red'] = [];

    for (int i = 0; i < this.users.length; i++) {
      this.users[i]["zone"] != null
          ? this.users[i]["zone"] == 'blue'
              ? blue += 1
              : this.users[i]["zone"] == 'yellow' ? yellow += 1 : red += 1
          : this.users[i]["is_safe"] ? blue += 1 : red += 1;

      this.userMap['all'].add(this.users[i]);
      this.users[i]["zone"] != null
          ? this.users[i]["zone"] == 'blue'
              ? this.userMap['blue'].add(this.users[i])
              : this.users[i]["zone"] == 'yellow'
                  ? this.userMap['yellow'].add(this.users[i])
                  : this.userMap['red'].add(this.users[i])
          : this.users[i]["is_safe"]
              ? this.userMap['blue'].add(this.users[i])
              : this.userMap['red'].add(this.users[i]);
    }
    this.setState(() {
      this.blueCount = blue;
      this.redCount = red;
      this.yellowCount = yellow;
    });
  }

  List<Widget> getCards() {
    // print('calleddd cards');
    List<Widget> widgets = [];
    List tempList = userMap[this.selectedSorting];
    for (int i = 0; i < userMap[this.selectedSorting].length; i++) {
      var msg = '';
      msg = tempList[i]["zone"] != null
          ? tempList[i]["zone"] == 'blue'
              ? 'SAFE'
              : tempList[i]["zone"] == 'yellow' ? 'CAUTION' : 'UNSAFE!!'
          : tempList[i]["is_safe"] ? 'SAFE' : 'UNSAFE!!';
      // print(tempList[i]);
      if (tempList[i]["mobile_number"].startsWith(this._name))
        widgets.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(
                '${Routes.viewContactPersons}/${int.parse(tempList[i]["id"].toString())}',
                arguments: {"userId": i}),
            child: Card(
                color: tempList[i]["zone"] != null
                    ? tempList[i]["zone"] == 'blue'
                        ? Colors.blue
                        : tempList[i]["zone"] == 'yellow'
                            ? Colors.yellow
                            : Colors.red
                    : tempList[i]["is_safe"] ? Colors.blue : Colors.red,
                child: Container(
                    // height: 100,
                    padding: EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    tempList[i]["name"] != null
                                        ? tempList[i]["name"]
                                        : '',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w600)),
                                Text('Mob: ${tempList[i]["mobile_number"]}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.normal)),
                                Text(
                                    tempList[i]["email_id"] != null
                                        ? tempList[i]["email_id"]
                                        : '',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                            Container(
                                child: Text(
                              msg,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600),
                            ))
                          ],
                        ),
                        tempList[i]['location'] != null
                            ? InkWell(
                                onTap: () => Navigator.of(context).pushNamed(
                                    '${Routes.userLocationMapView}/${int.parse(tempList[i]["id"].toString())}',
                                    arguments: {"userId": i}),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text('See Location'),
                                      Container(child: Icon(Icons.place)),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox()
                      ],
                    ))),
          ),
        ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () =>
          SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
      child: Scaffold(
        floatingActionButton: Container(
          // alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () => this.getUsers(),
                child: Stack(children: <Widget>[
                  FloatingActionButton(
                    onPressed: () => this.getUsers(),
                    backgroundColor: Colors.red,
                  ),
                  Container(
                      height: 60,
                      width: 50,
                      // color: Colors.red,
                      child: Icon(
                        Icons.refresh,
                        size: 30,
                        color: Colors.white,
                      )),
                ]),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xff2c4260),
          elevation: 0.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('CovidTracker-Admin'),
              FlashingButton(
                onPressed: () => ExternalLink.launchURL(),
                label: 'Live Cases',
                height: 40,
                multiTap: true,
                disabled: false,
                width: 100,
                color: Colors.white,
                style: TextStyle(color: CommonColors.blueGrey, fontSize: 16),
              ),
            ],
          ),
        ),
        drawer: DrawerWidget(),
        backgroundColor: Color(0xff2c4260),
        body: this.isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      // height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          Text('Users in zones:',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22)),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    // print('called');
                                    this.setState(() {
                                      if (this.selectedSorting != "blue")
                                        this.selectedSorting = "blue";
                                      else
                                        this.selectedSorting = "all";
                                    });
                                  },
                                  child: Card(
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      color: Colors.blue,
                                      alignment: Alignment.center,
                                      child: Text(this.blueCount.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => this.setState(() {
                                    if (this.selectedSorting != "yellow")
                                      this.selectedSorting = "yellow";
                                    else
                                      this.selectedSorting = "all";
                                  }),
                                  child: Card(
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      color: Colors.yellow,
                                      alignment: Alignment.center,
                                      child: Text(this.yellowCount.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => this.setState(() {
                                    if (this.selectedSorting != "red")
                                      this.selectedSorting = "red";
                                    else
                                      this.selectedSorting = "all";
                                  }),
                                  child: Card(
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      color: Colors.red,
                                      alignment: Alignment.center,
                                      child: Text(this.redCount.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          // labelStyle: TextStyle(color: Colors.white),
                          hintText: 'Search by mobile number',
                          labelText: 'Search',
                        ),
                        onEditingComplete: () {
                          // print(this._name);

                          FocusScope.of(context).requestFocus(new FocusNode());

                          this.setState(() {
                            this._name = this._name;
                          });
                        },
                        onChanged: (value) {
                          _name = value;
                        },
                        onSaved: (String value) {
                          _name = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    ...getCards()
                  ],
                ),
              )),
      ),
    );
  }
}
