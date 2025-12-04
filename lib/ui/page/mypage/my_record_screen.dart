import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyRecordScreen extends StatelessWidget {
  const MyRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              '나에 대한 기록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info
            Row(
              children: const [
                Text(
                  '생년월일',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF919191),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  '1996.08.30',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(30세, 만 29세)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFDEDEDE)),
            const SizedBox(height: 24),

            // Anniversaries
            _buildSectionHeader('기념일', iconColor: const Color(0xFFB0B0B0)),
            const SizedBox(height: 12),
            _buildAnniversaryCard('생일', '8월 30일'),
            const SizedBox(height: 8),
            _buildAnniversaryCard('축일', '8월 23일 → 로사 축일'),
            const SizedBox(height: 30),

            // Memos
            _buildSectionHeader('메모', iconColor: const Color(0xFFB0B0B0)),
            const SizedBox(height: 12),
            _buildMemoCard('표정 때문에 상대가 눈치보는 경우가 종종 발생함\n이점 인지하고 있기'),
            const SizedBox(height: 8),
            _buildMemoCard('5가지 사랑의 언어 테스트\n1위 함께하는 시간, 봉사 나옴'),
            const SizedBox(height: 8),
            _buildMemoCard(
              '최근에 알았는데 피곤하면 텐션이 올라간다\n이때 과장된 행동이나 리액션을 많이 하게 되는 것 같으니 ..\n아주 피곤한 날에는 .. 어디 가지말고 집가서 자는 게 좋을 거 같음 ㅎ',
            ),
            const SizedBox(height: 30),

            // Preferences
            _buildSectionHeader('취향 기록', iconColor: const Color(0xFFB0B0B0)),
            const SizedBox(height: 12),

            // Book Preference
            _buildPreferenceAccordion(
              title: '책',
              likes: '추리소설, SF 판타지, 장편 시리즈 (3권 까지는 괜찮음), 시',
              dislikes: '실용서적/자기계발서, 에세이, 고전문학',
            ),
            const SizedBox(height: 12),

            // Movie Preference
            _buildPreferenceAccordion(
              title: '영화',
              likes:
                  '웨스 앤더슨 감독 영화, 김종관 감독 영화\n영화 아멜리에, 영화 죽은 시인의 사회(동아리), 영화 에에올, 영화 미드나잇 인 파리, 영화 라이언 일병 구하기, 영화 내 사랑\n장르 느와르, 추리, 전쟁영화, 현실적인 영화',
              dislikes:
                  '히어로물, 페이크 다큐 형식 영화, 점프 스케어 공포물, 로맨스물, 너무 비현실적인 동화같은 영화 안 좋아함',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required Color iconColor}) {
    return Row(
      children: [
        Container(width: 9, height: 9, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9D9D9D),
          ),
        ),
      ],
    );
  }

  Widget _buildAnniversaryCard(String title, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Text(
            '$title   ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2A2A2A),
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Color(0xFF2A2A2A),
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildPreferenceAccordion({
    required String title,
    required String likes,
    required String dislikes,
  }) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF404040),
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: true,
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Likes
              const Text(
                '선호',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF00A6FF),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFF00A6FF),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  likes,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF464646),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Dislikes
              const Text(
                '비선호',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6F6F6F),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFF979797),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  dislikes,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF464646),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
