import 'package:covid_tracker/routing/routes.dart';
import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  AdminHomeScreen({Key key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  FirebaseApp app;
  FirebaseDatabase database;
  List users = [];
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
      }
    });
  }

  List<Widget> getCards() {
    List<Widget> widgets = [];
    for (int i = 0; i < this.users.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
              '${Routes.viewContactPersons}/${i}',
              arguments: {"userId": i}),
          child: Card(
              color: this.users[i]["is_safe"] ? Colors.green : Colors.red,
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
                        this.users[i]["is_safe"] ? 'SAFE' : 'UNSAFE!!',
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
    return Scaffold(
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
        title: Text('Covid Tracker - Admin'),
      ),
      drawer: DrawerWidget(),
      backgroundColor: Color(0xff2c4260),
      body: this.isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: SingleChildScrollView(
              child: Column(
                children: <Widget>[...getCards()],
              ),
            )),
    );
  }
}
