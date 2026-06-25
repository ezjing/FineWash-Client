import 'package:flutter/material.dart';

import '../models/schedule_master_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../utils/time_picker_util.dart';
import 'time_selector_field.dart';

/// 기본 근무시간·요일 설정 다이얼로그 (관리 화면에서 분리)
class WeeklyScheduleDialog extends StatefulWidget {
  final ScheduleMasterModel? master;
  final Future<void> Function(
    String startTime,
    String endTime,
    Map<String, bool> workDays,
  ) onSave;

  const WeeklyScheduleDialog({
    super.key,
    required this.master,
    required this.onSave,
  });

  @override
  State<WeeklyScheduleDialog> createState() => _WeeklyScheduleDialogState();
}

class _WeeklyScheduleDialogState extends State<WeeklyScheduleDialog> {
  late String _startTime;
  late String _endTime;
  late Map<String, bool> _workDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final master = widget.master;
    _startTime = master?.startTime ?? '09:00';
    _endTime = master?.endTime ?? '18:00';
    _workDays = ScheduleMasterModel.workDaysFrom(master);
  }

  Future<void> _selectTime({required bool isStart}) async {
    final picked = await TimePickerUtil.pickTime(
      context,
      currentTime: isStart ? _startTime : _endTime,
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

  Future<void> _handleSave() async {
    if (!TimePickerUtil.isEndAfterStart(_startTime, _endTime)) {
      showAppSnackBar(
        context,
        message: '종료 시간은 시작 시간보다 늦어야 합니다.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (!_workDays.values.contains(true)) {
      showAppSnackBar(
        context,
        message: '최소 1개 이상의 근무 요일을 선택해주세요.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSave(_startTime, _endTime, _workDays);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '기본 근무시간 설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '모든 근무 요일에 동일한 시간이 적용됩니다.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TimeSelectorField(
                      label: '시작',
                      value: _startTime,
                      valueFontSize: 16,
                      placeholder: '',
                      onTap: () => _selectTime(isStart: true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('~'),
                  ),
                  Expanded(
                    child: TimeSelectorField(
                      label: '종료',
                      value: _endTime,
                      valueFontSize: 16,
                      placeholder: '',
                      onTap: () => _selectTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '근무 요일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ScheduleMasterModel.koreanDayLabels.map((day) {
                  final isWorkDay = _workDays[day] ?? false;
                  return FilterChip(
                    label: Text(day),
                    selected: isWorkDay,
                    onSelected: (selected) {
                      setState(() => _workDays[day] = selected);
                    },
                    selectedColor: AppColors.primary.withAlpha(
                      (0.15 * 255).round(),
                    ),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 48),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
