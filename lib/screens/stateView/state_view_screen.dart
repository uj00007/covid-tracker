import 'dart:convert';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateViseView extends StatefulWidget {
  @override
  _StateViseViewState createState() => _StateViseViewState();
}

class _StateViseViewState extends State<StateViseView> {
  String dropdownValue = 'All';
  FirebaseApp app;
  FirebaseDatabase database;
  List users = [];
  Map stateMap = {'All': {}};
  User userAdmim;

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
    if (stringValue != null) {
      this.userAdmim = User.fromJson(json.decode(stringValue), '');
      setupdatabase();
    }
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

  getUsers() {
    database.reference().child('users').once().then((DataSnapshot snapshot) {
      print('value ${snapshot.value}');
      if (snapshot.value != null) {
        this.setState(() {
          this.users = snapshot.value;
        });
        createStateMap();
      }
    });
  }

  createStateMap() {
    var temp = {};
    var tempAll = {};
    for (var user in this.users) {
      if ((!this.userAdmim.isSuperAdmin &&
              this.userAdmim.groupCode == user["group_code"]) ||
          this.userAdmim.isSuperAdmin) {
        var state = user["state"] != null && user["state"] != ""
            ? user["state"]
            : user["nearest_hotspot"] != null
                ? user["nearest_hotspot"]["state"]
                : null;
        var grp = user["group_code"];
        var zone = user["zone"];
        print('hrll');
        print("${grp} - ${state}");
        if (tempAll.containsKey(grp)) {
          tempAll[grp]["total"] = tempAll[grp]["total"] + 1;
          if (tempAll[grp].containsKey(zone)) {
            tempAll[grp][zone] = tempAll[grp][zone] + 1;
          } else {
            tempAll[grp][zone] = 1;
          }
        } else {
          tempAll[grp] = {"total": 1};
          tempAll[grp][zone] = 1;
        }

        if (grp != '' && grp != null && state != null) {
          if (temp.containsKey(state)) {
            if (temp[state].containsKey(grp)) {
              temp[state][grp]['total'] = temp[state][grp]['total'] + 1;
              if (temp[state][grp].containsKey(zone)) {
                temp[state][grp][zone] = temp[state][grp][zone] + 1;
              } else {
                temp[state][grp][zone] = 1;
              }
            } else {
              temp[state][grp] = {"total": 1};
              temp[state][grp][zone] = 1;
            }
          } else {
            temp[state] = {};
            temp[state][grp] = {"total": 1};
            temp[state][grp][zone] = 1;
          }
        }
      }
    }
    print("state map");
    temp['All'] = tempAll;
    print(temp);
    this.setState(() {
      this.stateMap = temp;
    });
  }

  List<Widget> getGroupInfo() {
    var statejson = this.stateMap[dropdownValue];
    List<Widget> widgets = [];
    widgets.add(Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Group Code',
            style: TextStyle(color: Colors.red, fontSize: 24),
          ),
          Text(
            ' - ',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          Text(
            'User Count',
            style: TextStyle(color: Colors.red, fontSize: 24),
          ),
        ],
      ),
    ));
    for (var key in statejson.keys) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              key.toString(),
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              ' - ',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Total : ",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      statejson[key]['total'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Card(
                            child: Container(
                          height: 30,
                          width: 30,
                          color: Colors.blue,
                          alignment: Alignment.center,
                        )),
                        Text(
                          statejson[key]['blue'] != null
                              ? statejson[key]['blue'].toString()
                              : '0',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Card(
                              child: Container(
                            height: 30,
                            width: 30,
                            color: Colors.yellow,
                            alignment: Alignment.center,
                          )),
                          Text(
                            statejson[key]['yellow'] != null
                                ? statejson[key]['yellow'].toString()
                                : '0',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Card(
                            child: Container(
                          height: 30,
                          width: 30,
                          color: Colors.red,
                          alignment: Alignment.center,
                        )),
                        Text(
                          statejson[key]['red'] != null
                              ? statejson[key]['red'].toString()
                              : '0',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        // alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                this.getUsers();
              },
              child: Stack(children: <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    this.getUsers();
                  },
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
        backgroundColor: CommonColors.backgroundColor,
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('State Vise View'),
            // FlashingButton(
            //   onPressed: () => ExternalLink.launchURL(),
            //   label: 'Live Cases',
            //   height: 40,
            //   multiTap: true,
            //   disabled: false,
            //   width: 100,
            //   color: Colors.white,
            //   style: TextStyle(color: CommonColors.blueGrey, fontSize: 16),
            // ),
          ],
        ),
      ),
      backgroundColor: CommonColors.backgroundColor,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.red, fontSize: 20),
                    underline: Container(
                      height: 2,
                      color: Colors.red,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>[...stateMap.keys.toList()]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Container(
                child: Column(
                  children: <Widget>[...getGroupInfo()],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
