import 'dart:math';

import 'package:geolocator/geolocator.dart' as Geoloc;
import 'package:trekko_backend/controller/analysis/average.dart';
import 'package:trekko_backend/model/position.dart';
import 'package:fling_units/fling_units.dart';

final class PositionUtils {
  static Future<Position> getPosition(Geoloc.LocationAccuracy accuracy) {
    return Geoloc.Geolocator.getCurrentPosition(desiredAccuracy: accuracy)
        .then((value) => Position.fromGeoPosition(value));
  }

  static double calculateDistance(
      double startLat, double startLong, double endLat, double endLong) {
    const double earthRadius = 6371000; // Erdradius in Metern
    double dLat = _toRadians(endLat - startLat);
    double dLong = _toRadians(endLong - startLong);

    startLat = _toRadians(startLat);
    endLat = _toRadians(endLat);

    double a = pow(sin(dLat / 2), 2) +
        pow(sin(dLong / 2), 2) * cos(startLat) * cos(endLat);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  static double distanceBetween(Position start, Position end) {
    return calculateDistance(
        start.latitude, start.longitude, end.latitude, end.longitude);
  }

  static Position getCenter(List<Position> positions, {bool reverse = false}) {
    if (positions.length == 0) throw Exception("Positions may not be empty");
    // This is where the fun begins
    double avgLat =
        AverageCalculation().calculate(positions.map((e) => e.latitude))!;
    double avgLong =
        AverageCalculation().calculate(positions.map((e) => e.longitude))!;

    double? previousDistanceToCenter;
    int? centerPinpointIndex;
    for (int i = positions.length - 1; i >= 0; i--) {
      Position position = positions[i];
      double distanceToCenter = calculateDistance(
          avgLat, avgLong, position.latitude, position.longitude);
      if (previousDistanceToCenter == null) {
        previousDistanceToCenter = distanceToCenter;
        centerPinpointIndex = i;
      } else {
        if (previousDistanceToCenter > distanceToCenter) {
          previousDistanceToCenter = distanceToCenter;
          centerPinpointIndex = i;
        } else {
          break;
        }
      }
    }

    Iterable<Position> centerPositions =
        positions.sublist(0, centerPinpointIndex! + 1);
    return Position(
        longitude: AverageCalculation()
            .calculate(centerPositions.map((e) => e.longitude))!,
        latitude: AverageCalculation()
            .calculate(centerPositions.map((e) => e.latitude))!,
        timestamp: centerPositions.last.timestamp,
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0);
  }

  static double distanceBetweenPoints(List<Position> positions) {
    double distance = 0;
    for (int i = 1; i < positions.length; i++) {
      distance += distanceBetween(positions[i - 1], positions[i]);
    }
    return distance;
  }

  static double maxDistance(List<Position> positions) {
    double max = 0;
    Position anchor = positions[positions.length - 1];
    for (int i = 0; i < positions.length - 1; i++) {
      double distance = distanceBetween(anchor, positions[i]);
      if (distance > max) max = distance;
    }
    return max;
  }

  static List<Position> getFirstIn(Distance radius, List<Position> positions) {
    if (positions.isEmpty) return [];
    List<Position> result = List.empty(growable: true);
    Position anchor = positions[0];
    result.add(anchor);
    for (int i = 1; i < positions.length; i++) {
      double distance = distanceBetween(anchor, positions[i]);
      if (distance > radius.as(meters)) {
        return result;
      }
      result.add(positions[i]);
    }
    return result;
  }

  static List<Position> getPositionIn(
      DateTime start, DateTime end, List<Position> positions) {
    return positions
        .where((p) => p.timestamp.isAfter(start) && p.timestamp.isBefore(end))
        .toList();
  }

  static double holdProbPerRadius(DateTime start, DateTime end,
      Distance expectedDistance, List<Position> positions) {
    List<Position> lastPositions = getPositionIn(start, end, positions);
    double moved = 0;
    if (lastPositions.length != 0)
      moved = PositionUtils.maxDistance(lastPositions);
    // if (moved == 0) return 1;
    return min(expectedDistance.as(meters) / moved, 1);
  }

  static double calculateSingleHoldProbability(DateTime start,
      Duration duration, Distance expectedDistance, List<Position> positions) {
    if (positions.length == 0) return 0;
    DateTime minEnd = start.add(duration);
    return holdProbPerRadius(start, minEnd, expectedDistance, positions);
  }

  static double calculateHoldProbability(
      DateTime latest,
      Duration minDuration,
      Duration maxDuration,
      Distance expectedDistance,
      List<Position> positions) {
    if (positions.length == 0) return 0;
    double minEndProb = calculateSingleHoldProbability(
        latest.subtract(minDuration), minDuration, expectedDistance, positions);
    double maxEndProb = calculateSingleHoldProbability(
        latest.subtract(maxDuration), maxDuration, expectedDistance, positions);
    return (maxEndProb + minEndProb) / 2;
  }

  static Position? checkInOrder(Iterable<Position> positions) {
    Position? previous;
    for (Position position in positions) {
      if (previous != null && previous.timestamp.isAfter(position.timestamp)) {
        return previous;
      }
      previous = position;
    }
    return null;
  }
}
