import 'package:covid_tracker/screens/drawer/drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ViewContactPersonsScreen extends StatefulWidget {
  final userId;

  const ViewContactPersonsScreen({Key key, this.userId}) : super(key: key);

  @override
  _ViewContactPersonsScreenState createState() =>
      _ViewContactPersonsScreenState();
}

class _ViewContactPersonsScreenState extends State<ViewContactPersonsScreen> {
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
    print(widget.userId);
    database
        .reference()
        .child('users/${widget.userId}')
        .once()
        .then((DataSnapshot snapshot) {
      // print('value ${snapshot.value}');
      if (snapshot.value != null &&
          snapshot.value['in_contact_users'] != null) {
        var temp = [];
        for (var user in snapshot.value['in_contact_users'].values) {
          temp.add(user);
        }

        temp.sort((a, b) {
          return DateTime.parse(b['time']).compareTo(DateTime.parse(a['time']));
        });

        this.setState(() {
          this.users = temp;
          this.isLoading = false;
        });
      } else {
        this.setState(() {
          this.isLoading = false;
        });
      }
    });
  }

  List<Widget> getCards() {
    List<Widget> widgets = [];
    if (this.users != null) {
      for (var user in this.users) {
        widgets.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              color: Colors.white,
              child: Container(
                  // height: 100,
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(user["name"],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600)),
                            Text('Place: ${user['place']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.normal)),
                            Text(
                                'Mobile: ${user['mobile_number'] != null ? user['mobile_number'] : ''}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.normal)),
                            Text('Time: ${user['time']}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                    ],
                  ))),
        ));
      }
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
        title: Text('Visited Persons List'),
      ),
      // drawer: DrawerWidget(),
      backgroundColor: Color(0xff2c4260),
      body: Container(
        child: this.isLoading
            ? Center(child: CircularProgressIndicator())
            : this.users != null && this.users.isNotEmpty
                ? Container(
                    child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[...getCards()],
                    ),
                  ))
                : Center(
                    child: Text('No Visited users.',
                        style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
