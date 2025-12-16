import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../service/auth_service.dart';
import '../home/home_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        '알림',
        '이메일과 비밀번호를 입력해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    await AuthService.to.signInWithEmail(email, password);
    if (AuthService.to.isLoggedIn) {
      Get.offAll(() => const HomePage());
    }
  }

  void _handleGuestLogin() async {
    await AuthService.to.signInAnonymously();
    if (AuthService.to.isGuest) {
      Get.offAll(() => const HomePage());
      Get.snackbar(
        '알림',
        '둘러보기 모드로 진입했습니다. 데이터 저장이 제한됩니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _showPreparationToast() {
    Get.snackbar(
      '알림',
      '준비 중인 기능입니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  '기록을 위해 로그인하기',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                _buildTextField(controller: _emailController, hintText: '이메일'),
                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: '비밀번호',
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Text (SignUp | Guest)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignUpPage());
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '|',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleGuestLogin,
                      child: const Text(
                        '우선 둘러보기',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // SNS Login Label
                const Text(
                  'SNS로 가입하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
                const SizedBox(height: 12),

                // SNS Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSnsIcon(
                      onTap: _showPreparationToast,
                      child: const Icon(
                        Icons.g_mobiledata,
                        size: 32,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildSnsIcon(
                      onTap: _showPreparationToast,
                      child: const Text(
                        'N',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF03C75A), // Naver Green
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    _buildSnsIcon(
                      onTap: _showPreparationToast,
                      child: const Icon(
                        Icons.chat_bubble,
                        size: 24,
                        color: Color(0xFFFEE500),
                      ), // Kakao Yellow-ish
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
          border: InputBorder.none,
          isDense: true,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildSnsIcon({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
