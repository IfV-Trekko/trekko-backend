import 'package:app_backend/controller/wrapper/cluster_position.dart';
import 'package:app_backend/controller/wrapper/leg/analyzing_leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/leg/leg_wrapper.dart';
import 'package:app_backend/controller/wrapper/trip_wrapper.dart';
import 'package:app_backend/model/trip/donation_state.dart';
import 'package:app_backend/model/trip/leg.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:fluster/fluster.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

class AnalyzingTripWrapper implements TripWrapper {
  final List<Leg> _legs = [];
  LegWrapper _legWrapper = AnalyzingLegWrapper();

  @override
  Future<double> calculateEndProbability() {
    return Future.microtask(() {
      final fluster = Fluster<ClusterPosition>(
          minZoom: 0,
          maxZoom: 17,
          radius: 150,
          extent: 512,
          nodeSize: 64,
          points: _legs
              .expand((element) => element.trackedPoints
              .map((e) => ClusterPosition(
              latitude: e.latitude, longitude: e.longitude))
              .toList())
              .toList(),
          createCluster:
              (BaseCluster cluster, double longitude, double latitude) {
            return ClusterPosition(
                latitude: latitude, longitude: longitude, clusterId: cluster.id);
          });

      List<double> bounds = [];

      _legs.forEach((leg) {
        leg.trackedPoints.forEach((point) {
          if (bounds.length == 0) {
            bounds.add(point.longitude);
            bounds.add(point.latitude);
            bounds.add(point.longitude);
            bounds.add(point.latitude);
          } else {
            if (point.longitude < bounds[0]) bounds[0] = point.longitude;
            if (point.latitude < bounds[1]) bounds[1] = point.latitude;
            if (point.longitude > bounds[2]) bounds[2] = point.longitude;
            if (point.latitude > bounds[3]) bounds[3] = point.latitude;
          }
        });
      });

      double probability = 0;
      List<ClusterPosition> clusters = fluster.clusters(bounds, 17);


      return probability;
    });
  }

  @override
  Future<void> add(Position position) async {
    double probability = await _legWrapper.calculateEndProbability();
    if (_legWrapper.collectedDataPoints() > 0 && probability > 0.9) {
      _legs.add(await _legWrapper.get());
      _legWrapper = AnalyzingLegWrapper();
    } else {
      _legWrapper.add(position);
    }
  }

  @override
  int collectedDataPoints() {
    return _legs.length;
  }

  @override
  Future<Trip> get() async {
    if (_legWrapper.collectedDataPoints() != 0)
      _legs.add(await _legWrapper.get());

    Trip trip = Trip(
        donationState: DonationState.undefined,
        startTime: _legs[0].trackedPoints[0].timestamp,
        endTime: _legs[_legs.length - 1]
            .trackedPoints[_legs[_legs.length - 1].trackedPoints.length - 1]
            .timestamp,
        comment: null,
        purpose: null,
        legs: []);

    _legs.forEach((element) {
      trip.legs.add(element);
    });
    return Future.value(trip);
  }
}
