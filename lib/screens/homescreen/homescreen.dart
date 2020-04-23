import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/bar_chart.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/components/flashing_button.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:covid_tracker/utils/exter_link_launcher.dart';
import 'package:covid_tracker/utils/location_package.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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
  bool getBatckgroundLocationFlag = false;
  User user;
  int counterBackgroundLocation = 0;
  RemoteConfig remoteConfig;
  var hotspotData = {};
  String zone = 'blue';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_firebaseMessaging);
    notificationConfigurationSetter();
    setupdatabase();
    getUser();
    hotspotData = {
      'hotspots_distance': 50,
      'hotspot_alert_distance': 2,
      'hotspot_mid_distance': 5,
      'hotspots_to_show': 5
    };
    getBatckgroundLocationFlag = false;
    counterBackgroundLocation = 0;
    getHotspotData().then((res) => setState(() {
          this.hotspotData = res;
          this.getBatckgroundLocationFlag = res['background_location'];
        }));
  }

  void startLocation() async {
    await LocationPackage()
        .locationServiceStart({"email": "uj00007@gmail.com", "id": user.id});
  }

  Future<Map> getHotspotData() async {
    //basically fetching from remote config
    var hdistance;
    var halertdistance;
    var hmiddistance;
    var count;
    bool backgroundLocationFetch = false;
    remoteConfig = await RemoteConfig.instance;
    try {
      await remoteConfig.fetch(expiration: const Duration(hours: 0));
      await remoteConfig.activateFetched();
      hdistance = remoteConfig.getInt('hotspots_distance');
      halertdistance = remoteConfig.getInt('hotspot_alert_distance');
      hmiddistance = remoteConfig.getInt('hotspot_mid_distance');
      count = remoteConfig.getInt('hotspots_to_show');
      backgroundLocationFetch = remoteConfig.getBool('background_location');
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    return {
      'hotspots_distance': hdistance,
      'hotspot_alert_distance': halertdistance,
      'hotspot_mid_distance': hmiddistance,
      'hotspots_to_show': count,
      'background_location': backgroundLocationFetch
    };
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
      database.reference().child('users/${user.id}/location').set(
          {'latitude': position.latitude, 'longitude': position.longitude});
      _calculateNearestHotspots();

      if (this.getBatckgroundLocationFlag &&
          this.counterBackgroundLocation == 0) {
        startLocation();

        this.counterBackgroundLocation = 1;
      }
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
    print(this.hotspotData);
    nearestHotspot = null;

    if (hotspots.isNotEmpty) {
      hotspots.forEach((hotspot) {
        var dist = getDistanceFromLatLonInKm(
            double.parse(hotspot["lat"]),
            double.parse(hotspot["lng"]),
            _currentPosition.latitude,
            _currentPosition.longitude);
        // print(dist);
        if ((dist - double.parse(hotspot["radius"])) <
            this.hotspotData['hotspots_distance']) {
          hotspot["distance"] =
              (dist - double.parse(hotspot["radius"])).toStringAsFixed(3);
          nearesthotspots.add(hotspot);
        }
      });
    }
    nearesthotspots.sort((a, b) => a['distance'].compareTo(b['distance']));
    print('Sort by Age: ' + nearesthotspots.toString());
    if (nearesthotspots != null && nearesthotspots.length > 0) {
      nearesthotspots = nearesthotspots.sublist(
          0,
          nearesthotspots.length >= this.hotspotData['hotspots_to_show']
              ? this.hotspotData['hotspots_to_show']
              : nearesthotspots.length);
    }

    for (var hotspot in nearesthotspots) {
      if (double.parse(hotspot['distance']) <=
          this.hotspotData['hotspot_alert_distance']) {
        nearestHotspot = hotspot;
        this.zone = 'red';
        break;
      } else if (double.parse(hotspot['distance']) >
              this.hotspotData['hotspot_alert_distance'] &&
          double.parse(hotspot['distance']) <=
              this.hotspotData['hotspot_mid_distance']) {
        this.zone = 'yellow';
      } else {
        this.zone = 'blue';
      }
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
        this.zone = zone;
      });
    } else {
      updateDBOfUserSafe();
      this.setState(() {
        this.isProcessing = false;
        this.isSafe = true;
        this.nearestHotspot = nearestHotspot;
        this.nearesthotspots = nearesthotspots;
        this.zone = zone;
      });
    }
  }

  updateDBOfUser() {
    database
        .reference()
        .child('users/${user.id}/nearest_hotspot')
        .set(this.nearestHotspot);
    database.reference().child('users/${user.id}/is_safe').set(false);
    database.reference().child('users/${user.id}/zone').set(this.zone);
    getApiRequest(
        'https://us-central1-covid-tracker-85a72.cloudfunctions.net/sendNotification?id=${user.id}');
  }

  updateDBOfUserSafe() {
    database
        .reference()
        .child('users/${user.id}/nearest_hotspot')
        .set(this.nearestHotspot);
    database.reference().child('users/${user.id}/is_safe').set(true);
    database.reference().child('users/${user.id}/zone').set(this.zone);
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

    HttpClient httpClient = new HttpClient();

    myClient = IOClient(httpClient);
    try {
      print('get url hit -> $url');
      http.Response response = await myClient.get(url, headers: headers);
      if (response != null) {
        print('get response status code-> ${response.statusCode}');
        final int statusCode = response.statusCode;
      }
    } catch (error) {
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

  List<Widget> displaygraphData() {
    List<Widget> wid = [];
    this.nearesthotspots.forEach((hotspot) {
      wid.add(Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(200),
          ),
          elevation: 10.0,
          child: Container(
            height: 120,
            width: 120,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(hotspot['name'],
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text('cases: ${hotspot['cases']}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(
                    '${double.parse(hotspot['distance']).floor() < 0 ? '0' : double.parse(hotspot['distance']).floor()}km',
                    style: TextStyle(
                        color: CommonColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ],
            ),
          ),
        ),
      ));
    });

    return wid;
  }

  Widget makeTransactionsIcon() {
    const double width = 4.5;
    const double space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return WillPopScope(
      onWillPop: () =>
          SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff2c4260),
          elevation: 0.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Covid Tracker'),
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
                  label: 'Add Contact Log'),
            ],
          ),
        ),
        drawer: DrawerWidget(),
        backgroundColor: Color(0xff2c4260),
        body: Container(
          child: SingleChildScrollView(
            child: Center(
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
                              // BarChartSample2(
                              //     nearesthotspots: this.nearesthotspots),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  makeTransactionsIcon(),
                                  const SizedBox(
                                    width: 38,
                                  ),
                                  const Text(
                                    'hotspots near you..',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                ],
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: <Widget>[...displaygraphData()],
                              ),
                              // Container(
                              //   padding: EdgeInsets.only(left: 44),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: <Widget>[...displaygraphData()],
                              //   ),
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Container(
                              //     child: Row(
                              //       children: <Widget>[
                              //         Container(
                              //           height: 25,
                              //           width: 25,
                              //           color: Color(0xffff5182),
                              //         ),
                              //         Text(
                              //           '-  Represents proximity distance to hotspot..',
                              //           style: TextStyle(
                              //               color: const Color(0xff7589a2),
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 14),
                              //         )
                              //       ],
                              //     ),
                              //   ),
                              // )
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
                            child: Text("Get Hotspots",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
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
                    this.nearesthotspots == null ||
                            this.nearesthotspots.length == 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Text('No Hotspots Nearby',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30)),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
