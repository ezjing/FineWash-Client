import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule_detail_model.dart';
import '../services/schedule_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';

class BusinessScheduleEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  final int schMstIdx;
  final ScheduleDetailModel? existingDetail;
  final String? defaultStartTime;
  final String? defaultEndTime;

  const BusinessScheduleEventScreen({
    super.key,
    required this.selectedDate,
    required this.schMstIdx,
    this.existingDetail,
    this.defaultStartTime,
    this.defaultEndTime,
  });

  @override
  State<BusinessScheduleEventScreen> createState() =>
      _BusinessScheduleEventScreenState();
}

class _BusinessScheduleEventScreenState
    extends State<BusinessScheduleEventScreen> {
  String? _eventType;
  String? _startTime;
  String? _endTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final detail = widget.existingDetail;
    if (detail != null) {
      if (detail.isVacation) {
        _eventType = 'vacation';
      } else {
        _eventType = 'overtime';
        _startTime = detail.startTime;
        _endTime = detail.endTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.selectedDate.month}/${widget.selectedDate.day} 스케줄',
        ),
        actions: [
          if (widget.existingDetail != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '삭제',
              onPressed: _isSaving ? null : _deleteEvent,
            ),
        ],
      ),
      body: SingleChildScrollView(
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
                      '이벤트 유형 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _EventTypeCard(
                            icon: Icons.beach_access,
                            title: '연차',
                            accentColor: AppColors.purple,
                            isSelected: _eventType == 'vacation',
                            onTap: () {
                              setState(() {
                                _eventType = 'vacation';
                                _startTime = null;
                                _endTime = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EventTypeCard(
                            icon: Icons.schedule,
                            title: '연장근무',
                            accentColor: AppColors.orange,
                            isSelected: _eventType == 'overtime',
                            onTap: () {
                              setState(() {
                                _eventType = 'overtime';
                                _startTime =
                                    widget.defaultEndTime ??
                                    widget.defaultStartTime ??
                                    '18:00';
                                _endTime = '20:00';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_eventType == 'overtime') ...[
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '연장근무 시간',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeSelector(
                              label: '시작 시간',
                              value: _startTime ?? '시간 선택',
                              onTap: () => _selectTime(true),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('~'),
                          ),
                          Expanded(
                            child: _TimeSelector(
                              label: '종료 시간',
                              value: _endTime ?? '시간 선택',
                              onTap: () => _selectTime(false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _eventType == null || _isSaving ? null : _saveEvent,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('저장'),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final currentTime = isStart ? _startTime : _endTime;
    TimeOfDay initialTime = TimeOfDay.now();

    if (currentTime != null) {
      final parts = currentTime.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 18,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        final timeStr =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          _startTime = timeStr;
        } else {
          _endTime = timeStr;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_eventType == 'overtime' && (_startTime == null || _endTime == null)) {
      showAppSnackBar(
        context,
        message: '연장근무 시간을 선택해주세요.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (_eventType == 'overtime' &&
        _startTime!.compareTo(_endTime!) >= 0) {
      showAppSnackBar(
        context,
        message: '종료 시간은 시작 시간보다 늦어야 합니다.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    final scheduleService = context.read<ScheduleService>();

    final ok = await scheduleService.saveScheduleDetail(
      schMstIdx: widget.schMstIdx,
      date: widget.selectedDate,
      isVacation: _eventType == 'vacation',
      startTime: _startTime,
      endTime: _endTime,
      schDtlIdx: widget.existingDetail?.schDtlIdx,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      showAppSnackBar(
        context,
        message: '스케줄이 저장되었습니다.',
        type: AppSnackBarType.success,
      );
      Navigator.pop(context, true);
    } else {
      showAppSnackBar(
        context,
        message: '스케줄 저장에 실패했습니다.',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _deleteEvent() async {
    final detail = widget.existingDetail;
    if (detail == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('스케줄 삭제'),
        content: const Text('이 날짜의 스케줄을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    final scheduleService = context.read<ScheduleService>();
    final ok = await scheduleService.deleteScheduleDetail(detail.schDtlIdx);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      showAppSnackBar(
        context,
        message: '스케줄이 삭제되었습니다.',
        type: AppSnackBarType.success,
      );
      Navigator.pop(context, true);
    } else {
      showAppSnackBar(
        context,
        message: '스케줄 삭제에 실패했습니다.',
        type: AppSnackBarType.error,
      );
    }
  }
}

class _EventTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypeCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.isSelected,
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
          color: isSelected
              ? accentColor.withAlpha((0.1 * 255).round())
              : Colors.white,
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? accentColor : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? accentColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
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
    );
  }
}
