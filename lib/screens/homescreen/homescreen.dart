import 'dart:math';
import 'dart:typed_data';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:covid_tracker/utils/location_package.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

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
  Position _currentPosition;
  List hotspots = [];
  List nearesthotspots = [];
  var maxX = 50.0;
  var maxY = 50.0;
  final radius = 8.0;

  Color blue1 = const Color(0xFF0D47A1);
  Color blue2 = const Color(0xFF42A5F5).withOpacity(0.8);

  bool showFlutter = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_firebaseMessaging);
    notificationConfigurationSetter();
    setupdatabase();
    startLocation();
  }

  void startLocation() async {
    await LocationPackage()
        .locationServiceStart({"email": "uj00007@gmail.com"});
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
    // database.reference().child('users').push().set({
    //   "name": "Ujjwal Goyal",
    //   "age": 25,
    //   "mobile_number": "9650377543",
    //   "state": "Karnataka",
    //   "city": "Bengaluru",
    //   "email_id": "uj00007@gmail.com",
    //   "token": ""
    // });
    _getHotspotData();
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

  _getCurrentLocation() {
    // nearesthotspots = [];
    // hotspots = [];
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      print(_currentPosition);
      _calculateNearestHotspots();
    }).catchError((e) {
      print(e);
    });
  }

  _getHotspotData() {
    database.reference().child('hotspots').once().then((DataSnapshot snapshot) {
      // print('value ${snapshot.value}');
      hotspots = snapshot.value;
    });
  }

  _calculateNearestHotspots() {
    print('calculating nearby');
    if (hotspots.isNotEmpty) {
      hotspots.forEach((hotspot) {
        var dist = getDistanceFromLatLonInKm(
            double.parse(hotspot["lat"]),
            double.parse(hotspot["lng"]),
            _currentPosition.latitude,
            _currentPosition.longitude);
        // print(dist);
        if ((dist - double.parse(hotspot["radius"])) < 200) {
          nearesthotspots.add(hotspot);
        }
      });
    }
    print(nearesthotspots);
  }

  getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  deg2rad(deg) {
    return deg * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        title: Text('Covid Tracker'),
      ),
      drawer: DrawerWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.location_on,
              color: CommonColors.softRed,
              size: 30,
            ),
            FlatButton(
              child: Text("Get Hotspots"),
              onPressed: () {
                // Get location here
                // setState(() {
                //   nearesthotspots = [];
                //   hotspots = [];
                // });

                _getCurrentLocation();
              },
            ),
            InkWell(
              onTap: () {
                setState(() {
                  showFlutter = !showFlutter;
                });
              },
              child: Container(
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots:
                        showFlutter ? flutterLogoData() : randomData(),
                    minX: 0,
                    maxX: 30,
                    minY: 0,
                    maxY: 30,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    gridData: FlGridData(
                      show: true,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                    ),
                    scatterTouchData: ScatterTouchData(
                      enabled: false,
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ScatterSpot> flutterLogoData() {
    return [
      /// section 1
      ScatterSpot(20, 14.5, color: blue1, radius: radius),
      ScatterSpot(22, 16.5, color: blue1, radius: radius),
      ScatterSpot(24, 18.5, color: blue1, radius: radius),

      ScatterSpot(22, 12.5, color: blue1, radius: radius),
      ScatterSpot(24, 14.5, color: blue1, radius: radius),
      ScatterSpot(26, 16.5, color: blue1, radius: radius),

      ScatterSpot(24, 10.5, color: blue1, radius: radius),
      ScatterSpot(26, 12.5, color: blue1, radius: radius),
      ScatterSpot(28, 14.5, color: blue1, radius: radius),

      ScatterSpot(26, 8.5, color: blue1, radius: radius),
      ScatterSpot(28, 10.5, color: blue1, radius: radius),
      ScatterSpot(30, 12.5, color: blue1, radius: radius),

      ScatterSpot(28, 6.5, color: blue1, radius: radius),
      ScatterSpot(30, 8.5, color: blue1, radius: radius),
      ScatterSpot(32, 10.5, color: blue1, radius: radius),

      ScatterSpot(30, 4.5, color: blue1, radius: radius),
      ScatterSpot(32, 6.5, color: blue1, radius: radius),
      ScatterSpot(34, 8.5, color: blue1, radius: radius),

      ScatterSpot(34, 4.5, color: blue1, radius: radius),
      ScatterSpot(36, 6.5, color: blue1, radius: radius),

      ScatterSpot(38, 4.5, color: blue1, radius: radius),

      /// section 2
      ScatterSpot(20, 14.5, color: blue2, radius: radius),
      ScatterSpot(22, 12.5, color: blue2, radius: radius),
      ScatterSpot(24, 10.5, color: blue2, radius: radius),

      ScatterSpot(22, 16.5, color: blue2, radius: radius),
      ScatterSpot(24, 14.5, color: blue2, radius: radius),
      ScatterSpot(26, 12.5, color: blue2, radius: radius),

      ScatterSpot(24, 18.5, color: blue2, radius: radius),
      ScatterSpot(26, 16.5, color: blue2, radius: radius),
      ScatterSpot(28, 14.5, color: blue2, radius: radius),

      ScatterSpot(26, 20.5, color: blue2, radius: radius),
      ScatterSpot(28, 18.5, color: blue2, radius: radius),
      ScatterSpot(30, 16.5, color: blue2, radius: radius),

      ScatterSpot(28, 22.5, color: blue2, radius: radius),
      ScatterSpot(30, 20.5, color: blue2, radius: radius),
      ScatterSpot(32, 18.5, color: blue2, radius: radius),

      ScatterSpot(30, 24.5, color: blue2, radius: radius),
      ScatterSpot(32, 22.5, color: blue2, radius: radius),
      ScatterSpot(34, 20.5, color: blue2, radius: radius),

      ScatterSpot(34, 24.5, color: blue2, radius: radius),
      ScatterSpot(36, 22.5, color: blue2, radius: radius),

      ScatterSpot(38, 24.5, color: blue2, radius: radius),

      /// section 3
      ScatterSpot(10, 25, color: blue2, radius: radius),
      ScatterSpot(12, 23, color: blue2, radius: radius),
      ScatterSpot(14, 21, color: blue2, radius: radius),

      ScatterSpot(12, 27, color: blue2, radius: radius),
      ScatterSpot(14, 25, color: blue2, radius: radius),
      ScatterSpot(16, 23, color: blue2, radius: radius),

      ScatterSpot(14, 29, color: blue2, radius: radius),
      ScatterSpot(16, 27, color: blue2, radius: radius),
      ScatterSpot(18, 25, color: blue2, radius: radius),

      ScatterSpot(16, 31, color: blue2, radius: radius),
      ScatterSpot(18, 29, color: blue2, radius: radius),
      ScatterSpot(20, 27, color: blue2, radius: radius),

      ScatterSpot(18, 33, color: blue2, radius: radius),
      ScatterSpot(20, 31, color: blue2, radius: radius),
      ScatterSpot(22, 29, color: blue2, radius: radius),

      ScatterSpot(20, 35, color: blue2, radius: radius),
      ScatterSpot(22, 33, color: blue2, radius: radius),
      ScatterSpot(24, 31, color: blue2, radius: radius),

      ScatterSpot(22, 37, color: blue2, radius: radius),
      ScatterSpot(24, 35, color: blue2, radius: radius),
      ScatterSpot(26, 33, color: blue2, radius: radius),

      ScatterSpot(24, 39, color: blue2, radius: radius),
      ScatterSpot(26, 37, color: blue2, radius: radius),
      ScatterSpot(28, 35, color: blue2, radius: radius),

      ScatterSpot(26, 41, color: blue2, radius: radius),
      ScatterSpot(28, 39, color: blue2, radius: radius),
      ScatterSpot(30, 37, color: blue2, radius: radius),

      ScatterSpot(28, 43, color: blue2, radius: radius),
      ScatterSpot(30, 41, color: blue2, radius: radius),
      ScatterSpot(32, 39, color: blue2, radius: radius),

      ScatterSpot(30, 45, color: blue2, radius: radius),
      ScatterSpot(32, 43, color: blue2, radius: radius),
      ScatterSpot(34, 41, color: blue2, radius: radius),

      ScatterSpot(34, 45, color: blue2, radius: radius),
      ScatterSpot(36, 43, color: blue2, radius: radius),

      ScatterSpot(38, 45, color: blue2, radius: radius),
    ];
  }

  List<ScatterSpot> randomData() {
    // const blue1Count = 2;
    List<ScatterSpot> splatterlist = [];
    var blue2Count = nearesthotspots.length;
    splatterlist = List.generate(blue2Count, (i) {
      Color color;
      color = blue2;

      return ScatterSpot((Random().nextDouble() * (maxX - 8)) + 4,
          (Random().nextDouble() * (maxY - 8)) + 4,
          color: color,
          // radius: (Random().nextDouble() * 16) + 4,
          radius: double.parse(nearesthotspots[i]["radius"]));
    });
    splatterlist.add(ScatterSpot(25, 25, color: blue1, radius: radius));
    return splatterlist;
  }
}
