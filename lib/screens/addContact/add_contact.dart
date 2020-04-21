import 'dart:convert';
import 'dart:io';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:covid_tracker/models/in_contact_user.dart';
import 'package:covid_tracker/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  FirebaseApp app;
  FirebaseDatabase database;
  List rawUsers = [];
  String _name;
  String _place;
  String _mobileNumber;
  String _time;
  User user;
  File _image;
  Map<PermissionGroup, PermissionStatus> permissions;

  @override
  void initState() {
    super.initState();
    setupdatabase();
    getPermission();
    getUser();
  }

  getPermission() async {
    permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    String dir;
    File newImage2;
    final myDir = new Directory('/storage/emulated/0/Pictures/covid-tracker');
    myDir.create().then((dir) {
      if (_name != null && _name != '') {
        image
            .copy('${dir.path}/${_name.replaceAll(' ', '_')}.png')
            .then((onValue) {
          newImage2 = onValue;
        });
      } else {
        image
            .copy('${dir.path}/${image.path.split('/')[9]}.png')
            .then((onValue) {
          newImage2 = onValue;
        });
      }
    });

    setState(() {
      _image = image;
    });

    // print(image.)
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('user');
    print(stringValue);
    if (stringValue != null) {
      user = User.fromJson(json.decode(stringValue), '');
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
  }

  updateUser() {
    _time = new DateTime.now().toLocal().toString();
    InContactUser incontactuser = InContactUser(
        name: _name, place: _place, time: _time, mobileNumber: _mobileNumber);
    if (user != null) {
      database
          .reference()
          .child('users/${user.id}/in_contact_users')
          .push()
          .set(incontactuser.toJson());
    }
    final snackBar = SnackBar(
      content: Text('Updated SuccessFully!!, thanks for info.'),
      backgroundColor: CommonColors.green,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    this.setState(() {
      _name = '';
      _place = '';
      _mobileNumber = '';
    });
    _formKey.currentState.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: CommonColors.backgroundColor,
        elevation: 0.0,
        title: Text('Add Visited Persons'),
      ),
      body: Container(
          color: CommonColors.backgroundColor,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 300,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Card(
                      child: Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 400,
                          padding: EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.person),
                                      hintText:
                                          'Name of the person, whom you met',
                                      labelText: 'Name',
                                    ),
                                    onSaved: (String value) {
                                      _name = value;
                                    },
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    onSaved: (String value) {
                                      _place = value;
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.place),
                                      hintText: 'Place of contact',
                                      labelText: 'Place',
                                    ),
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter some text';
                                    //   } else if (value.length > 3) {
                                    //     return 'Enter a valid age';
                                    //   }
                                    //   return '';
                                    // },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.settings_cell),
                                      hintText:
                                          'What is your mobile number(10 digits)',
                                      labelText: 'Mobile Number',
                                    ),
                                    onSaved: (String value) {
                                      _mobileNumber = value;
                                    },
                                    // validator: (value) {
                                    //   if (value.isEmpty) {
                                    //     return 'Please enter some text';
                                    //   } else if (value.length != 10) {
                                    //     return 'Enter a valid mobile number';
                                    //   }
                                    //   return null;
                                    // },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Text(
                                          _image == null
                                              ? 'Take a pic'
                                              : 'image taken successfully',
                                          style: TextStyle(
                                              color: CommonColors.grey68),
                                        ),
                                      ),
                                      FloatingActionButton(
                                        onPressed: () => _image == null
                                            ? getImage()
                                            : print("Already taken"),
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.add_a_photo),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: CustomButton(
                  color: Colors.red,
                  label: "SUBMIT",
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a Snackbar.
                      print('validated');
                      _formKey.currentState.save();
                      _image = null;
                      print(_name);
                      updateUser();
                    }
                  },
                ),
              )
            ],
          )),
    );
  }
}
