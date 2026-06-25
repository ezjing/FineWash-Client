import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reservation_service.dart';
import '../utils/app_colors.dart';
import '../widgets/customer_reservation_list_item.dart';

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
        builder: (context, reservationService, _) {
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
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        CustomerReservationListItem(
                          reservation: reservations[index],
                        ),
                  ),
          );
        },
      ),
    );
  }
}
