import 'package:flutter/services.dart';

class LocationPackage {
  static const MethodChannel _channel =
      const MethodChannel('com.covid.location');

  LocationPackage() {
    _channel.setMethodCallHandler((m) => setupMethodHandler(m));
  }

  setupMethodHandler(m) async {
    String channelName = m.method.trim();
    switch (channelName) {
      case "locationUpdated":
        print(
            "location locationUpdated ${m.arguments['lat']} ${m.arguments['lng']}");
        break;

      default:
    }
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  locationServiceStart(Map locationServiceData) async {
    print("in page background 4=> $locationServiceData");
    await _channel.invokeMethod("locationServiceStart", locationServiceData);
  }

  locationServiceStop() async {
    await _channel.invokeMethod("locationServiceEnd");
  }
}
