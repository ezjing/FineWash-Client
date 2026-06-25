import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../services/vehicle_service.dart';
import 'reservation_history_screen.dart';
import 'vehicle_management_screen.dart';
import '../utils/app_colors.dart';
import '../widgets/customer_reservation_list_item.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;

    // 마이페이지 진입 시 예약/차량 카운트가 바로 보이도록 1회 조회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReservationService>().searchLogic1();
      context.read<VehicleService>().searchLogic1();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reservationService = Provider.of<ReservationService>(context);
    final vehicleService = Provider.of<VehicleService>(context);
    final user = authService.currentUser;
    final reservations = reservationService.reservations;
    final vehicles = vehicleService.vehicles;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.orange.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? '사용자',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatItem(
                        label: '예약',
                        value: reservations.length.toString(),
                        color: AppColors.primary,
                      ),
                      _StatItem(
                        label: '차량',
                        value: vehicles.length.toString(),
                        color: AppColors.purple,
                      ),
                      _StatItem(
                        label: '쿠폰',
                        value: '0',
                        color: AppColors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (reservations.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '최근 예약',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...reservationService.getRecentReservations().map(
                      (reservation) => CustomerReservationListItem(
                        reservation: reservation,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _MenuSection(
              title: '예약 관리',
              items: [
                _MenuItem(
                  icon: Icons.calendar_today_outlined,
                  label: '예약 내역',
                  count: reservations.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReservationHistoryScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.directions_car_outlined,
                  label: '차량 관리',
                  count: vehicles.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehicleManagementScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(icon: Icons.notifications_outlined, label: '알림 설정'),
              ],
            ),
            const SizedBox(height: 8),
            _MenuSection(
              title: '혜택',
              items: [
                _MenuItem(icon: Icons.credit_card_outlined, label: '쿠폰함'),
                _MenuItem(icon: Icons.card_giftcard_outlined, label: '이벤트'),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('로그아웃'),
                      content: const Text('로그아웃 하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await authService.logout();
                    vehicleService.clearVehicles();
                    reservationService.clearReservations();
                    if (context.mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: bottomPadding + 24),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(item.icon, size: 24, color: AppColors.textSecondary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (item.count != null) ...[
                    Text(
                      item.count.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback? onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.count,
    this.onTap,
  });
}
