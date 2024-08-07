import 'dart:io';

import 'package:fling_units/fling_units.dart';
import 'package:trekko_backend/controller/builder/build_exception.dart';
import 'package:trekko_backend/controller/builder/last_login_builder.dart';
import 'package:trekko_backend/controller/builder/login_builder.dart';
import 'package:trekko_backend/controller/builder/login_result.dart';
import 'package:trekko_backend/controller/builder/offline_builder.dart';
import 'package:trekko_backend/controller/builder/registration_builder.dart';
import 'package:trekko_backend/controller/trekko.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:trekko_backend/controller/utils/logging.dart';
import 'package:trekko_backend/controller/utils/trip_builder.dart';
import 'package:trekko_backend/model/log/log_level.dart';
import 'package:trekko_backend/model/trip/trip.dart';

import 'tracking_test_util.dart';

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

class TrekkoTestUtils {
  static const String email = "temp_test_account@web.de";
  static const String password = "1aA!hklj32r4hkjl324r";
  static final Trip default_trip = TripBuilder()
      .stay(Duration(hours: 1))
      .move(true, Duration(minutes: 10), 500.meters)
      .stay(Duration(minutes: 5))
      .move(false, Duration(minutes: 10), 500.meters)
      .stay(Duration(hours: 1))
      .build();

  static String getAddress() {
    String ip = "localhost";
    if (Platform.isAndroid) {
      ip = "10.0.2.2";
    } else if (Platform.isMacOS) {
      ip = "127.0.0.1";
    } else {
      ip = "localhost";
    }
    return "http://$ip:8080";
  }

  static Future<void> clear() async {
    late String ip = getAddress();
    try {
      Trekko lastLogin = await LastLoginBuilder().build();
      await lastLogin.signOut(delete: true);

      Trekko loggedIn = await LoginBuilder.withData(
              projectUrl: ip, email: email, password: password)
          .build();
      await loggedIn.signOut(delete: true);
    } catch (e) {
      if (e is BuildException) {
        if (e.reason == LoginResult.failedNoSuchUser ||
            e.reason == LoginResult.failedNoConnection) {
          return;
        }
      }
      rethrow;
    }
  }

  static Future<Trekko> register(String ip) async {
    return await RegistrationBuilder.withData(
            projectUrl: ip,
            email: email,
            password: password,
            passwordConfirmation: password,
            code: "12345")
        .build();
  }

  static Future<void> init() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    await Isar.initializeIsarCore(download: true);
    PathProviderPlatform.instance = MockPathProvider();
    PermissionHandlerPlatform.instance = CustomPermissionHandlerPlatform();
    await TrackingTestUtil.init();
    Logging.loggingHooks.add((e) {
      if (e.key != LogLevel.error) return;
      fail("Received error: ${e.value}");
    });
  }

  static Future<Trekko> initTrekko(
      {bool signOut = true, bool initAll = true, online = false}) async {
    if (initAll && signOut) {
      await init();
    }
    if (!online) {
      return OfflineBuilder().build();
    }

    late String ip = getAddress();
    try {
      Trekko loggedIn = await LoginBuilder.withData(
              projectUrl: ip, email: email, password: password)
          .build();
      if (signOut) {
        await loggedIn.signOut(delete: true);
        return register(ip);
      } else {
        return loggedIn;
      }
    } catch (e) {
      if (e is BuildException) {
        if (e.reason == LoginResult.failedNoSuchUser) {
          return register(ip);
        }
      }
      rethrow;
    }
  }

  static Future<void> close(Trekko trekko) async {
    await trekko.signOut(delete: true);
  }
}
