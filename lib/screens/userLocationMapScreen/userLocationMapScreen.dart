import 'dart:async';
import 'dart:convert';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:covid_tracker/utils/group_codes.dart';
import 'package:covid_tracker/utils/map_style_json.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocationMapScreen extends StatefulWidget {
  final userId;

  const UserLocationMapScreen({Key key, this.userId}) : super(key: key);
  @override
  _UserLocationMapScreenState createState() => _UserLocationMapScreenState();
}

class _UserLocationMapScreenState extends State<UserLocationMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];
  List<Circle> circles = [];
  FirebaseApp app;
  FirebaseDatabase database;

  CameraPosition _pos;
  List users = [];
  List hotspots = [];
  Position _currentPosition;
  Marker self;
  User user;
  RemoteConfig remoteConfig;

  var groupCodes = {};

  @override
  void initState() {
    super.initState();

    groupCodes = json.decode(groupCodesDefaultJson);
    getGroupCodes().then((res) {
      _getCurrentLocation();
      print('remote config group codes done');
      setState(() {
        this.groupCodes = res;
      });
    });
  }

  Future<Map> getGroupCodes() async {
    //basically fetching from remote config

    var groupCodes;
    remoteConfig = await RemoteConfig.instance;
    try {
      await remoteConfig.fetch(expiration: const Duration(hours: 0));
      await remoteConfig.activateFetched();
      groupCodes = json.decode(remoteConfig.getString('group_codes'));
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    return groupCodes;
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null) {
      this.user = User.fromJson(json.decode(stringValue), '');
      print('get user done');

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
    print('setup database complete');

    getUsers();
    getHotspots();
  }

  _getCurrentLocation() {
    // final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    getUser();

    // geolocator
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
    //     .then((Position position) {
    //   this.setState(() {
    //     _currentPosition = position;

    //     self = Marker(
    //         infoWindow: InfoWindow(title: 'You'),
    //         markerId: MarkerId('You'),
    //         draggable: false,
    //         onTap: () => print('tapped'),
    //         position: LatLng(position.latitude, position.longitude));
    //   });
    //   print(_currentPosition);
    //   print('current location done');

    // }).catchError((e) {
    //   this.setState(() {
    //     _pos = CameraPosition(target: LatLng(12.897489, 78.34058), zoom: 11);
    //   });
    //   getUser();

    //   print(e);
    // });
  }

  getHotspots() {
    try {
      database
          .reference()
          .child('hotspots')
          .once()
          .then((DataSnapshot snapshot) {
        // print('value ${snapshot.value}');
        if (snapshot.value != null) {
          this.setState(() {
            this.hotspots = snapshot.value;
            // this.isLoading = false;
          });
          // getCounts();
          print('get hotspots complere');

          setHotspotCircles();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  setHotspotCircles() {
    List<Circle> temp = [];
    for (var hotspot in this.hotspots) {
      temp.add(Circle(
        fillColor: Color.fromRGBO(255, 255, 0, 0.3),
        strokeColor: Colors.yellow,
        strokeWidth: 3,
        circleId: CircleId(
            hotspot['name'] != null ? '${hotspot['name']}-caution' : ''),
        center:
            LatLng(double.parse(hotspot['lat']), double.parse(hotspot['lng'])),
        radius: (double.parse(hotspot["radius"].toString()) + 3.0) * 1000,
      ));
      temp.add(Circle(
        fillColor: Color.fromRGBO(255, 0, 0, 0.3),
        strokeColor: Colors.red,
        strokeWidth: 3,
        circleId: CircleId(hotspot['name'] != null ? hotspot['name'] : ''),
        center:
            LatLng(double.parse(hotspot['lat']), double.parse(hotspot['lng'])),
        radius: double.parse(hotspot["radius"].toString()) * 1000,
      ));
    }

    this.setState(() {
      this.circles = temp;
    });
    print('hot spot circles dine');
  }

  getUsers() {
    try {
      database.reference().child('users').once().then((DataSnapshot snapshot) {
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
            });
          } else {
            this.setState(() {
              this.users = snapshot.value;
            });
          }
          print('get users complete');

          setUserMarkers();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  setUserMarkers() {
    print('set user markers start');

    List<Marker> markerstemp = this.self != null ? [self] : [];
    CameraPosition temppos = null;
    for (var user in this.users) {
      // print(user);
      if (user['location'] != null && user["id"] == widget.userId) {
        var userCode = user['group_code'] != null ? user['group_code'] : '100';
        print(double.parse(this.groupCodes[userCode] != null
            ? this.groupCodes[userCode]['hue_code'].toString()
            : '2.0'));
        markerstemp.add(Marker(
            infoWindow: InfoWindow(
                title: user['name'],
                snippet: user['nearest_hotspot'] != null &&
                        user['nearest_hotspot']['distance'] != null &&
                        user['group_code'] != null
                    ? "${double.parse(user['nearest_hotspot']['distance'].toString()) < 0 ? '0' : double.parse(user['nearest_hotspot']['distance'].toString()).toString()} Kms; Group: ${user['group_code'].toString()}"
                    : ''),
            icon: BitmapDescriptor.defaultMarkerWithHue(double.parse(
                this.groupCodes[userCode] != null
                    ? this.groupCodes[userCode]['hue_code'].toString()
                    : '2.0')),
            markerId: MarkerId(user['email_id']),
            draggable: false,
            onTap: () => print('tapped'),
            position: LatLng(
                user['location']['latitude'], user['location']['longitude'])));
        temppos = CameraPosition(
            target: LatLng(
                user['location']['latitude'], user['location']['longitude']),
            zoom: 11);
        break;
      }
    }
    print('user markers setting done done');

    this.setState(() {
      this.markers = markerstemp;
      _pos = temppos;
    });
  }

  @override
  void dispose() {
    print('disposed');
    super.dispose();
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
                this.setState(() {
                  this.users = [];
                  this.hotspots = [];
                });
                this.getUsers();
                this.getHotspots();
              },
              child: Stack(children: <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    this.setState(() {
                      this.users = [];
                      this.hotspots = [];
                    });
                    this.getUsers();
                    this.getHotspots();
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
        backgroundColor: Color(0xff2c4260),
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('User Location'),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          _pos != null
              ? GoogleMap(
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: _pos,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    controller.setMapStyle(mapStyleJson);
                  },
                  markers: Set.from(markers),
                  circles: Set.from(circles),
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
