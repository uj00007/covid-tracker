import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:covid_tracker/utils/exter_link_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
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
    getUsers();
  }

  getUsers() {
    this.setState(() {
      this.isLoading = true;
    });
    database.reference().child('users').once().then((DataSnapshot snapshot) {
      // print('value ${snapshot.value}');
      if (snapshot.value != null) {
        this.setState(() {
          this.users = snapshot.value;
          this.isLoading = false;
        });
        getCounts();
      }
    });
  }

  getCounts() {
    var blue = 0, red = 0, yellow = 0;
    for (int i = 0; i < this.users.length; i++) {
      this.users[i]["zone"] != null
          ? this.users[i]["zone"] == 'blue'
              ? blue += 1
              : this.users[i]["zone"] == 'yellow' ? yellow += 1 : red += 1
          : this.users[i]["is_safe"] ? blue += 1 : red += 1;
    }
    this.setState(() {
      this.blueCount = blue;
      this.redCount = red;
      this.yellowCount = yellow;
    });
  }

  List<Widget> getCards() {
    List<Widget> widgets = [];
    for (int i = 0; i < this.users.length; i++) {
      var msg = '';
      msg = this.users[i]["zone"] != null
          ? this.users[i]["zone"] == 'blue'
              ? 'SAFE'
              : this.users[i]["zone"] == 'yellow' ? 'CAUTION' : 'UNSAFE!!'
          : this.users[i]["is_safe"] ? 'SAFE' : 'UNSAFE!!';

      widgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
              '${Routes.viewContactPersons}/${i}',
              arguments: {"userId": i}),
          child: Card(
              color: this.users[i]["zone"] != null
                  ? this.users[i]["zone"] == 'blue'
                      ? Colors.blue
                      : this.users[i]["zone"] == 'yellow'
                          ? Colors.yellow
                          : Colors.red
                  : this.users[i]["is_safe"] ? Colors.blue : Colors.red,
              child: Container(
                  // height: 100,
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(users[i]["name"],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w600)),
                          Text('Mob: ${users[i]["mobile_number"]}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.normal)),
                          Text(users[i]["email_id"],
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
                                Card(
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
                                Card(
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
                                Card(
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
                              ],
                            ),
                          )
                        ],
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
