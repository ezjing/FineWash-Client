import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/reservation_model.dart';
import '../services/business_service.dart';
import 'business_room_register_screen.dart';

class BusinessLocationDetailScreen extends StatefulWidget {
  /// 사업장 마스터 인덱스 (수정 등에 사용)
  final int locationId;
  /// 룸(DTL) 인덱스 - 있으면 해당 룸 상세(룸명, 예약, 매출) 표시
  final int? roomId;

  const BusinessLocationDetailScreen({
    super.key,
    required this.locationId,
    this.roomId,
  });

  @override
  State<BusinessLocationDetailScreen> createState() =>
      _BusinessLocationDetailScreenState();
}

class _BusinessLocationDetailScreenState
    extends State<BusinessLocationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  @override
  void didUpdateWidget(covariant BusinessLocationDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId) {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    final businessService = context.read<BusinessService>();
    if (widget.roomId != null) {
      businessService.clearCurrentRoom();
      await businessService.getRoomDetail(widget.roomId!);
    } else {
      businessService.clearCurrentBusiness();
      await businessService.getBusinessDetail(widget.locationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomId = widget.roomId;
    final isRoomMode = roomId != null;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<BusinessService>(
          builder: (context, businessService, _) {
            if (isRoomMode && businessService.currentRoom != null) {
              return Text(
                businessService.currentRoom!.roomName ?? '룸',
              );
            }
            if (!isRoomMode && businessService.currentBusiness != null) {
              return Text(
                businessService.currentBusiness!.companyName ?? '사업장',
              );
            }
            return const Text('로딩 중...');
          },
        ),
      ),
      body: isRoomMode ? _buildRoomBody() : _buildMasterBody(),
    );
  }

  /// 룸(DTL) 기준: 룸 정보 + 예약 내역 + 매출
  Widget _buildRoomBody() {
    return Consumer<BusinessService>(
      builder: (context, businessService, _) {
        if (businessService.isLoading &&
            businessService.currentRoom == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final room = businessService.currentRoom;
        if (room == null) {
          return const Center(
            child: Text('룸 정보를 찾을 수 없습니다.'),
          );
        }
        final reservations = businessService.roomReservations;
        final totalRevenue = businessService.roomTotalRevenue;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DTL(룸) 정보 카드
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '룸 정보',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: '룸 수정',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final saved = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BusinessRoomRegisterScreen(
                                    busMstIdx: widget.locationId,
                                    busDtlIdx: room.busDtlIdx,
                                    initialRoomName: room.roomName,
                                    initialActiveYn: room.activeYn,
                                    initialStartDate: room.startDate,
                                    initialEndDate: room.endDate,
                                  ),
                                ),
                              );
                              if (saved == true && mounted) {
                                _loadDetail();
                              }
                            },
                          ),
                          IconButton(
                            tooltip: '룸 삭제',
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.error,
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('룸 삭제'),
                                  content: Text(
                                    '"${room.roomName ?? '-'}" 룸을 삭제하시겠습니까?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('취소'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                      ),
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok != true || !mounted) return;

                              final businessService =
                                  context.read<BusinessService>();
                              final deleted = await businessService.deleteRoom(
                                busDtlIdx: room.busDtlIdx,
                              );
                              if (!mounted) return;
                              if (deleted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('룸이 삭제되었습니다')),
                                );
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('룸 삭제에 실패했습니다')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.meeting_room,
                        label: '룸명',
                        value: room.roomName ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.toggle_on,
                        label: '상태',
                        value: room.isActive ? '활성' : '비활성',
                      ),
                      if (room.startDate != null || room.endDate != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: '운영 기간',
                          value: [
                            room.startDate,
                            room.endDate,
                          ].whereType<String>().join(' ~ '),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 예약 건수 / 매출 요약
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today,
                          label: '예약 건수',
                          value: '${reservations.length}건',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.payments,
                          label: '매출',
                          value: _formatRevenue(totalRevenue),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 예약 내역
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '예약 내역',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${reservations.length}건',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (reservations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              '예약 내역이 없습니다.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...reservations.map((r) => _ReservationTile(reservation: r)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  static String _formatRevenue(int amount) {
    if (amount == 0) return '0원';
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }

  /// 기존: 마스터 기준 (roomId 없이 진입 시)
  Widget _buildMasterBody() {
    return Consumer<BusinessService>(
      builder: (context, businessService, _) {
        if (businessService.isLoading &&
            businessService.currentBusiness == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final business = businessService.currentBusiness;
        if (business == null) {
          return const Center(
            child: Text('사업장 정보를 찾을 수 없습니다.'),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '기본 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.business,
                        label: '사업장명',
                        value: business.companyName ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.numbers,
                        label: '사업자번호',
                        value: business.businessNumber ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on,
                        label: '주소',
                        value: business.address ?? '-',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.phone,
                        label: '전화번호',
                        value: business.phone ?? '-',
                      ),
                      if (business.email != null &&
                          business.email!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.email,
                          label: '이메일',
                          value: business.email!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (business.businessDetails.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '룸 목록',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...business.businessDetails.map((detail) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(Icons.meeting_room,
                                    size: 20, color: AppColors.textSecondary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    detail.roomName ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (detail.isActive)
                                  const Text(
                                    '활성',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                    ),
                                  )
                                else
                                  const Text(
                                    '비활성',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list),
                label: const Text('예약 내역 보기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final amount = reservation.paymentAmount ?? 0;
    final amountStr = amount > 0
        ? '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
        : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reservation.date ?? '-'} ${reservation.time ?? ''}'.trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reservation.mainOption ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (reservation.midOption != null ||
                    reservation.subOption != null)
                  Text(
                    [
                      reservation.midOption,
                      reservation.subOption,
                    ].whereType<String>().join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            amountStr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: reservation.isConfirmed
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.textTertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              reservation.isConfirmed ? '확정' : '취소',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: reservation.isConfirmed
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
