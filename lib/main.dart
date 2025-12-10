import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'service/data_service.dart';
import 'service/person_metadata_service.dart';
import 'ui/page/splash/splash_page.dart';
import 'ui/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // 🔥 Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive and DataService
  await Get.putAsync(() => DataService().init());
  await Get.putAsync(() => PersonMetadataService().init());

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
      debugShowCheckedModeBanner: false,
    );
  }
}
