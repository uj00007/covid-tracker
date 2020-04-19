import 'dart:io';

ApiService() {
  // Make sure to replace <YOUR_LOCAL_IP> with
  // the external IP of your computer if you're using Android.
  // Note that we're using port 8888 which is Charles' default.
  // Create a new HttpClient instance.
  // HttpClient httpClient = new HttpClient();
  // if (!kReleaseMode && false) {
  //   String proxy =
  //       Platform.isAndroid ? '192.168.29.135:8888' : 'localhost:8888';

  //   // Hook into the findProxy callback to set
  //   // the client's proxy.
  //   httpClient.findProxy = (uri) {
  //     return "PROXY $proxy;";
  //   };

  //   // This is a workaround to allow Charles to receive
  //   // SSL payloads when your app is running on Android.
  //   httpClient.badCertificateCallback =
  //       ((X509Certificate cert, String host, int port) => Platform.isAndroid);

  //   // Pass your newly instantiated HttpClient to http.IOClient.

  // }
  // myClient = IOClient(httpClient);
}
