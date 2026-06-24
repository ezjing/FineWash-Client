import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../services/business_service.dart';
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
  int? _selectedBusMstIdx; // 사업장 선택(필수)
  String _selectedStatusFilter = 'all'; // all, pending, Y, N

  bool _isPendingReservation(ReservationModel reservation) {
    return reservation.contractYn != 'Y' && reservation.contractYn != 'N';
  }

  Future<void> _approveReservation(ReservationModel reservation) async {
    final reservationService = context.read<ReservationService>();
    final messenger = ScaffoldMessenger.of(context);

    if (reservation.date == null ||
        reservation.date!.isEmpty ||
        reservation.time == null ||
        reservation.time!.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('예약 일정 정보가 없습니다. 상세 화면에서 승인해주세요.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 승인'),
        content: Text('예약 #${reservation.resvIdx} 를 승인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('승인'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok = await reservationService.approveReservation(
        resvIdx: reservation.resvIdx,
        date: reservation.date!,
        time: reservation.time!,
      );
      if (ok) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('예약이 승인되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadReservations();
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('예약 승인에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('예약 승인 중 오류가 발생했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectReservation(ReservationModel reservation) async {
    final reservationService = context.read<ReservationService>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 거절'),
        content: Text('예약 #${reservation.resvIdx} 를 거절하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('거절'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok = await reservationService.rejectReservation(
        reservation.resvIdx,
      );
      if (ok) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('예약이 거절되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadReservations();
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('예약 거절에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('예약 거절 중 오류가 발생했습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  Future<void> _loadReservations() async {
    final businessService = Provider.of<BusinessService>(
      context,
      listen: false,
    );

    // 사업장 목록이 없으면 먼저 조회
    if (businessService.businesses.isEmpty) {
      await businessService.searchLogic1();
    }

    // "전체"를 쓰지 않으므로: 첫 사업장을 기본 선택
    if (_selectedBusMstIdx == null && businessService.businesses.isNotEmpty) {
      _selectedBusMstIdx = businessService.businesses.first.busMstIdx;
    }

    // 선택된 사업장이 없으면(사업장 0개) 예약도 비움
    if (_selectedBusMstIdx == null) {
      await businessService.searchLogic5(busMstIdx: -1);
      return;
    }

    await businessService.searchLogic5(busMstIdx: _selectedBusMstIdx);
  }

  List<ReservationModel> _getFilteredReservations(
    List<ReservationModel> reservations,
  ) {
    if (_selectedStatusFilter == 'all') return reservations;
    if (_selectedStatusFilter == 'pending') {
      return reservations.where(_isPendingReservation).toList();
    }
    return reservations
        .where((r) => r.contractYn == _selectedStatusFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('예약 관리')),
      body: Column(
        children: [
          // 필터 영역 (사업장 + 상태)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Consumer<BusinessService>(
              builder: (context, businessService, child) {
                final businesses = businessService.businesses;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사업장 필터 (전체 + 내 사업장 목록)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedBusMstIdx,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: [
                            ...businesses.map(
                              (b) => DropdownMenuItem<int?>(
                                value: b.busMstIdx,
                                child: Text(
                                  b.companyName ?? '사업장 #${b.busMstIdx}',
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            setState(() => _selectedBusMstIdx = value);
                            await _loadReservations();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 상태 필터
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: '전체',
                            isSelected: _selectedStatusFilter == 'all',
                            onTap: () async {
                              setState(() => _selectedStatusFilter = 'all');
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: '대기',
                            isSelected: _selectedStatusFilter == 'pending',
                            onTap: () async {
                              setState(() => _selectedStatusFilter = 'pending');
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: '승인',
                            isSelected: _selectedStatusFilter == 'Y',
                            onTap: () async {
                              setState(() => _selectedStatusFilter = 'Y');
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: '거절',
                            isSelected: _selectedStatusFilter == 'N',
                            onTap: () async {
                              setState(() => _selectedStatusFilter = 'N');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // 예약 목록
          Expanded(
            child: Consumer<BusinessService>(
              builder: (context, businessService, child) {
                if (businessService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservations = _getFilteredReservations(
                  businessService.businessReservations,
                );

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
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + mediaQuery.padding.bottom,
                    ),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return _ReservationCard(
                        reservation: reservation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BusinessReservationDetailScreen(
                                reservation: reservation,
                              ),
                            ),
                          ).then((_) => _loadReservations());
                        },
                        onApprove: _isPendingReservation(reservation)
                            ? () => _approveReservation(reservation)
                            : null,
                        onReject: _isPendingReservation(reservation)
                            ? () => _rejectReservation(reservation)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: mediaQuery.padding.bottom),
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
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _ReservationCard({
    required this.reservation,
    required this.onTap,
    this.onApprove,
    this.onReject,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withAlpha((0.1 * 255).round()),
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
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
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
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
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
                    Icon(
                      Icons.payments,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
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
              if (onReject != null || onApprove != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('승인'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('거절'),
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
