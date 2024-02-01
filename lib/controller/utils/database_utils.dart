import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseUtils {
  static Future<Isar> establishConnection(
      List<CollectionSchema<dynamic>> schemas, String name) async {
    var dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      schemas,
      directory: dir.path,
      // name: name,
    );
  }
}
