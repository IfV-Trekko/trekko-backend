import 'dart:math';

import 'package:trekko_backend/controller/utils/position_utils.dart';
import 'package:trekko_backend/controller/wrapper/analyzer/leg/transport/position/patternizer.dart';
import 'package:trekko_backend/model/tracking/cache/raw_phone_data_type.dart';
import 'package:trekko_backend/model/tracking/position.dart';
import 'package:trekko_backend/model/tracking/raw_phone_data.dart';

class RepeatingStopsPatternizer implements Patternizer {

  const RepeatingStopsPatternizer();

  @override
  double hasPattern(Iterable<RawPhoneData> data) {
    List<Position> positions = data
        .where((d) => d.getType() == RawPhoneDataType.position)
        .cast<Position>()
        .toList();

    if (positions.length < 2) {
      return 0.0;
    }

    const double distanceThreshold = 50; // meters to consider as a stop
    const double allowedDeviation = 0.2; // 20%
    List<int> stopDurations = [];
    List<double> segmentSpeeds = [];

    int stopStartIndex = -1;
    int lastStopEndIndex = 0;
    for (int i = 1; i < positions.length; i++) { // TODO: Check if works
      if (isStopped(positions[i - 1], positions[i], distanceThreshold)) {
        // Stopped
        if (stopStartIndex == -1) {
          // Just stopped
          segmentSpeeds
              .add(calculateSpeed(positions[lastStopEndIndex], positions[i]));
          stopStartIndex = i - 1;
        }
      } else {
        // Not stopped
        if (stopStartIndex != -1) {
          // Started driving again
          stopDurations.add(positions[i - 1]
              .timestamp
              .difference(positions[stopStartIndex].timestamp)
              .inSeconds);
          stopStartIndex = -1;
          lastStopEndIndex = i - 1;
        }
      }
    }

    if (stopDurations.isEmpty || segmentSpeeds.isEmpty) {
      return 0.0;
    }

    double averageStopDuration =
        stopDurations.reduce((a, b) => a + b) / stopDurations.length;
    double averageSegmentSpeed =
        segmentSpeeds.reduce((a, b) => a + b) / segmentSpeeds.length;

    double stopDurationDeviation = stopDurations
            .map((duration) =>
                (duration - averageStopDuration).abs() / averageStopDuration)
            .reduce((a, b) => a + b) /
        stopDurations.length;
    double segmentSpeedDeviation = segmentSpeeds
            .map((speed) =>
                (speed - averageSegmentSpeed).abs() / averageSegmentSpeed)
            .reduce((a, b) => a + b) /
        segmentSpeeds.length;

    double stopDurationScore =
        (1 - min(stopDurationDeviation, allowedDeviation)) / allowedDeviation;
    double segmentSpeedScore =
        (1 - min(segmentSpeedDeviation, allowedDeviation)) / allowedDeviation;

    return (stopDurationScore + segmentSpeedScore) / 2;
  }

  double calculateSpeed(Position p1, Position p2) {
    double distance = PositionUtils.distanceBetween(p1, p2);
    double timeDiff = p2.timestamp.difference(p1.timestamp).inSeconds as double;
    return distance / timeDiff; // speed in meters per second
  }

  bool isStopped(Position p1, Position p2, double distanceThreshold) {
    return PositionUtils.distanceBetween(p1, p2) < distanceThreshold;
  }
}
