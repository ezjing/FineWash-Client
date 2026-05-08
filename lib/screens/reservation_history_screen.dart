import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../utils/app_colors.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationService>().searchLogic1();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('예약 내역')),
      body: Consumer<ReservationService>(
        builder: (context, reservationService, child) {
          final reservations = reservationService.reservations;

          return RefreshIndicator(
            onRefresh: () => reservationService.searchLogic1(),
            child: reservationService.isLoading && reservations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : reservations.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 64),
                      Icon(
                        Icons.event_note_outlined,
                        size: 56,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '예약 내역이 없습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _ReservationTile(reservation: reservations[index]),
                  ),
          );
        },
      ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final ReservationModel reservation;
  const _ReservationTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final isAffiliate = reservation.busMstIdx != null;
    final statusColor = reservation.isConfirmed
        ? AppColors.success
        : reservation.isCancelled
        ? AppColors.error
        : AppColors.warning;

    final subtitleLines = <String>[
      if ((reservation.date ?? '').isNotEmpty || (reservation.time ?? '').isNotEmpty)
        '${reservation.date ?? ''} ${reservation.time ?? ''}'.trim(),
      if (isAffiliate) '구분: 제휴세차장' else '구분: 출장세차',
      if (!isAffiliate && (reservation.vehicleLocation ?? '').isNotEmpty)
        '차량 위치: ${reservation.vehicleLocation}',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_car_wash_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (reservation.mainOption ?? '예약').trim().isEmpty
                            ? '예약'
                            : (reservation.mainOption ?? '예약'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        reservation.isConfirmed ? '확정' : '취소',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if ((reservation.midOption ?? '').isNotEmpty ||
                    (reservation.subOption ?? '').isNotEmpty)
                  Text(
                    [
                      if ((reservation.midOption ?? '').isNotEmpty)
                        reservation.midOption,
                      if ((reservation.subOption ?? '').isNotEmpty)
                        reservation.subOption,
                    ].whereType<String>().join(' · '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 6),
                ...subtitleLines.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

