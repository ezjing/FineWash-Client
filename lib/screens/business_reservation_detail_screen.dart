import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class BusinessReservationDetailScreen extends StatefulWidget {
  final ReservationModel reservation;

  const BusinessReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<BusinessReservationDetailScreen> createState() =>
      _BusinessReservationDetailScreenState();
}

class _BusinessReservationDetailScreenState
    extends State<BusinessReservationDetailScreen> {
  late String _selectedDate;
  late String _selectedTime;
  String? _estimatedDuration;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.reservation.date ?? '';
    _selectedTime = widget.reservation.time ?? '';
  }

  Future<void> _approveReservation() async {
    if (_selectedDate.isEmpty || _selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약 날짜와 시간을 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 예약 승인 및 일정 업데이트 API 호출
      final response = await ApiService.put(
        '/reservations/${widget.reservation.resvIdx}/approve',
        {
          'date': _selectedDate,
          'time': _selectedTime,
          if (_estimatedDuration != null) 'estimatedDuration': _estimatedDuration,
        },
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('예약이 승인되었습니다')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? '예약 승인에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectReservation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 거절'),
        content: const Text('정말 이 예약을 거절하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('거절'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.put(
        '/reservations/${widget.reservation.resvIdx}/reject',
        {},
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('예약이 거절되었습니다')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? '예약 거절에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isNotEmpty
          ? DateTime.tryParse(_selectedDate) ?? now
          : now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    final now = DateTime.now();
    TimeOfDay initialTime = TimeOfDay.now();

    if (_selectedTime.isNotEmpty) {
      final parts = _selectedTime.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? now.hour,
          minute: int.tryParse(parts[1]) ?? now.minute,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;
    final isPending = reservation.contractYn != 'Y' && reservation.contractYn != 'N';

    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 예약 정보 카드
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
                        Text(
                          '예약 #${reservation.resvIdx}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPending
                                ? AppColors.warning.withOpacity(0.1)
                                : reservation.contractYn == 'Y'
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPending
                                ? '대기중'
                                : reservation.contractYn == 'Y'
                                    ? '승인됨'
                                    : '거절됨',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPending
                                  ? AppColors.warning
                                  : reservation.contractYn == 'Y'
                                      ? AppColors.success
                                      : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: '위치',
                      value: reservation.vehicleLocation ?? '-',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.directions_car,
                      label: '서비스',
                      value: reservation.mainOption ?? '-',
                    ),
                    if (reservation.midOption != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.cleaning_services,
                        label: '중옵션',
                        value: reservation.midOption!,
                      ),
                    ],
                    if (reservation.subOption != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.build,
                        label: '소옵션',
                        value: reservation.subOption!,
                      ),
                    ],
                    if (reservation.paymentAmount != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.payments,
                        label: '결제 금액',
                        value:
                            '${reservation.paymentAmount!.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 일정 조정 섹션 (대기중인 경우만)
            if (isPending) ...[
              const Text(
                '상세 일정 조정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DateTimeSelector(
                        label: '예약 날짜',
                        value: _selectedDate.isEmpty
                            ? '날짜 선택'
                            : _selectedDate,
                        icon: Icons.calendar_today,
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 16),
                      _DateTimeSelector(
                        label: '예약 시간',
                        value: _selectedTime.isEmpty
                            ? '시간 선택'
                            : _selectedTime,
                        icon: Icons.access_time,
                        onTap: _selectTime,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: '예상 소요 시간 (분)',
                          hintText: '예: 60',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _estimatedDuration = value.isEmpty ? null : value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 승인/거절 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _rejectReservation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('거절'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _approveReservation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('승인'),
                    ),
                  ),
                ],
              ),
            ],
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

class _DateTimeSelector extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeSelector({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value.contains('선택')
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
