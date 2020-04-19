import 'package:covid_tracker/utils/custom_validations.dart';

class InContactUser {
  String name;
  String place;
  String time;

  InContactUser({
    this.name,
    this.place,
    this.time,
  });

  factory InContactUser.fromJson(Map<dynamic, dynamic> json) {
    print('got here');
    return InContactUser(
      name: validateMapKey('name', json) ? json["name"] : '',
      place: validateMapKey('place', json) ? json["place"] : '',
      time: validateMapKey('time', json) ? json["time"] : '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": this.name,
        "place": this.place,
        "time": this.time,
      };
}
