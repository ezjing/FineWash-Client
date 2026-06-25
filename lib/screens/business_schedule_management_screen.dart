import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/business_master_model.dart';
import '../models/schedule_detail_model.dart';
import '../services/business_service.dart';
import '../services/schedule_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/business_dropdown_field.dart';
import '../widgets/legend_dot.dart';
import '../widgets/month_navigator.dart';
import '../widgets/schedule_month_calendar.dart';
import '../widgets/weekly_schedule_dialog.dart';
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

    showDialog(
      context: context,
      builder: (context) => WeeklyScheduleDialog(
        master: scheduleService.scheduleMaster,
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
    }
  }

  void _changeMonth(int monthDelta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + monthDelta,
      );
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
          Selector<BusinessService, List<BusinessMasterModel>>(
            selector: (_, service) => service.businesses,
            builder: (context, businesses, _) {
              if (businesses.isEmpty) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                color: Colors.white,
                child: BusinessDropdownField(
                  businesses: businesses,
                  value: _selectedBusMstIdx,
                  onChanged: (value) {
                    setState(() => _selectedBusMstIdx = value);
                    _loadData();
                  },
                ),
              );
            },
          ),
          MonthNavigator(
            selectedMonth: _selectedMonth,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          Expanded(
            child: Selector2<BusinessService, ScheduleService,
                _ScheduleBodyData>(
              selector: (_, businessService, scheduleService) =>
                  _ScheduleBodyData(
                businessesEmpty: businessService.businesses.isEmpty,
                isLoading: scheduleService.isLoading,
                details: scheduleService.scheduleDetails,
              ),
              builder: (context, data, _) {
                if (data.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (data.businessesEmpty) {
                  return const Center(
                    child: Text(
                      '등록된 사업장이 없습니다.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ScheduleMonthCalendar(
                  selectedMonth: _selectedMonth,
                  details: data.details,
                  onDateTap: _openEventScreen,
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendDot(color: AppColors.purple, label: '연차'),
                SizedBox(width: 16),
                LegendDot(color: AppColors.orange, label: '연장근무'),
              ],
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

/// Selector용 — 필요한 필드만 구독해 전체 화면 재빌드 방지
class _ScheduleBodyData {
  final bool businessesEmpty;
  final bool isLoading;
  final List<ScheduleDetailModel> details;

  const _ScheduleBodyData({
    required this.businessesEmpty,
    required this.isLoading,
    required this.details,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ScheduleBodyData &&
          businessesEmpty == other.businessesEmpty &&
          isLoading == other.isLoading &&
          identical(details, other.details);

  @override
  int get hashCode =>
      Object.hash(businessesEmpty, isLoading, details);
}
