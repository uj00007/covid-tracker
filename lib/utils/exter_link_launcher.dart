import 'package:url_launcher/url_launcher.dart';

class ExternalLink {
  static launchURL() async {
    const url = 'https://www.covid19india.org/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
