import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';

abstract class ManualTripWrapper extends TripWrapper {

  void triggerEndOnLegEnd();

}