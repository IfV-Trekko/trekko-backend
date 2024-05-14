import 'package:trekko_backend/controller/wrapper/trip_wrapper.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';

abstract class ManualTripWrapper extends TripWrapper {

  void triggerEndOnLegEnd();

  void updateTransportType(TransportType type);

}