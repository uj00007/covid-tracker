import 'dart:convert';
import 'dart:typed_data';

import 'package:covid_tracker/routing/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseApp app;
  FirebaseDatabase database;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmtoken;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool versionMismatch = false;

  RemoteConfig remoteConfig;
  var versionData = {};

  @override
  void initState() {
    super.initState();

    versionData = {
      'forced_update': false,
    };
    getVersionData().then((res) {
      setState(() {
        this.versionData = res;
      });
      if (!res['forced_update']) notificationConfigurationSetter();
    });
  }

  Future<bool> compareAppVersion(String versionCode) async {
    PackageInfo info = await PackageInfo.fromPlatform();
    print('versionCode: $versionCode');
    print('buildNumber: ${info.buildNumber}');
    if (int.parse(versionCode) > int.parse(info.buildNumber))
      versionMismatch = true;
    print(versionMismatch);
    return versionMismatch;
  }

  Future<Map> getVersionData() async {
    //basically fetching from remote config
    bool forcedUpdate = false;
    String version = '0';
    remoteConfig = await RemoteConfig.instance;
    try {
      await remoteConfig.fetch(expiration: const Duration(hours: 0));
      await remoteConfig.activateFetched();
      version = remoteConfig.getString('version_code');
      // halertdistance = remoteConfig.getInt('hotspot_alert_distance');
      // hmiddistance = remoteConfig.getInt('hotspot_mid_distance');
      // count = remoteConfig.getInt('hotspots_to_show');
      forcedUpdate = remoteConfig.getBool('forced_update');
      if (await compareAppVersion(version) && forcedUpdate) {
        forcedUpdate = true;
      } else {
        forcedUpdate = false;
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    return {'forced_update': forcedUpdate};
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
        _showNotification(
            message["notification"]["title"], message["notification"]["body"]);
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

  getToken() async {
    this.fcmtoken = await _firebaseMessaging.getToken();
    print(fcmtoken);
    getUser();
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
        1, title, subtitle, platformChannelSpecifics);
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null) {
      setupdatabase(json.decode(stringValue)['id']);
    } else
      Navigator.of(context).pushNamed(Routes.loginRoute);
  }

  void setupdatabase(id) async {
    app = await FirebaseApp.configure(
        name: 'covid-tracker-85a72',
        options: const FirebaseOptions(
            googleAppID: '1:614988993013:android:e03932f4df5f75e28fd0bc',
            apiKey: '614988993013',
            databaseURL: 'https://covid-tracker-85a72.firebaseio.com'));
    database = FirebaseDatabase(app: app);
    // updatedb();
    getUserFromDB(id);
  }

  // updatedb() {
  //   database.reference().child('users').once().then((DataSnapshot snapshot) {
  //     // print('value ${snapshot.value}');
  //     if (snapshot.value != null) {
  //       for (var i = 0; i < snapshot.value.length; i++) {
  //         database.reference().child('users/${i}/id').set(i.toString());
  //       }
  //     }
  //   });
  // }

  addUserToStorage(user, id) async {
    user["id"] = id;
    user["token"] = this.fcmtoken;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(user));
    database.reference().child('users/${id}').set(user);
    print('updated successfully');
  }

  setUserToStorage(user, id) async {
    user["id"] = id;
    user["token"] = this.fcmtoken;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(user));
    print('updated successfully');
  }

  getUserFromDB(id) {
    if (id != null) {
      database
          .reference()
          .child('users/${id}')
          .once()
          .then((DataSnapshot snapshot) {
        // print('value ${snapshot.value}');
        if (snapshot.value != null) {
          if (this.fcmtoken != snapshot.value['token']) {
            addUserToStorage(snapshot.value, id);
          } else {
            setUserToStorage(snapshot.value, id);
          }

          if (snapshot.value['is_admin'])
            Navigator.of(context).pushNamed(Routes.adminHomeScreenRoute);
          else
            Navigator.of(context).pushNamed(Routes.homeScreenRoute);
        } else {
          Navigator.of(context).pushNamed(Routes.loginRoute);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff123448),
      body: !this.versionData["forced_update"]
          ? Container(
              height: MediaQuery.of(context).size.height,
              color: Color(0xff123448),
              child: Image.asset(
                'assets/images/splash.png',
                alignment: Alignment.center,
                fit: BoxFit.contain,
                // height: 100,
                // width: 100,
                scale: 20,
              ),
            )
          : Center(
              child: Text(
                "Please Install Latest Version of the app",
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}
