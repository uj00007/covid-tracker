import 'dart:convert';
import 'dart:typed_data';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/utils/adjusted_size.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseApp app;
  FirebaseDatabase database;
  List rawUsers = [];
  String _name;
  String _mobileNumber;
  String _groupCode;
  String _email;
  int _age;
  String version;
  String _token;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    notificationConfigurationSetter();
    setupdatabase();
  }

  void notificationConfigurationSetter() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    _firebaseMessaging.subscribeToTopic('all');
    // _showNotification('fghcv', 'des');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // _showItemDialog(message);
        _showNotification('fghcv', 'des');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   setState(() {
    //     _homeScreenText = "Push Messaging token: $token";
    //   });
    this.getToken();
  }

  addUserToStorage(user, id) async {
    user["id"] = id;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(user));
  }

  void _showNotification(String title, String subtitle) async {
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 1000;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 1000;
    vibrationPattern[3] = 1000;
    // final iconPath = await saveImage(Image.asset('assets/splash_image.png'));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      "1",
      "test notification",
      "notification test",
      icon: '@mipmap/ic_launcher',
      importance: Importance.Max,
      priority: Priority.High,
      sound: 'soundtone_notification',
      color: Color(0xfffc223c),
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        1, 'Hi', 'Hello', platformChannelSpecifics);
  }

  getToken() async {
    String fcmtoken = await _firebaseMessaging.getToken();
    print(fcmtoken);
    _token = fcmtoken;
  }

  void setupdatabase() async {
    app = await FirebaseApp.configure(
        name: 'covid-tracker-85a72',
        options: const FirebaseOptions(
            googleAppID: '1:614988993013:android:e03932f4df5f75e28fd0bc',
            apiKey: '614988993013',
            databaseURL: 'https://covid-tracker-85a72.firebaseio.com'));
    database = FirebaseDatabase(app: app);
    // database.reference().child('hotspots').once().then((DataSnapshot snapshot) {
    //   print('value ${snapshot.value[0]['name']}');
    // });
    database.reference().child('users').once().then((DataSnapshot snapshot) {
      print('value ${snapshot.value}');
      this.rawUsers = snapshot.value;
    });
    this.version = await getAppVersion();
  }

  Future<String> getAppVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    print('buildNumber: ${info.buildNumber}');
    return info.version;
  }

  updateUsers() {
    User temp;
    List usersUpdated = [];
    var tempJson;
    if (rawUsers != null) {
      for (var i = 0; i < rawUsers.length; i++) {
        if (rawUsers[i]["email_id"] == _email) {
          print(rawUsers[i]["in_contact_users"]);
          print(rawUsers[i]["in_contact_users"].runtimeType);

          rawUsers[i]["name"] = _name;
          rawUsers[i]["mobile_number"] = _mobileNumber;
          rawUsers[i]["group_code"] = _groupCode;
          rawUsers[i]["email_id"] = _email;
          rawUsers[i]["age"] = _age;
          rawUsers[i]["token"] = _token;
          rawUsers[i]["version"] = this.version;

          temp = User.fromJson(rawUsers[i], i.toString());
          tempJson = rawUsers[i];
          tempJson["version"] = this.version;

          break;
        }
      }
      usersUpdated = [...rawUsers];
    }
    if (temp != null) {
      database.reference().child('users/${temp.id}').set(tempJson);
      //set this temp to shared pref

    } else {
      temp = User(
          id: usersUpdated.length.toString(),
          name: _name,
          mobileNumber: _mobileNumber,
          groupCode: _groupCode,
          emailId: _email,
          age: _age,
          token: _token);
      var user = temp.toJson();
      usersUpdated.add(user);
      user["version"] = this.version;
      // print('usersUpdated');
      database.reference().child('users/${temp.id}').set(user);
    }
    addUserToStorage(temp.toJson(), temp.id);
    if (temp.isAdmin)
      Navigator.of(context).pushNamed(Routes.adminHomeScreenRoute);
    else
      Navigator.of(context).pushNamed(Routes.homeScreenRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          color: CommonColors.backgroundColor,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0, bottom: 50),
                    child: Card(
                      child: Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          // height: 400,
                          padding: EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.person),
                                        hintText: 'What do people call you?',
                                        labelText: 'Name',
                                      ),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.email),
                                        hintText: "What's your email?",
                                        labelText: 'Email',
                                      ),
                                      onSaved: (String value) {
                                        _email = value;
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some text';
                                        } else if (!value.contains('@')) {
                                          return 'Please enter correct email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter
                                            .digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.settings_cell),
                                        hintText:
                                            'What is your mobile number(10 digits)',
                                        labelText: 'Mobile Number',
                                      ),
                                      onSaved: (String value) {
                                        _mobileNumber = value;
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some text';
                                        } else if (value.length != 10) {
                                          return 'Enter a valid mobile number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter
                                            .digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.group),
                                        hintText: 'What is your group Code?',
                                        labelText: 'Group Code',
                                      ),
                                      onSaved: (String value) {
                                        _groupCode = value;
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some text';
                                        } else if (value.length > 3) {
                                          return 'Enter a valid group code';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter
                                            .digitsOnly
                                      ],
                                      onSaved: (String value) {
                                        _age = int.parse(value);
                                      },
                                      decoration: const InputDecoration(
                                        icon: Icon(Icons.assignment_ind),
                                        hintText: 'What is your age',
                                        labelText: 'Age',
                                      ),
                                      // validator: (value) {
                                      //   if (value.isEmpty) {
                                      //     return 'Please enter some text';
                                      //   } else if (value.length > 3) {
                                      //     return 'Enter a valid age';
                                      //   }
                                      //   return '';
                                      // },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: CustomButton(
                  color: Colors.red,
                  label: "SUBMIT",
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a Snackbar.
                      print('validated');
                      _formKey.currentState.save();
                      print(_name);
                      updateUsers();
                    }
                  },
                ),
              )
            ],
          )),
    );
  }
}
