import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'service/data_service.dart';
import 'service/auth_service.dart';
import 'service/person_metadata_service.dart';
import 'ui/page/splash/splash_page.dart';
import 'ui/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/repository/schedule_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // 🔥 Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    '🔥 Firebase Initialized. Project ID: ${Firebase.app().options.projectId}',
  );
  debugPrint('🔥 Firebase Options: ${Firebase.app().options.asMap}');

  // Initialize Hive and DataService
  await Get.putAsync(() => DataService().init());
  await Get.putAsync(() => PersonMetadataService().init());
  await Get.putAsync(() => AuthService().init());

  // ⬇️ 여기서 ScheduleRepository 를 GetX DI 에 등록
  Get.put(ScheduleRepository()); // ⬅️ 이 한 줄이 핵심

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '너기',
      theme: AppTheme.light,
      home: const SplashPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
      debugShowCheckedModeBanner: false,
    );
  }
}
