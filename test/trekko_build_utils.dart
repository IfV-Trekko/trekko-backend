import 'dart:io';

import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/login_builder.dart';
import 'package:trekko_backend/controller/builder/login_result.dart';
import 'package:trekko_backend/controller/builder/registration_builder.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:trekko_backend/controller/utils/tracking_util.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
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

class CustomPermissionHandlerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.granted;
  }
}

class TrekkoBuildUtils {

  static String getAddress() {
    String ip = "localhost";
    if (Platform.isAndroid) {
      ip = "10.0.2.2";
    } else if (Platform.isMacOS) {
      ip =  "127.0.0.1";
    } else {
      ip =  "localhost";
    }
    return "http://$ip:8080";
  }

  @GenerateMocks([BackgroundLocator])
  Future<void> init() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    await Isar.initializeIsarCore(download: true);
    PathProviderPlatform.instance = MockPathProvider();
    disablePathProviderPlatformOverride = true;
    LocationBackgroundTracking.debug = true;
    PermissionHandlerPlatform.instance = CustomPermissionHandlerPlatform();
  }

  Future<Trekko> loginOrRegister(String email, String password) async {
    await init();
    late String ip = getAddress();
    try {
      return await LoginBuilder.withData(
              projectUrl: ip, email: email, password: password)
          .build();
    } catch (e) {
      if (e is BuildException) {
        if (e.reason == LoginResult.failedNoSuchUser) {
          try {
            return await RegistrationBuilder.withData(
                    projectUrl: ip,
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
    await trekko.signOut(delete: true);
  }
}
