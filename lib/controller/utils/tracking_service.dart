import 'package:background_location/background_location.dart';
import 'package:trekko_backend/model/position.dart';

class TrackingService {
  static bool debug = false;
  static Function(Function(Position))? debugCallback;

  static void startLocationService(int interval) {
    if (debug) return;
    BackgroundLocation.setAndroidConfiguration(interval);
    BackgroundLocation.startLocationService();
  }

  static void stopLocationService() {
    if (debug) return;
    BackgroundLocation.stopLocationService();
  }

  static void getLocationUpdates(Function(Position) locationCallback) {
    if (debug) {
      debugCallback?.call(locationCallback);
      return;
    }

    BackgroundLocation.getLocationUpdates(
        (location) => locationCallback(Position.fromLocation(location)));
  }
}
