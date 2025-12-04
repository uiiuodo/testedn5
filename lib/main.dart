import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'service/data_service.dart';
import 'ui/page/splash/splash_page.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Initialize Hive and DataService
  await Get.putAsync(() => DataService().init());

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
