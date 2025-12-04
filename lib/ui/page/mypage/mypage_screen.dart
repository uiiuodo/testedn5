import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/login_page.dart';
import 'my_record_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('마이페이지')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. "Record about me" Card
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyRecordScreen());
                },
                child: Container(
                  width: double.infinity,
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '나에 대한 기록',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF636363),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 2. Account Settings
              _buildSectionHeader('계정 설정'),
              const SizedBox(height: 8),
              _buildSectionContainer([
                _buildListTile(
                  '로그인 정보',
                  onTap: () {
                    // TODO: Navigate to login info
                  },
                ),
              ]),
              const SizedBox(height: 30),

              // 3. Service Settings
              _buildSectionHeader('서비스 설정'),
              const SizedBox(height: 8),
              _buildSectionContainer([
                _buildListTile(
                  '알림 설정',
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  '구독/결제 관리',
                  onTap: () {
                    // TODO: Navigate to subscription
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  '백업',
                  onTap: () {
                    // TODO: Navigate to backup
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  '언어 설정',
                  onTap: () {
                    // TODO: Navigate to language settings
                  },
                ),
              ]),
              const SizedBox(height: 30),

              // 4. Support
              _buildSectionHeader('고객지원'),
              const SizedBox(height: 8),
              _buildSectionContainer([
                _buildListTile(
                  'FAQ',
                  onTap: () {
                    // TODO: Navigate to FAQ
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  '1:1 문의',
                  onTap: () {
                    // TODO: Navigate to inquiry
                  },
                ),
              ]),
              const SizedBox(height: 40),

              // 5. Logout
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement logout logic
                    Get.offAll(() => const LoginPage());
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Color(0xFFFF3B30), // Red color
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFA0A0A0),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2A2A2A),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF636363),
        size: 16,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 0.5,
      thickness: 0.5,
      color: Color(0xFFDBDBDB),
      indent: 16,
      endIndent: 16,
    );
  }
}
