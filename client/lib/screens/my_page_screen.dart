import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/vehicle_service.dart';
import '../utils/app_colors.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bookingService = Provider.of<BookingService>(context);
    final vehicleService = Provider.of<VehicleService>(context);
    final user = authService.currentUser;
    final bookings = bookingService.bookings;
    final vehicles = vehicleService.vehicles;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('마이페이지'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24), color: Colors.white,
              child: Column(
                children: [
                  Row(children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person_rounded, size: 32, color: AppColors.orange)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.name ?? '사용자', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)), const SizedBox(height: 4), Text(user?.email ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))]))]),
                  const SizedBox(height: 24),
                  Row(children: [_StatItem(label: '예약', value: bookings.length.toString(), color: AppColors.primary), _StatItem(label: '차량', value: vehicles.length.toString(), color: AppColors.purple), _StatItem(label: '쿠폰', value: '0', color: AppColors.orange)]),
                ],
              ),
            ),
            if (bookings.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(24), color: Colors.white, margin: const EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('최근 예약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)), const SizedBox(height: 16), ...bookingService.getRecentBookings().map((booking) => _BookingCard(booking: booking))])),
            const SizedBox(height: 8),
            _MenuSection(title: '예약 관리', items: [_MenuItem(icon: Icons.calendar_today_outlined, label: '예약 내역', count: bookings.length), _MenuItem(icon: Icons.directions_car_outlined, label: '차량 관리', count: vehicles.length), _MenuItem(icon: Icons.notifications_outlined, label: '알림 설정')]),
            const SizedBox(height: 8),
            _MenuSection(title: '혜택', items: [_MenuItem(icon: Icons.credit_card_outlined, label: '쿠폰함'), _MenuItem(icon: Icons.card_giftcard_outlined, label: '이벤트')]),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24), color: Colors.white,
              child: InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('로그아웃'), content: const Text('로그아웃 하시겠습니까?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인'))]));
                  if (confirm == true) { await authService.logout(); vehicleService.clearVehicles(); bookingService.clearBookings(); if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst); }
                },
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, color: AppColors.error), SizedBox(width: 8), Text('로그아웃', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.error))]),
              ),
            ),
            const SizedBox(height: 24),
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
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))]));
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(booking.serviceType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _getStatusColor(booking.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(booking.status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(booking.status))))]), const SizedBox(height: 8), Text('${booking.date} ${booking.time}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)), const SizedBox(height: 4), Text('${booking.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) { case BookingStatus.pending: return AppColors.warning; case BookingStatus.confirmed: return AppColors.info; case BookingStatus.completed: return AppColors.success; case BookingStatus.cancelled: return AppColors.error; }
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(24), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)), const SizedBox(height: 16), ...items.map((item) => InkWell(onTap: () {}, child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [Icon(item.icon, size: 24, color: AppColors.textSecondary), const SizedBox(width: 16), Expanded(child: Text(item.label, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary))), if (item.count != null) ...[Text(item.count.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)), const SizedBox(width: 8)], const Icon(Icons.chevron_right, color: AppColors.textSecondary)]))))]));
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int? count;
  const _MenuItem({required this.icon, required this.label, this.count});
}

