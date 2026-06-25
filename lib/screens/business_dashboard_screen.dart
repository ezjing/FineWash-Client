import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reservation_model.dart';
import '../services/business_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/business_location_chip_selector.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/month_navigator.dart';
import '../widgets/simple_bar_chart.dart';
import '../widgets/time_slot_bar.dart';

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
                    MonthNavigator(
                      selectedMonth: _selectedMonth,
                      onPrevious: () => _shiftMonth(-1),
                      onNext: () => _shiftMonth(1),
                      onTitleTap: _pickMonth,
                      variant: MonthNavigatorVariant.card,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (businesses.isNotEmpty)
                    BusinessLocationChipSelector(
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
                        child: DashboardStatCard(
                          title: '총 예약',
                          value: formatNumber(totalReservations),
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
                        child: DashboardStatCard(
                          title: '총 매출',
                          value: formatCompactRevenue(totalRevenue),
                          unit: revenueUnit(totalRevenue),
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
                        child: DashboardStatCard(
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
                        child: DashboardStatCard(
                          title: '승인 예약',
                          value: formatNumber(approvedCount),
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
                          SimpleBarChart(
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
                            TimeSlotBar(
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

