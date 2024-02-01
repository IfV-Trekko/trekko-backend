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

  static List<Position> getPositionIn(
      DateTime start, DateTime end, List<Position> positions) {
    return positions
        .where((p) => p.timestamp.isAfter(start) && p.timestamp.isBefore(end))
        .toList();
  }

  static double holdProbPerRadius(DateTime start, DateTime end,
      Distance expectedDistance, List<Position> positions) {
    List<Position> lastPositions = getPositionIn(start, end, positions);
    double moved = PositionUtils.maxDistance(lastPositions);
    return min(expectedDistance.as(meters) / moved, 1);
  }

  static Future<double> calculateHoldProbability(
      DateTime start,
      Duration minDuration,
      Duration maxDuration,
      Distance expectedDistance,
      List<Position> positions) {
    return Future.microtask(() {
      if (positions.length == 0) return 0;
      DateTime minEnd = start.add(maxDuration);
      double minEndProb =
          holdProbPerRadius(start, minEnd, expectedDistance, positions);

      DateTime maxEnd = start.add(maxDuration);
      double maxEndProb =
          holdProbPerRadius(start, maxEnd, expectedDistance, positions);
      return (maxEndProb + minEndProb) / 2;
    });
  }
}
