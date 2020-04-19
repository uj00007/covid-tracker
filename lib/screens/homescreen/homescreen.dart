import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/bar_chart.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var nearestHotspot;
  bool isProcessing = false;
  bool isSafe = true;
  User user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_firebaseMessaging);
    notificationConfigurationSetter();
    setupdatabase();
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
    getUserInfo();
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

  getToken() async {
    String fcmtoken = await _firebaseMessaging.getToken();
    print(fcmtoken);
  }

  _getCurrentLocation() {
    this.setState(() {
      this.isProcessing = true;
      this.nearesthotspots = [];
    });
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
    nearestHotspot = null;

    if (hotspots.isNotEmpty) {
      hotspots.forEach((hotspot) {
        var dist = getDistanceFromLatLonInKm(
            double.parse(hotspot["lat"]),
            double.parse(hotspot["lng"]),
            _currentPosition.latitude,
            _currentPosition.longitude);
        // print(dist);
        if ((dist - double.parse(hotspot["radius"])) < 200) {
          hotspot["distance"] =
              (dist - double.parse(hotspot["radius"])).toStringAsFixed(3);
          nearesthotspots.add(hotspot);
          if ((dist - double.parse(hotspot["radius"])) < 100) {
            nearestHotspot = hotspot;
          }
        }
      });
    }
    // print(nearesthotspots);
    print('nearest ${nearestHotspot}');
    if (nearestHotspot != null) {
      // _showNotification('ALERT!!!', 'You are in a vicinity');
      updateDBOfUser();
      this.setState(() {
        this.isProcessing = false;
        this.isSafe = false;
        this.nearestHotspot = nearestHotspot;
        this.nearesthotspots = nearesthotspots;
      });
    } else {
      updateDBOfUserSafe();
      this.setState(() {
        this.isProcessing = false;
        this.isSafe = true;
        this.nearestHotspot = nearestHotspot;
        this.nearesthotspots = nearesthotspots;
      });
    }
  }

  updateDBOfUser() {
    database
        .reference()
        .child('users/${user.id}/nearest_hotspot')
        .set(this.nearestHotspot);
    database.reference().child('users/${user.id}/is_safe').set(false);
    getApiRequest(
        'https://us-central1-covid-tracker-85a72.cloudfunctions.net/sendNotification?id=${user.id}');
  }

  updateDBOfUserSafe() {
    database
        .reference()
        .child('users/${user.id}/nearest_hotspot')
        .set(this.nearestHotspot);
    database.reference().child('users/${user.id}/is_safe').set(true);
  }

  getUserInfo() {
    database
        .reference()
        .child('users/${user.id}')
        .once()
        .then((DataSnapshot snapshot) {
      print('value ${snapshot.value}');
      if (snapshot.value != null) {
        this.setState(() {
          this.isSafe = snapshot.value["is_safe"];
        });
      }
    });
  }

  getApiRequest(String url, {Map<String, String> headers}) async {
    IOClient myClient;

    // Map<String, String> header = {
    //   HttpHeaders.authorizationHeader: user.authToken,
    //   'agent_id': user.agentId.toString()
    // };
    HttpClient httpClient = new HttpClient();

    myClient = IOClient(httpClient);
    try {
      print('get url hit -> $url');
//        ClevertapFlutter.pushEvent(
//            'Api Get Request', {'url': url, "header": header});
      http.Response response = await myClient.get(url, headers: headers);
      if (response != null) {
        print('get response status code-> ${response.statusCode}');
        final int statusCode = response.statusCode;
      }
      // return http
      //     .get(url, headers: headers)
      //     .timeout(Duration(seconds: timeoutInSeconds),
      //         onTimeout: () => onTimeout(failureCallback))
      //     .then((http.Response response) {
      //   print("header--->>> ${headers.toString()}");
      //   print('get response status code-> ${response}');

      //   if (response != null) {
      //     print('get response status code-> ${response.statusCode}');
      //     final int statusCode = response.statusCode;
      //     updateAuthHeaders(response);
      //     return statusCodeCheck(
      //       statusCode,
      //       response,
      //       successCallback,
      //       failureCallback,
      //     );
      //   } else
      //     return failureCallback({});
      // });
    }
    // on TimeoutException catch (e) {
    //   onTimeout(failureCallback);
    // }
    catch (error) {
      print('api failed');
      print(error);
    }
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

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null) {
      user = User.fromJson(
          json.decode(stringValue), json.decode(stringValue)["id"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2c4260),
        elevation: 0.0,
        title: Text('Covid Tracker'),
      ),
      floatingActionButton: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () => _getCurrentLocation(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Icon(
                    Icons.refresh,
                    size: 40,
                    color: Colors.red,
                  )),
            ),
            CustomButton(
                width: 200,
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.addContactPersonRoute),
                label: 'Add Visited People'),
          ],
        ),
      ),
      drawer: DrawerWidget(),
      backgroundColor: Color(0xff2c4260),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              !this.isSafe
                  ? Container(
                      // color: Colors.red,
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        color: Colors.red,
                        elevation: 1.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("ALERT!!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    letterSpacing: 5,
                                    fontWeight: FontWeight.w700)),
                            Text("You are inside a hotspot zone",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              !this.isProcessing &&
                      this.nearesthotspots != null &&
                      this.nearesthotspots.length != 0
                  ? Column(
                      children: <Widget>[
                        BarChartSample2(nearesthotspots: this.nearesthotspots),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 25,
                                  width: 25,
                                  color: Color(0xff53fdd7),
                                ),
                                Text(
                                  '-  Represents cases..',
                                  style: TextStyle(
                                      color: const Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 25,
                                  width: 25,
                                  color: Color(0xffff5182),
                                ),
                                Text(
                                  '-  Represents proximity distance to hotspot..',
                                  style: TextStyle(
                                      color: const Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : SizedBox(),
              !this.isProcessing
                  ? Icon(
                      Icons.location_on,
                      color: CommonColors.softRed,
                      size: 40,
                    )
                  : CircularProgressIndicator(),
              (!this.isProcessing &&
                      this.nearesthotspots != null &&
                      this.nearesthotspots.length == 0)
                  ? FlatButton(
                      child: Text("Get Hotspots"),
                      onPressed: () {
                        // Get location here
                        // setState(() {
                        //   nearesthotspots = [];
                        //   hotspots = [];
                        // });

                        _getCurrentLocation();
                      },
                    )
                  : SizedBox(),
              _currentPosition != null
                  ? Text(
                      '${_currentPosition.latitude.toString()} ,${_currentPosition.longitude.toString()}',
                      style: TextStyle(color: Color(0xffff5182)),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
