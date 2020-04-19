import 'package:covid_tracker/utils/custom_validations.dart';

class Hotspot {
  int cases;
  double lat;
  double lng;
  int radius;
  String name;

  Hotspot({
    this.cases,
    this.lat,
    this.lng,
    this.radius,
    this.name,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json) => Hotspot(
        cases: validateMapKey('cases', json) ? json["cases"] : 0,
        lat: validateMapKey('lat', json) ? json["lat"].toDouble() : 0.0,
        lng: validateMapKey('lng', json) ? json["lng"].toDouble() : 0.0,
        radius: validateMapKey('radius', json) ? json["radius"] : 1,
        name: validateMapKey('name', json) ? json["name"] : '',
      );

  Map<String, dynamic> toJson() => {
        "cases": this.cases,
        "lat": this.lat,
        "lng": this.lng,
        "radius": this.radius,
        "name": this.name,
      };
}
