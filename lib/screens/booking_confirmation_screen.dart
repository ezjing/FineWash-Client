import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/vehicle_model.dart';
import '../utils/app_colors.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;
  final VehicleModel vehicle;

  const BookingConfirmationScreen({super.key, required this.booking, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 48), color: Colors.white,
              child: Column(
                children: [
                  Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success)),
                  const SizedBox(height: 16),
                  const Text('예약 완료', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('예약이 성공적으로 완료되었습니다', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('예약 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 20),
                          _InfoRow(icon: Icons.directions_car_outlined, label: '차량', value: vehicle.displayName),
                          const SizedBox(height: 16),
                          _InfoRow(icon: Icons.auto_awesome_outlined, label: '서비스', value: booking.serviceType),
                          const SizedBox(height: 16),
                          _InfoRow(icon: Icons.calendar_today_outlined, label: '날짜', value: booking.date),
                          const SizedBox(height: 16),
                          _InfoRow(icon: Icons.access_time_outlined, label: '시간', value: booking.time),
                          const SizedBox(height: 16),
                          if (booking.type == BookingType.mobile && booking.address != null) ...[_InfoRow(icon: Icons.location_on_outlined, label: '주소', value: booking.address!), const SizedBox(height: 16)],
                          if (booking.type == BookingType.partner && booking.washLocation != null) ...[_InfoRow(icon: Icons.location_on_outlined, label: '세차장', value: booking.washLocation!), const SizedBox(height: 16)],
                          _InfoRow(icon: Icons.credit_card_outlined, label: '결제 금액', value: '${booking.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', valueColor: AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [Icon(Icons.info_outline, color: AppColors.info), SizedBox(width: 12), Expanded(child: Text('예약 내역은 마이페이지에서 확인하실 수 있습니다', style: TextStyle(fontSize: 14, color: AppColors.info)))]),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
              child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('홈으로 돌아가기')),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: valueColor ?? AppColors.textPrimary))])),
      ],
    );
  }
}

