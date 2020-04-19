import 'dart:convert';

import 'package:covid_tracker/models/hotspot.dart';
import 'package:covid_tracker/models/in_contact_user.dart';
import 'package:covid_tracker/utils/custom_validations.dart';

class User {
  String id;
  String name;
  String state;
  String token;
  Hotspot nearestHotspot;
  String mobileNumber;
  bool isInfected;
  bool isSafe;
  bool isAdmin;
  String emailId;
  String city;
  int age;
  List<InContactUser> inContactUsers;

  User({
    this.id = '',
    this.name = '',
    this.state = '',
    this.token = '',
    this.nearestHotspot,
    this.mobileNumber = '',
    this.isInfected = false,
    this.isSafe = true,
    this.isAdmin = false,
    this.emailId = '',
    this.city = '',
    this.age = 0,
    this.inContactUsers,
  });

  factory User.fromRawJson(String str) =>
      User.fromJson(json.decode(str), json.decode(str)["id"]);

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<dynamic, dynamic> json, id) {
    // print('got here');
    // print(json["in_contact_users"]);
    // Map x = json["in_contact_users"];
    // for (var i in x.values) {
    //   print(i.runtimeType);
    // }

    return User(
      id: id != '' ? id : validateMapKey('id', json) ? json["id"] : '',
      name: validateMapKey('name', json) ? json["name"] : '',
      state: validateMapKey('state', json) ? json["state"] : '',
      token: validateMapKey('token', json) ? json["token"] : '',
      nearestHotspot: validateMapKey('nearest_hotspot', json)
          ? Hotspot.fromJson(json["nearest_hotspot"])
          : null,
      mobileNumber:
          validateMapKey('mobile_number', json) ? json["mobile_number"] : '',
      isInfected:
          validateMapKey('is_infected', json) ? json["is_infected"] : false,
      isSafe: validateMapKey('is_safe', json) ? json["is_safe"] : true,
      isAdmin: validateMapKey('is_admin', json) ? json["is_admin"] : false,
      emailId: validateMapKey('email_id', json) ? json["email_id"] : '',
      city: validateMapKey('city', json) ? json["city"] : '',
      age: validateMapKey('age', json) ? json["age"] : 0,
      inContactUsers: validateMapKey('in_contact_users', json)
          ? getContactUsers(json['in_contact_users'])
          : [],
    );
  }
  static List<InContactUser> getContactUsers(data) {
    List<InContactUser> users = [];
    for (var i in data.values) {
      // print(i.runtimeType);
      users.add(InContactUser.fromJson(i));
    }
    return users;
  }

  Map<String, dynamic> toJson() => {
        "name": this.name,
        "state": this.state,
        "token": this.token,
        "nearest_hotspot":
            this.nearestHotspot != null ? this.nearestHotspot.toJson() : {},
        "mobile_number": this.mobileNumber,
        "is_infected": this.isInfected,
        "is_safe": this.isSafe,
        "is_admin": this.isAdmin,
        "email_id": this.emailId,
        "city": this.city,
        "age": this.age,
        // "in_contact_users": this.inContactUsers != null
        //     ? List<dynamic>.from(this.inContactUsers.map((x) => x.toJson()))
        //     : null,
      };
}
