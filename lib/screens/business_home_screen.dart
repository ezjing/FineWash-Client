import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'business_reservation_management_screen.dart';
import 'business_location_management_screen.dart';
import 'business_schedule_management_screen.dart';
import 'business_dashboard_screen.dart';
import 'business_my_page_screen.dart';

class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '사업자 관리',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '안녕하세요, ${user?.name ?? '사업자'}님',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _MenuCard(
                        icon: Icons.calendar_today_rounded,
                        title: '예약 관리',
                        description: '예약 승인 및 거절',
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessReservationManagementScreen(),
                          ),
                        ),
                      ),
                      _MenuCard(
                        icon: Icons.business_rounded,
                        title: '사업장 관리',
                        description: '사업장 정보 관리',
                        color: AppColors.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessLocationManagementScreen(),
                          ),
                        ),
                      ),
                      _MenuCard(
                        icon: Icons.schedule_rounded,
                        title: '스케줄 관리',
                        description: '사업장 스케줄 설정',
                        color: AppColors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessScheduleManagementScreen(),
                          ),
                        ),
                      ),
                      _MenuCard(
                        icon: Icons.dashboard_rounded,
                        title: '종합 운영현황',
                        description: '대시보드',
                        color: AppColors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessDashboardScreen(),
                          ),
                        ),
                      ),
                      _MenuCard(
                        icon: Icons.person_rounded,
                        title: '마이페이지',
                        description: '설정 및 정보',
                        color: AppColors.yellow,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BusinessMyPageScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: mediaQuery.padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
