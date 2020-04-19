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

  factory Hotspot.fromJson(Map<dynamic, dynamic> json) => Hotspot(
        cases: validateMapKey('cases', json)
            ? int.parse(json["cases"].toString())
            : 0,
        lat: validateMapKey('lat', json)
            ? double.parse(json["lat"].toString())
            : 0.0,
        lng: validateMapKey('lng', json)
            ? double.parse(json["lng"].toString())
            : 0.0,
        radius: validateMapKey('radius', json)
            ? int.parse(json["radius"].toString())
            : 1,
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
