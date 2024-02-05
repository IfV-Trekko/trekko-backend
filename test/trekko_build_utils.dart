import 'dart:io';

import 'package:app_backend/controller/builder/authentification_utils.dart';
import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/registration_builder.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return (Directory.systemTemp).path;
  }
}

class MyHttpOverrides extends HttpOverrides {}

class TrekkoBuildUtils {
  Future<void> init() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    await Isar.initializeIsarCore(download: true);
    PathProviderPlatform.instance = MockPathProvider();
    disablePathProviderPlatformOverride = true;
  }

  Future<Trekko> loginOrRegister(String email, String password) async {
    await init();
    late String ip;
    if (Platform.isAndroid) {
      ip = "10.0.2.2";
    } else {
      ip = "localhost";
    }
    try {
      return await LoginBuilder("http://$ip:8080", email, password).build();
    } catch (e) {
      if (e is BuildException) {
        if (e.reason == LoginResult.failedNoSuchUser) {
          try {
            return await RegistrationBuilder(
                    "http://$ip:8080", email, password, password, "12345")
                .build();
          } catch (e) {
            print((e as BuildException).reason);
          }
        }
      }
      rethrow;
    }
  }

  Future<void> close(Trekko trekko) async {
    Profile profile = await trekko.getProfile().first;
    await trekko.terminate();
    await AuthentificationUtils.deleteProfile(
        profile.projectUrl, profile.email);
  }
}
