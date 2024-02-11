import 'dart:math';

import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

final class PositionUtils {
  static double distanceBetween(Position a, Position b) {
    return Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
  }

  static Position getCenter(List<Position> positions) {
    if (positions.length == 0) throw Exception("Positions may not be empty");
    // This is where the fun begins
    double sumLat =
        positions.map((e) => e.latitude).reduce((p0, p1) => p0 + p1) /
            positions.length;
    double sumLong =
        positions.map((e) => e.longitude).reduce((p0, p1) => p0 + p1) /
            positions.length;

    double? previousDistanceToCenter;
    Position? tripStart;
    for (int i = positions.length - 1; i >= 0; i--) {
      Position position = positions[i];
      double distanceToCenter = Geolocator.distanceBetween(
          sumLat, sumLong, position.latitude, position.longitude);
      if (previousDistanceToCenter == null) {
        previousDistanceToCenter = distanceToCenter;
        tripStart = position;
      } else {
        if (previousDistanceToCenter > distanceToCenter) {
          previousDistanceToCenter = distanceToCenter;
          tripStart = position;
        } else {
          break;
        }
      }
    }

    return Position(
        longitude: tripStart!.longitude,
        latitude: tripStart.latitude,
        timestamp: tripStart.timestamp,
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
}
