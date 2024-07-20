import 'package:trekko_backend/controller/wrapper/data_wrapper.dart';
import 'package:trekko_backend/model/trip/transport_type.dart';
import 'package:trekko_backend/model/trip/trip.dart';

abstract class ManualTripWrapper extends DataWrapper<Trip> {

  void triggerEnd();

  void triggerStartLeg(TransportType nextType);

  TransportType? getTransportType();

}