import 'dart:math';

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

  static Future<double> calculateEndProbability(
      Duration pointTimeDiff, double x3Factor, List<Position> positions) {
    return Future.microtask(() {
      if (maxDistance(positions) < 100) return 0;

      // Get the positions of the last x minutes
      List<Position> lastPositions = [];
      for (int i = positions.length - 1; i >= 0; i--) {
        if (positions[i]
            .timestamp
            .isAfter(DateTime.now().subtract(pointTimeDiff))) {
          lastPositions.add(positions[i]);
        } else {
          break;
        }
      }

      // Calculate end probability by the radius of the last positions
      Position anchor = lastPositions[0];
      double averageProbability = 0;
      for (Position position in lastPositions) {
        double distance = distanceBetween(anchor, position);
        double probability = (-1 / (1 * pow(1, x3Factor))) * pow(distance, 3) +
            1; // hell yeah, math
        probability = min(1, max(0, probability));
        averageProbability += probability;
      }
      averageProbability /= lastPositions.length;
      return averageProbability;
    });
  }
}
