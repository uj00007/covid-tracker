import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseApp app;
  FirebaseDatabase database;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_firebaseMessaging);
    notificationConfigurationSetter();
    setupdatabase();
  }

  void setupdatabase() async {
    app = await FirebaseApp.configure(
        name: 'covid-tracker-85a72',
        options: const FirebaseOptions(
            googleAppID: '1:614988993013:android:e03932f4df5f75e28fd0bc',
            apiKey: '614988993013',
            databaseURL: 'https://covid-tracker-85a72.firebaseio.com'));
    database = FirebaseDatabase(app: app);
    database.reference().child('hotspots').once().then((DataSnapshot snapshot) {
      print('value ${snapshot.value[0]['name']}');
    });
    database.reference().child('users').push().set({
      "name": "Ujjwal Goyal",
      "age": 25,
      "mobile_number": "9650377543",
      "state": "Karnataka",
      "city": "Bengaluru",
      "email_id": "uj00007@gmail.com",
      "token": ""
    });
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
    _showNotification('fghcv', 'des');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
    );
  }
}
