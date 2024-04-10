import 'dart:io';

import 'package:trekko_backend/model/cache_object.dart';
import 'package:trekko_backend/model/profile/profile.dart';
import 'package:trekko_backend/model/tracking_options.dart';
import 'package:trekko_backend/model/trip/trip.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum Databases {
  profile("profile", [ProfileSchema]),
  trip("trip", [TripSchema], needsExtraParams: true),
  cache("location_cache", [CacheObjectSchema, TrackingOptionsSchema]);

  final String name;
  final List<CollectionSchema<dynamic>> schemas;
  final bool needsExtraParams;

  const Databases(this.name, this.schemas, {this.needsExtraParams = false});

  Future<String> _getDatabasePath(String name) async {
    String dir = p.join((await getApplicationDocumentsDirectory()).path, name);
    await Directory(dir).create(recursive: true);
    return dir;
  }

  Future<Isar> _open({String? path = null}) async {
    if (needsExtraParams && path == null) {
      throw Exception("This database needs extra parameters");
    }
    return Isar.open(
      schemas,
      directory: await _getDatabasePath(path ?? name),
      name: this.name,
    );
  }

  Future<Isar> getInstance({String? path}) async {
    Isar? isar = Isar.getInstance(name);
    if (isar == null || !isar.isOpen) {
      isar = await _open(path: path);
    }
    return isar;
  }
}
