import 'dart:async';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/utils/exter_link_launcher.dart';
import 'package:covid_tracker/utils/map_style_json.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({@required Key key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    getHotspots();
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      this.setState(() {
        _currentPosition = position;
        _pos = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 11);
        self = Marker(
            infoWindow: InfoWindow(title: 'You'),
            markerId: MarkerId('You'),
            draggable: false,
            onTap: () => print('tapped'),
            position: LatLng(position.latitude, position.longitude));
      });
      print(_currentPosition);
      setupdatabase();
    }).catchError((e) {
      this.setState(() {
        _pos = CameraPosition(target: LatLng(12.897489, 78.34058), zoom: 11);
      });
      setupdatabase();

      print(e);
    });
  }

  getHotspots() {
    database.reference().child('hotspots').once().then((DataSnapshot snapshot) {
      // print('value ${snapshot.value}');
      if (snapshot.value != null) {
        this.setState(() {
          this.hotspots = snapshot.value;
          // this.isLoading = false;
        });
        // getCounts();
        setHotspotCircles();
      }
    });
  }

  setHotspotCircles() {
    List<Circle> temp = [];
    for (var hotspot in this.hotspots) {
      temp.add(Circle(
        fillColor: Color.fromRGBO(255, 0, 0, 0.3),
        strokeColor: Colors.red,
        strokeWidth: 3,
        circleId: CircleId(hotspot['name'] != null ? hotspot['name'] : ''),
        center:
            LatLng(double.parse(hotspot['lat']), double.parse(hotspot['lng'])),
        radius: 10000,
      ));
    }
    this.setState(() {
      this.circles = temp;
    });
  }

  getUsers() {
    database.reference().child('users').once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        this.setState(() {
          this.users = snapshot.value;
        });
        setUserMarkers();
      }
    });
  }

  setUserMarkers() {
    List<Marker> markerstemp = this.self != null ? [self] : [];
    for (var user in this.users) {
      if (user['location'] != null)
        markerstemp.add(Marker(
            infoWindow: InfoWindow(title: user['name']),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            markerId: MarkerId(user['email_id']),
            draggable: false,
            onTap: () => print('tapped'),
            position: LatLng(
                user['location']['latitude'], user['location']['longitude'])));
    }
    this.setState(() {
      this.markers = markerstemp;
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('CovidTracker-Admin'),
            CustomButton(
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
