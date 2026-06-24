import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/business_master_model.dart';
import '../models/reservation_model.dart';
import '../services/business_service.dart';
import '../utils/app_colors.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  String _selectedPeriod = 'month'; // month, year
  int? _selectedBusMstIdx; // null이면 전체
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final businessService = context.read<BusinessService>();
    if (businessService.businesses.isEmpty) {
      await businessService.searchLogic1();
    }
    await businessService.searchLogic5();
  }

  List<ReservationModel> _filteredReservations(
    List<ReservationModel> reservations,
  ) {
    if (_selectedBusMstIdx == null) return reservations;
    return reservations
        .where((r) => r.busMstIdx == _selectedBusMstIdx)
        .toList();
  }

  DateTime? _reservationDate(ReservationModel reservation) {
    final date = reservation.date;
    if (date != null && date.isNotEmpty) {
      return DateTime.tryParse(date);
    }
    return reservation.createdDate;
  }

  bool _isInRange(DateTime date, DateTime start, DateTime end) {
    final day = DateTime(date.year, date.month, date.day);
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day);
    return !day.isBefore(rangeStart) && !day.isAfter(rangeEnd);
  }

  List<ReservationModel> _reservationsInPeriod(
    List<ReservationModel> reservations,
    DateTime start,
    DateTime end,
  ) {
    return reservations.where((r) {
      final date = _reservationDate(r);
      if (date == null) return false;
      return _isInRange(date, start, end);
    }).toList();
  }

  DateTime _lastDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0);
  }

  int _periodDays() {
    final now = DateTime.now();
    return switch (_selectedPeriod) {
      'month' => _lastDayOfMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      ).day,
      'year' => now.difference(DateTime(now.year, 1, 1)).inDays + 1,
      _ => 1,
    };
  }

  ({DateTime currentStart, DateTime currentEnd, DateTime previousStart, DateTime previousEnd})
  _periodRanges() {
    final now = DateTime.now();

    if (_selectedPeriod == 'year') {
      return (
        currentStart: DateTime(now.year, 1, 1),
        currentEnd: DateTime(now.year, 12, 31),
        previousStart: DateTime(now.year - 1, 1, 1),
        previousEnd: DateTime(now.year - 1, 12, 31),
      );
    }

    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final currentStart = DateTime(year, month, 1);
    final currentEnd = _lastDayOfMonth(year, month);
    final previousMonth = DateTime(year, month - 1, 1);
    final previousStart = DateTime(previousMonth.year, previousMonth.month, 1);
    final previousEnd = _lastDayOfMonth(
      previousMonth.year,
      previousMonth.month,
    );

    return (
      currentStart: currentStart,
      currentEnd: currentEnd,
      previousStart: previousStart,
      previousEnd: previousEnd,
    );
  }

  int _totalRevenue(List<ReservationModel> reservations) {
    return reservations
        .where((r) => r.contractYn == 'Y')
        .fold<int>(0, (sum, r) => sum + (r.paymentAmount ?? 0));
  }

  int _approvedCount(List<ReservationModel> reservations) {
    return reservations.where((r) => r.contractYn == 'Y').length;
  }

  double _changePercent(num current, num previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  String _formatChange(double change) {
    final prefix = change > 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(change.abs() >= 10 ? 0 : 1)}%';
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  String _formatRevenue(int amount) {
    if (amount >= 10000) {
      final man = amount / 10000;
      return man >= 10
          ? _formatNumber(man.round())
          : man.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    }
    return _formatNumber(amount);
  }

  String _revenueUnit(int amount) {
    return amount >= 10000 ? '만원' : '원';
  }

  List<int> _chartData(List<ReservationModel> reservations) {
    final ranges = _periodRanges();
    final current = _reservationsInPeriod(
      reservations,
      ranges.currentStart,
      ranges.currentEnd,
    );

    return switch (_selectedPeriod) {
      'year' => _yearlyMonthlyChartData(current),
      _ => _weeklyChartData(
        current,
        ranges.currentStart,
        ranges.currentEnd,
      ),
    };
  }

  List<String> _chartLabels() {
    final ranges = _periodRanges();
    return switch (_selectedPeriod) {
      'year' => List.generate(12, (i) => '${i + 1}월'),
      _ => List.generate(
        _weekCountInMonth(ranges.currentStart, ranges.currentEnd),
        (i) => '${i + 1}주',
      ),
    };
  }

  String _chartTitle() {
    return switch (_selectedPeriod) {
      'year' => '올해 월별 예약 추이',
      _ => '${_selectedMonth.year}년 ${_selectedMonth.month}월 주차별 예약 추이',
    };
  }

  int _weekCountInMonth(DateTime start, DateTime end) {
    return ((end.day - 1) ~/ 7) + 1;
  }

  List<int> _weeklyChartData(
    List<ReservationModel> reservations,
    DateTime start,
    DateTime end,
  ) {
    final weekCount = _weekCountInMonth(start, end);
    final counts = List<int>.filled(weekCount, 0);
    for (final reservation in reservations) {
      final date = _reservationDate(reservation);
      if (date == null) continue;
      if (date.year != start.year || date.month != start.month) continue;
      final weekIndex = (date.day - 1) ~/ 7;
      if (weekIndex >= 0 && weekIndex < counts.length) {
        counts[weekIndex]++;
      }
    }
    return counts;
  }

  List<int> _yearlyMonthlyChartData(List<ReservationModel> reservations) {
    final year = DateTime.now().year;
    final counts = List<int>.filled(12, 0);

    for (final reservation in reservations) {
      final date = _reservationDate(reservation);
      if (date == null || date.year != year) continue;
      counts[date.month - 1]++;
    }

    return counts;
  }

  List<({String label, int count})> _timeSlotDistribution(
    List<ReservationModel> reservations,
  ) {
    const slots = [
      (label: '09:00-12:00', start: 9, end: 12),
      (label: '12:00-15:00', start: 12, end: 15),
      (label: '15:00-18:00', start: 15, end: 18),
      (label: '18:00-21:00', start: 18, end: 21),
    ];

    final counts = List<int>.filled(slots.length, 0);
    for (final reservation in reservations) {
      final hour = _parseHour(reservation.time);
      if (hour == null) continue;
      for (var i = 0; i < slots.length; i++) {
        if (hour >= slots[i].start && hour < slots[i].end) {
          counts[i]++;
          break;
        }
      }
    }

    return List.generate(
      slots.length,
      (i) => (label: slots[i].label, count: counts[i]),
    );
  }

  int? _parseHour(String? time) {
    if (time == null || time.isEmpty) return null;
    return int.tryParse(time.split(':').first);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: '월 선택',
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedMonth = DateTime(picked.year, picked.month));
  }

  void _shiftMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종합 운영현황'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'month', child: Text('월간')),
              PopupMenuItem(value: 'year', child: Text('연간')),
            ],
          ),
        ],
      ),
      body: Consumer<BusinessService>(
        builder: (context, businessService, child) {
          if (businessService.isLoading && businessService.businesses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final businesses = businessService.businesses;
          final allReservations = _filteredReservations(
            businessService.businessReservations,
          );
          final ranges = _periodRanges();
          final currentReservations = _reservationsInPeriod(
            allReservations,
            ranges.currentStart,
            ranges.currentEnd,
          );
          final previousReservations = _reservationsInPeriod(
            allReservations,
            ranges.previousStart,
            ranges.previousEnd,
          );

          final totalReservations = currentReservations.length;
          final previousTotalReservations = previousReservations.length;
          final totalRevenue = _totalRevenue(currentReservations);
          final previousTotalRevenue = _totalRevenue(previousReservations);
          final approvedCount = _approvedCount(currentReservations);
          final previousApprovedCount = _approvedCount(previousReservations);
          final avgPerDay = totalReservations / _periodDays();
          final previousAvgPerDay = previousTotalReservations / _periodDays();

          final chartData = _chartData(allReservations);
          final chartLabels = _chartLabels();
          final timeSlots = _timeSlotDistribution(currentReservations);
          final maxTimeSlotCount = timeSlots.fold<int>(
            0,
            (max, slot) => slot.count > max ? slot.count : max,
          );

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPeriod == 'month') ...[
                    _MonthSelector(
                      selectedMonth: _selectedMonth,
                      onPrevious: () => _shiftMonth(-1),
                      onNext: () => _shiftMonth(1),
                      onPick: _pickMonth,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (businesses.isNotEmpty)
                    _LocationSelector(
                      businesses: businesses,
                      selectedBusMstIdx: _selectedBusMstIdx,
                      onSelected: (busMstIdx) {
                        setState(() => _selectedBusMstIdx = busMstIdx);
                      },
                    ),
                  if (businesses.isNotEmpty) const SizedBox(height: 16),
                  const Text(
                    '주요 지표',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: '총 예약',
                          value: _formatNumber(totalReservations),
                          unit: '건',
                          icon: Icons.calendar_today,
                          color: AppColors.primary,
                          change: _formatChange(
                            _changePercent(
                              totalReservations,
                              previousTotalReservations,
                            ),
                          ),
                          isPositive:
                              totalReservations >= previousTotalReservations,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: '총 매출',
                          value: _formatRevenue(totalRevenue),
                          unit: _revenueUnit(totalRevenue),
                          icon: Icons.payments,
                          color: AppColors.success,
                          change: _formatChange(
                            _changePercent(totalRevenue, previousTotalRevenue),
                          ),
                          isPositive: totalRevenue >= previousTotalRevenue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: '평균 예약',
                          value: avgPerDay.toStringAsFixed(1),
                          unit: '건/일',
                          icon: Icons.trending_up,
                          color: AppColors.orange,
                          change: _formatChange(
                            _changePercent(avgPerDay, previousAvgPerDay),
                          ),
                          isPositive: avgPerDay >= previousAvgPerDay,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: '승인 예약',
                          value: _formatNumber(approvedCount),
                          unit: '건',
                          icon: Icons.check_circle_outline,
                          color: AppColors.yellow,
                          change: _formatChange(
                            _changePercent(
                              approvedCount,
                              previousApprovedCount,
                            ),
                          ),
                          isPositive: approvedCount >= previousApprovedCount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '예약 현황',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          Text(
                            _chartTitle(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SimpleBarChart(
                            data: chartData,
                            labels: chartLabels,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '시간대별 예약 분포',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          for (final slot in timeSlots) ...[
                            _TimeSlotBar(
                              label: slot.label,
                              count: slot.count,
                              maxCount: maxTimeSlotCount,
                            ),
                            if (slot != timeSlots.last) const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${selectedMonth.year}년 ${selectedMonth.month}월',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  final List<BusinessMasterModel> businesses;
  final int? selectedBusMstIdx;
  final ValueChanged<int?> onSelected;

  const _LocationSelector({
    required this.businesses,
    required this.selectedBusMstIdx,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사업장 선택',
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
            children: [
              _LocationChip(
                label: '전체',
                isSelected: selectedBusMstIdx == null,
                onTap: () => onSelected(null),
              ),
              ...businesses.map(
                (business) => _LocationChip(
                  label: business.companyName ?? '사업장 #${business.busMstIdx}',
                  isSelected: selectedBusMstIdx == business.busMstIdx,
                  onTap: () => onSelected(business.busMstIdx),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationChip({
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
          color: isSelected ? AppColors.primary : Colors.white,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String change;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error)
                        .withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels;

  const _SimpleBarChart({
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '예약 데이터가 없습니다',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return SizedBox(
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const xAxisHeight = 28.0;
          const countLabelHeight = 14.0;
          const gap = 4.0;
          final maxBarHeight =
              constraints.maxHeight - xAxisHeight - countLabelHeight - gap;

          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight - xAxisHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (index) {
                    final barHeight = (data[index] / safeMax) * maxBarHeight;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (data[index] > 0)
                              Text(
                                '${data[index]}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            const SizedBox(height: gap),
                            Container(
                              width: double.infinity,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(data.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        index < labels.length ? labels[index] : '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeSlotBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;

  const _TimeSlotBar({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final value = maxCount == 0 ? 0.0 : count / maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$count건',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
