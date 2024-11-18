import 'package:sensors_plus/sensors_plus.dart';

class SensorHelper {
  static Future<void> detectTilt(Function onTiltDown, Function onTiltUp) async {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      if (event.z > 8.0) {
        onTiltDown();
      } else if (event.z < -8.0) {
        onTiltUp();
      }
    });
  }
}
