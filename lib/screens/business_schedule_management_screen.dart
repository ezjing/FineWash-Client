import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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
  final Map<String, Map<String, String>> _weeklySchedule = {
    '월': {'start': '09:00', 'end': '18:00'},
    '화': {'start': '09:00', 'end': '18:00'},
    '수': {'start': '09:00', 'end': '18:00'},
    '목': {'start': '09:00', 'end': '18:00'},
    '금': {'start': '09:00', 'end': '18:00'},
    '토': {'start': '10:00', 'end': '16:00'},
    '일': {'start': '', 'end': ''}, // 휴무
  };

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showWeeklyScheduleDialog,
            tooltip: '기본 근무시간 설정',
          ),
        ],
      ),
      body: Column(
        children: [
          // 월 선택 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
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
                  },
                ),
              ],
            ),
          ),
          // 캘린더
          Expanded(
            child: _buildCalendar(),
          ),
          SizedBox(height: mediaQuery.padding.bottom),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday % 7; // 일요일 = 0
    final daysInMonth = lastDay.day;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((day) => Expanded(
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
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // 캘린더 그리드
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
                final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                // TODO: 실제 이벤트 데이터 가져오기
                final hasEvent = day % 7 == 0 || day % 11 == 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessScheduleEventScreen(
                          selectedDate: date,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isToday
                            ? AppColors.primary
                            : AppColors.border,
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
                        if (hasEvent)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.orange,
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

  void _showWeeklyScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => _WeeklyScheduleDialog(
        weeklySchedule: _weeklySchedule,
        onSave: (schedule) {
          setState(() {
            _weeklySchedule.clear();
            _weeklySchedule.addAll(schedule);
          });
        },
      ),
    );
  }
}

class _WeeklyScheduleDialog extends StatefulWidget {
  final Map<String, Map<String, String>> weeklySchedule;
  final Function(Map<String, Map<String, String>>) onSave;

  const _WeeklyScheduleDialog({
    required this.weeklySchedule,
    required this.onSave,
  });

  @override
  State<_WeeklyScheduleDialog> createState() => _WeeklyScheduleDialogState();
}

class _WeeklyScheduleDialogState extends State<_WeeklyScheduleDialog> {
  late Map<String, Map<String, String>> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.weeklySchedule);
  }

  Future<void> _selectTime(
      String day, String type, BuildContext context) async {
    final currentTime = _schedule[day]![type] ?? '09:00';
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _schedule[day]![type] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _toggleDayOff(String day) {
    setState(() {
      if (_schedule[day]!['start']!.isEmpty) {
        _schedule[day]!['start'] = '09:00';
        _schedule[day]!['end'] = '18:00';
      } else {
        _schedule[day]!['start'] = '';
        _schedule[day]!['end'] = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기본 근무시간 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: ['월', '화', '수', '목', '금', '토', '일']
                    .map((day) => _DayScheduleRow(
                          day: day,
                          schedule: _schedule[day]!,
                          onStartTimeTap: () => _selectTime(day, 'start', context),
                          onEndTimeTap: () => _selectTime(day, 'end', context),
                          onDayOffToggle: () => _toggleDayOff(day),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(_schedule);
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayScheduleRow extends StatelessWidget {
  final String day;
  final Map<String, String> schedule;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;
  final VoidCallback onDayOffToggle;

  const _DayScheduleRow({
    required this.day,
    required this.schedule,
    required this.onStartTimeTap,
    required this.onEndTimeTap,
    required this.onDayOffToggle,
  });

  bool get isDayOff => schedule['start']!.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isDayOff ? null : onStartTimeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                        color: isDayOff
                            ? AppColors.surfaceVariant
                            : Colors.white,
                      ),
                      child: Text(
                        isDayOff ? '휴무' : schedule['start'] ?? '09:00',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDayOff
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                if (!isDayOff) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('~'),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onEndTimeTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule['end'] ?? '18:00',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: isDayOff,
            onChanged: (_) => onDayOffToggle(),
          ),
        ],
      ),
    );
  }
}
