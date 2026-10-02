import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyService {
  Future<void> call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri)) {
      throw Exception('Unable to open phone dialer.');
    }
  }

  Future<String> currentLocationMessage() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }

    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }

    if (p == LocationPermission.denied ||
        p == LocationPermission.deniedForever) {
      throw Exception('Location permission not granted.');
    }

    final pos = await Geolocator.getCurrentPosition();
    return 'My current location: https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
  }

  Future<void> openSms(String phone, String body) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': body},
    );
    if (!await launchUrl(uri)) {
      throw Exception('Unable to open SMS.');
    }
  }
}
