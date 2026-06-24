import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/schedule_detail_model.dart';
import '../models/schedule_master_model.dart';
import '../services/business_service.dart';
import '../services/schedule_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import 'business_schedule_event_screen.dart';

class BusinessScheduleManagementScreen extends StatefulWidget {
  const BusinessScheduleManagementScreen({super.key});

  @override
  State<BusinessScheduleManagementScreen> createState() =>
      _BusinessScheduleManagementScreenState();
}

class _BusinessScheduleManagementScreenState
    extends State<BusinessScheduleManagementScreen> {
  DateTime _selectedMonth = DateTime.now();
  int? _selectedBusMstIdx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final businessService = context.read<BusinessService>();
    final scheduleService = context.read<ScheduleService>();

    if (businessService.businesses.isEmpty) {
      await businessService.searchLogic1();
    }

    if (_selectedBusMstIdx == null && businessService.businesses.isNotEmpty) {
      _selectedBusMstIdx = businessService.businesses.first.busMstIdx;
    }

    if (_selectedBusMstIdx == null) {
      scheduleService.clear();
      if (mounted) setState(() {});
      return;
    }

    await scheduleService.loadScheduleMaster(_selectedBusMstIdx!);
    await scheduleService.loadScheduleDetails(
      busMstIdx: _selectedBusMstIdx!,
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );

    if (mounted) setState(() {});
  }

  void _showWeeklyScheduleDialog() {
    final scheduleService = context.read<ScheduleService>();
    final master = scheduleService.scheduleMaster;

    showDialog(
      context: context,
      builder: (context) => _WeeklyScheduleDialog(
        master: master,
        onSave: (startTime, endTime, workDays) async {
          if (_selectedBusMstIdx == null) return;

          final ok = await scheduleService.saveScheduleMaster(
            busMstIdx: _selectedBusMstIdx!,
            startTime: startTime,
            endTime: endTime,
            workDays: workDays,
          );

          if (!mounted) return;
          if (ok) {
            showAppSnackBar(
              context,
              message: '기본 근무시간이 저장되었습니다.',
              type: AppSnackBarType.success,
            );
            setState(() {});
          } else {
            showAppSnackBar(
              context,
              message: '기본 근무시간 저장에 실패했습니다.',
              type: AppSnackBarType.error,
            );
          }
        },
      ),
    );
  }

  Future<void> _openEventScreen(DateTime date) async {
    final scheduleService = context.read<ScheduleService>();
    final master = scheduleService.scheduleMaster;

    if (master == null) {
      showAppSnackBar(
        context,
        message: '먼저 기본 근무시간을 설정해주세요.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final existing = scheduleService.detailForDate(date);
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessScheduleEventScreen(
          selectedDate: date,
          schMstIdx: master.schMstIdx,
          existingDetail: existing,
          defaultStartTime: master.startTime,
          defaultEndTime: master.endTime,
        ),
      ),
    );

    if (changed == true && _selectedBusMstIdx != null) {
      await scheduleService.loadScheduleDetails(
        busMstIdx: _selectedBusMstIdx!,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final businessService = context.watch<BusinessService>();
    final scheduleService = context.watch<ScheduleService>();
    final businesses = businessService.businesses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _selectedBusMstIdx == null
                ? null
                : _showWeeklyScheduleDialog,
            tooltip: '기본 근무시간 설정',
          ),
        ],
      ),
      body: Column(
        children: [
          if (businesses.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              color: Colors.white,
              child: DropdownButtonFormField<int>(
                value: _selectedBusMstIdx,
                decoration: const InputDecoration(
                  labelText: '사업장',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: businesses
                    .map(
                      (b) => DropdownMenuItem(
                        value: b.busMstIdx,
                        child: Text(
                          b.companyName ?? '사업장 #${b.busMstIdx}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedBusMstIdx = value);
                  _loadData();
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                    _loadData();
                  },
                ),
                Text(
                  '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          if (scheduleService.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (businesses.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  '등록된 사업장이 없습니다.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: _buildCalendar(scheduleService.scheduleDetails),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.purple, label: '연차'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.orange, label: '연장근무'),
              ],
            ),
          ),
          SizedBox(height: mediaQuery.padding.bottom),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<ScheduleDetailModel> details) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    final detailMap = {
      for (final detail in details) detail.scheduleDate: detail,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: day == '일'
                              ? AppColors.error
                              : day == '토'
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: firstDayOfWeek + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek) {
                  return const SizedBox.shrink();
                }

                final day = index - firstDayOfWeek + 1;
                final date = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month,
                  day,
                );
                final isToday =
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                final dateKey =
                    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final detail = detailMap[dateKey];
                final markerColor = detail == null
                    ? null
                    : detail.isVacation
                    ? AppColors.purple
                    : AppColors.orange;

                return GestureDetector(
                  onTap: () => _openEventScreen(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withAlpha((0.1 * 255).round())
                          : Colors.white,
                      border: Border.all(
                        color: isToday ? AppColors.primary : AppColors.border,
                        width: isToday ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (markerColor != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _WeeklyScheduleDialog extends StatefulWidget {
  final ScheduleMasterModel? master;
  final Future<void> Function(
    String startTime,
    String endTime,
    Map<String, bool> workDays,
  ) onSave;

  const _WeeklyScheduleDialog({required this.master, required this.onSave});

  @override
  State<_WeeklyScheduleDialog> createState() => _WeeklyScheduleDialogState();
}

class _WeeklyScheduleDialogState extends State<_WeeklyScheduleDialog> {
  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

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
    _workDays = {
      '월': master?.mondayYn ?? true,
      '화': master?.tuesdayYn ?? true,
      '수': master?.wednesdayYn ?? true,
      '목': master?.thursdayYn ?? true,
      '금': master?.fridayYn ?? true,
      '토': master?.saturdayYn ?? false,
      '일': master?.sundayYn ?? false,
    };
  }

  Future<void> _selectTime({required bool isStart}) async {
    final current = isStart ? _startTime : _endTime;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      ),
    );

    if (picked != null) {
      setState(() {
        final value =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          _startTime = value;
        } else {
          _endTime = value;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (_startTime.compareTo(_endTime) >= 0) {
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
                    child: _TimeBox(
                      label: '시작',
                      value: _startTime,
                      onTap: () => _selectTime(isStart: true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('~'),
                  ),
                  Expanded(
                    child: _TimeBox(
                      label: '종료',
                      value: _endTime,
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
                children: _dayLabels.map((day) {
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

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeBox({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
