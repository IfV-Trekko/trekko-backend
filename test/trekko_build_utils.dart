import 'dart:io';

import 'package:app_backend/controller/builder/authentification_utils.dart';
import 'package:app_backend/controller/builder/build_exception.dart';
import 'package:app_backend/controller/builder/login_builder.dart';
import 'package:app_backend/controller/builder/login_result.dart';
import 'package:app_backend/controller/builder/registration_builder.dart';
import 'package:app_backend/controller/trekko.dart';
import 'package:app_backend/controller/utils/tracking_util.dart';
import 'package:app_backend/model/profile/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:background_locator_2/background_locator.dart';

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

  @GenerateMocks([BackgroundLocator])
  Future<void> init() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    await Isar.initializeIsarCore(download: true);
    PathProviderPlatform.instance = MockPathProvider();
    disablePathProviderPlatformOverride = true;
    LocationBackgroundTracking.debug = true;
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
      return await LoginBuilder.withData(
              projectUrl: "http://$ip:8080", email: email, password: password)
          .build();
    } catch (e) {
      if (e is BuildException) {
        if (e.reason == LoginResult.failedNoSuchUser) {
          try {
            return await RegistrationBuilder.withData(
                    projectUrl: "http://$ip:8080",
                    email: email,
                    password: password,
                    passwordConfirmation: password,
                    code: "12345")
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
