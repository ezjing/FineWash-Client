import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule_detail_model.dart';
import '../services/schedule_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../utils/time_picker_util.dart';
import '../widgets/section_card.dart';
import '../widgets/time_selector_field.dart';

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
  static const _timePlaceholder = '시간 선택';

  String? _eventType;
  String? _startTime;
  String? _endTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final detail = widget.existingDetail;
    if (detail == null) return;

    if (detail.isVacation) {
      _eventType = 'vacation';
      return;
    }

    _eventType = 'overtime';
    _startTime = detail.startTime;
    _endTime = detail.endTime;
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
            SectionCard(
              title: '이벤트 유형 선택',
              child: Row(
                children: [
                  Expanded(
                    child: _EventTypeCard(
                      icon: Icons.beach_access,
                      title: '연차',
                      accentColor: AppColors.purple,
                      isSelected: _eventType == 'vacation',
                      onTap: _selectVacation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EventTypeCard(
                      icon: Icons.schedule,
                      title: '연장근무',
                      accentColor: AppColors.orange,
                      isSelected: _eventType == 'overtime',
                      onTap: _selectOvertime,
                    ),
                  ),
                ],
              ),
            ),
            if (_eventType == 'overtime') ...[
              const SizedBox(height: 16),
              SectionCard(
                title: '연장근무 시간',
                child: Row(
                  children: [
                    Expanded(
                      child: TimeSelectorField(
                        label: '시작 시간',
                        value: _startTime ?? _timePlaceholder,
                        placeholder: _timePlaceholder,
                        onTap: () => _selectTime(isStart: true),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('~'),
                    ),
                    Expanded(
                      child: TimeSelectorField(
                        label: '종료 시간',
                        value: _endTime ?? _timePlaceholder,
                        placeholder: _timePlaceholder,
                        onTap: () => _selectTime(isStart: false),
                      ),
                    ),
                  ],
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

  void _selectVacation() {
    setState(() {
      _eventType = 'vacation';
      _startTime = null;
      _endTime = null;
    });
  }

  void _selectOvertime() {
    setState(() {
      _eventType = 'overtime';
      _startTime =
          widget.defaultEndTime ?? widget.defaultStartTime ?? '18:00';
      _endTime = '20:00';
    });
  }

  Future<void> _selectTime({required bool isStart}) async {
    final picked = await TimePickerUtil.pickTime(
      context,
      currentTime: isStart ? _startTime : _endTime,
      fallback: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
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
        !TimePickerUtil.isEndAfterStart(_startTime!, _endTime!)) {
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

/// 이벤트 유형 카드 — 선택 상태만 props로 받아 부분 재빌드 가능
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
