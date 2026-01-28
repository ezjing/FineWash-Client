import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../utils/app_colors.dart';
import 'business_reservation_detail_screen.dart';

class BusinessReservationManagementScreen extends StatefulWidget {
  const BusinessReservationManagementScreen({super.key});

  @override
  State<BusinessReservationManagementScreen> createState() =>
      _BusinessReservationManagementScreenState();
}

class _BusinessReservationManagementScreenState
    extends State<BusinessReservationManagementScreen> {
  String _selectedFilter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  Future<void> _loadReservations() async {
    final reservationService =
        Provider.of<ReservationService>(context, listen: false);
    await reservationService.searchLogic1();
  }

  List<ReservationModel> _getFilteredReservations(
      List<ReservationModel> reservations) {
    switch (_selectedFilter) {
      case 'pending':
        return reservations
            .where((r) => r.contractYn != 'Y' && r.contractYn != 'N')
            .toList();
      case 'approved':
        return reservations.where((r) => r.contractYn == 'Y').toList();
      case 'rejected':
        return reservations.where((r) => r.contractYn == 'N').toList();
      default:
        return reservations;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 관리'),
      ),
      body: Column(
        children: [
          // 필터 탭
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '대기중',
                  isSelected: _selectedFilter == 'pending',
                  onTap: () => setState(() => _selectedFilter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '승인',
                  isSelected: _selectedFilter == 'approved',
                  onTap: () => setState(() => _selectedFilter = 'approved'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '거절',
                  isSelected: _selectedFilter == 'rejected',
                  onTap: () => setState(() => _selectedFilter = 'rejected'),
                ),
              ],
            ),
          ),
          // 예약 목록
          Expanded(
            child: Consumer<ReservationService>(
              builder: (context, reservationService, child) {
                if (reservationService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservations = _getFilteredReservations(
                    reservationService.reservations);

                if (reservations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '예약 내역이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadReservations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return _ReservationCard(
                        reservation: reservation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BusinessReservationDetailScreen(
                                reservation: reservation,
                              ),
                            ),
                          ).then((_) => _loadReservations());
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onTap;

  const _ReservationCard({
    required this.reservation,
    required this.onTap,
  });

  String _getStatusText() {
    if (reservation.contractYn == 'Y') {
      return '승인됨';
    } else if (reservation.contractYn == 'N') {
      return '거절됨';
    } else {
      return '대기중';
    }
  }

  Color _getStatusColor() {
    if (reservation.contractYn == 'Y') {
      return AppColors.success;
    } else if (reservation.contractYn == 'N') {
      return AppColors.error;
    } else {
      return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '예약 #${reservation.resvIdx}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (reservation.date != null && reservation.time != null)
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '${reservation.date} ${reservation.time}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              if (reservation.vehicleLocation != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reservation.vehicleLocation!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (reservation.paymentAmount != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payments,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '${reservation.paymentAmount!.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
