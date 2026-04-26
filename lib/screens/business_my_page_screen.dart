import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class BusinessMyPageScreen extends StatelessWidget {
  const BusinessMyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 사용자 정보 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? '사업자',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // 메뉴 리스트
            _MenuSection(
              title: '예약 관리',
              items: [
                _MenuItem(
                  icon: Icons.calendar_today,
                  title: '예약',
                  onTap: () {
                    // TODO: 예약 화면으로 이동
                  },
                ),
                _MenuItem(
                  icon: Icons.history,
                  title: '예약내역',
                  onTap: () {
                    // TODO: 예약내역 화면으로 이동
                  },
                ),
              ],
            ),
            _MenuSection(
              title: '정보',
              items: [
                _MenuItem(
                  icon: Icons.info_outline,
                  title: '서비스 안내',
                  onTap: () {
                    // TODO: 서비스 안내 화면으로 이동
                  },
                ),
                _MenuItem(
                  icon: Icons.location_on,
                  title: '지점안내',
                  onTap: () {
                    // TODO: 지점안내 화면으로 이동
                  },
                ),
              ],
            ),
            _MenuSection(
              title: '혜택',
              items: [
                _MenuItem(
                  icon: Icons.card_giftcard,
                  title: '상품권',
                  onTap: () {
                    // TODO: 상품권 화면으로 이동
                  },
                ),
                _MenuItem(
                  icon: Icons.local_offer,
                  title: '쿠폰',
                  onTap: () {
                    // TODO: 쿠폰 화면으로 이동
                  },
                ),
                _MenuItem(
                  icon: Icons.celebration,
                  title: '이벤트',
                  onTap: () {
                    // TODO: 이벤트 화면으로 이동
                  },
                ),
              ],
            ),
            _MenuSection(
              title: '쇼핑',
              items: [
                _MenuItem(
                  icon: Icons.shopping_bag,
                  title: '쇼핑몰',
                  onTap: () {
                    // TODO: 쇼핑몰 화면으로 이동
                  },
                ),
              ],
            ),
            _MenuSection(
              title: '고객지원',
              items: [
                _MenuItem(
                  icon: Icons.notifications,
                  title: '공지사항',
                  onTap: () {
                    // TODO: 공지사항 화면으로 이동
                  },
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Q&A',
                  onTap: () {
                    // TODO: Q&A 화면으로 이동
                  },
                ),
                _MenuItem(
                  icon: Icons.support_agent,
                  title: '고객센터',
                  onTap: () {
                    // TODO: 고객센터 화면으로 이동
                  },
                ),
              ],
            ),
            _MenuSection(
              title: '서비스',
              items: [
                _MenuItem(
                  icon: Icons.directions_car,
                  title: '법인차량관리/제휴 구독서비스',
                  onTap: () {
                    // TODO: 법인차량관리/제휴 구독서비스 화면으로 이동
                  },
                ),
              ],
            ),
            // 문의 정보
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '문의하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ContactButton(
                        icon: Icons.phone,
                        label: '전화',
                        onTap: () {
                          // TODO: 전화 걸기
                        },
                      ),
                      const SizedBox(width: 16),
                      _ContactButton(
                        icon: Icons.chat_bubble_outline,
                        label: '카카오톡',
                        onTap: () {
                          // TODO: 카카오톡 채널 열기
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('정말 로그아웃하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await authService.logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('로그아웃'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
