import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:croppy/croppy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
// ✅ مطلوب لدعم SQLite على Windows/Linux/macOS
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/get_platform.dart' show pt, PlatformInfo, PTExt;
import 'core/database/db_helper.dart';
import 'core/database/helpers/database_backup_helper.dart';
import 'core/utils/bloc_observer.dart';
import 'di/service_locator.dart' as di;

class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ تهيئة SQLite FFI لـ Windows / Linux / macOS Desktop
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print('✅ sqflite FFI initialized for desktop platform');
    }

    await di.setupServiceLocator();
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      handleError(details.exception, details.stack ?? StackTrace.current);
      originalOnError?.call(details);
    };

    // final zoneSpecification = ZoneSpecification(
    //   handleUncaughtError:
    //       (
    //         Zone self,
    //         ZoneDelegate parent,
    //         Zone zone,
    //         Object error,
    //         StackTrace stackTrace,
    //       ) {
    //         handleError(error, stackTrace);
    //       },
    // );
    // await Zone.current.fork(specification: zoneSpecification).run(() async {
    //   return _futureInit();
    // });
    HttpOverrides.global = MyHttpOverrides();
    final temporaryDirectory = await getTemporaryDirectory();

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(temporaryDirectory.path),
    );
    if (kDebugMode) await HydratedBloc.storage.clear();

    try {
      // ✅ 1. استرجاع النسخة الاحتياطية إن وُجدت قبل فتح القاعدة
      await DBBackupManager().restoreBackupIfExists();

      // ✅ 2. تهيئة القاعدة فعليًا (بعد الاسترجاع)
      final db = await DBHelper().database;
      print('✅ Database initialized successfully');
      final data = await db.query('users');

      if (data.isEmpty) {
        print(
          '⚠️ No permissions found, consider creating permissions or checking seeder.',
        );
      } else {
        print('✅ Found $data permission(s) in the database.');
      }
      // ✅ 3. إنشاء نسخة احتياطية جديدة بعد التأكد من جاهزية القاعدة
      await DBBackupManager().createBackup();
    } catch (e, stack) {
      print('❌ Failed to initialize or restore/create backup: $e');
      print('🪵 Stack trace: $stack');
    }
    await _init();

    await EasyLocalization.ensureInitialized();

    await ScreenUtil.ensureScreenSize();

    Bloc.observer = AppBlocObserver();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void handleError(Object error, StackTrace stackTrace) {
    log('Unhandled error: $error', error: error, stackTrace: stackTrace);
    return FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'AppInitializer',
        context: ErrorDescription('Unhandled error in AppInitializer'),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

Future<void> _init() async {
  pt = PlatformInfo.getCurrentPlatformType();
  if (pt.isNotWeb) croppyForceUseCassowaryDartImpl = true;
}
