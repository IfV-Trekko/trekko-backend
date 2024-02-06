import 'dart:io';

import 'package:app_backend/model/profile/profile.dart';
import 'package:app_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum Databases {
  profile([ProfileSchema]),
  trip([TripSchema]);

  final List<CollectionSchema<dynamic>> schemas;

  const Databases(this.schemas);
}

class DatabaseUtils {
  static Future<String> _getDatabasePath(String name) async {
    String dir = p.join((await getApplicationDocumentsDirectory()).path, name);
    await Directory(dir).create(recursive: true);
    return dir;
  }

  static Future<Isar> openProfiles() async {
    return Isar.open(
      [ProfileSchema],
      directory: await _getDatabasePath("profiles"),
      name: "profile",
    );
  }

  static Future<Isar> openTrips(int profileId) async {
    return Isar.open(
      [TripSchema],
      directory: await _getDatabasePath("$profileId"),
      name: "trip",
    );
  }
}
