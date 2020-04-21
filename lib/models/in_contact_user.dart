import 'package:covid_tracker/utils/custom_validations.dart';

class InContactUser {
  String name;
  String place;
  String time;
  String mobileNumber;

  InContactUser({
    this.name,
    this.place,
    this.mobileNumber,
    this.time,
  });

  factory InContactUser.fromJson(Map<dynamic, dynamic> json) {
    print('got here');
    return InContactUser(
      name: validateMapKey('name', json) ? json["name"] : '',
      place: validateMapKey('place', json) ? json["place"] : '',
      mobileNumber:
          validateMapKey('mobile_number', json) ? json["mobile_number"] : '',
      time: validateMapKey('time', json) ? json["time"] : '',
    );
  }

  Map<String, dynamic> toJson() => {
        "name": this.name,
        "place": this.place,
        "mobile_number": this.mobileNumber,
        "time": this.time,
      };
}
