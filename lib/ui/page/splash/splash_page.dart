import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';
import '../../../service/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (AuthService.to.isLoggedIn) {
        Get.offAll(() => const HomePage());
      } else {
        Get.off(() => const LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '너기',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '기억해 두면 더 가까워지는 관계가 있습니다',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
