import 'dart:math';

import 'package:fling_units/fling_units.dart';
import 'package:geolocator/geolocator.dart';

final class PositionUtils {
  static double distanceBetween(Position a, Position b) {
    return Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
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
    List<Position> result = List.empty(growable: true);
    Position anchor = positions[0];
    result.add(anchor);
    for (int i = 1; i < positions.length; i++) {
      Distance distance = distanceBetween(anchor, positions[i]).meters;
      if (distance > radius) {
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

  static Future<double> calculateSingleHoldProbability(DateTime start,
      Duration duration, Distance expectedDistance, List<Position> positions) {
    return Future.microtask(() {
      if (positions.length == 0) return 0;
      DateTime minEnd = start.add(duration);
      return holdProbPerRadius(start, minEnd, expectedDistance, positions);
    });
  }

  static Future<double> calculateHoldProbability(
      DateTime start,
      Duration minDuration,
      Duration maxDuration,
      Distance expectedDistance,
      List<Position> positions) {
    return Future.microtask(() async {
      if (positions.length == 0) return 0;
      double minEndProb = await calculateSingleHoldProbability(
          start, minDuration, expectedDistance, positions);
      double maxEndProb = await calculateSingleHoldProbability(
          start, maxDuration, expectedDistance, positions);
      return (maxEndProb + minEndProb) / 2;
    });
  }
}
