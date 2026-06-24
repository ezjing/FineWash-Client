import 'package:flutter/foundation.dart';

import '../models/schedule_detail_model.dart';
import '../models/schedule_master_model.dart';
import '../repositories/schedule_repository.dart';

class ScheduleService extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  ScheduleMasterModel? _scheduleMaster;
  List<ScheduleDetailModel> _scheduleDetails = [];
  bool _isLoading = false;
  String? _lastError;

  ScheduleMasterModel? get scheduleMaster => _scheduleMaster;
  List<ScheduleDetailModel> get scheduleDetails => _scheduleDetails;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  ScheduleDetailModel? detailForDate(DateTime date) {
    final key = _dateKey(date);
    for (final detail in _scheduleDetails) {
      if (detail.scheduleDate == key) return detail;
    }
    return null;
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<bool> loadScheduleMaster(int busMstIdx) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _repository.searchLogic1(busMstIdx: busMstIdx);
      final rows = response['rows'] as List?;
      if (rows != null && rows.isNotEmpty) {
        _scheduleMaster = ScheduleMasterModel.fromJson(
          rows.first as Map<String, dynamic>,
        );
      } else {
        _scheduleMaster = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadScheduleDetails({
    required int busMstIdx,
    required int year,
    required int month,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _repository.searchLogic2(
        busMstIdx: busMstIdx,
        year: year,
        month: month,
      );
      final rows = response['rows'] as List?;
      _scheduleDetails = rows != null
          ? rows
                .map(
                  (json) =>
                      ScheduleDetailModel.fromJson(json as Map<String, dynamic>),
                )
                .toList()
          : [];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveScheduleMaster({
    required int busMstIdx,
    required String startTime,
    required String endTime,
    required Map<String, bool> workDays,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final body = {
        'busMstIdx': busMstIdx,
        'startTime': startTime,
        'endTime': endTime,
        'mondayYn': workDays['월'] == true ? 'Y' : 'N',
        'tuesdayYn': workDays['화'] == true ? 'Y' : 'N',
        'wednesdayYn': workDays['수'] == true ? 'Y' : 'N',
        'thursdayYn': workDays['목'] == true ? 'Y' : 'N',
        'fridayYn': workDays['금'] == true ? 'Y' : 'N',
        'saturdayYn': workDays['토'] == true ? 'Y' : 'N',
        'sundayYn': workDays['일'] == true ? 'Y' : 'N',
      };

      final response = _scheduleMaster == null
          ? await _repository.saveLogic1(body)
          : await _repository.saveLogic2(_scheduleMaster!.schMstIdx, body);

      if (response['row'] != null) {
        _scheduleMaster = ScheduleMasterModel.fromJson(
          response['row'] as Map<String, dynamic>,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveScheduleDetail({
    required int schMstIdx,
    required DateTime date,
    required bool isVacation,
    String? startTime,
    String? endTime,
    int? schDtlIdx,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final body = {
        'schMstIdx': schMstIdx,
        'scheduleDate': _dateKey(date),
        'holidayYn': isVacation ? 'Y' : 'N',
        if (!isVacation) 'startTime': startTime,
        if (!isVacation) 'endTime': endTime,
      };

      final response = schDtlIdx == null
          ? await _repository.saveLogic3(body)
          : await _repository.saveLogic4(schDtlIdx, body);

      if (response['row'] != null) {
        final saved = ScheduleDetailModel.fromJson(
          response['row'] as Map<String, dynamic>,
        );
        final index = _scheduleDetails.indexWhere(
          (d) => d.scheduleDate == saved.scheduleDate,
        );
        if (index >= 0) {
          _scheduleDetails[index] = saved;
        } else {
          _scheduleDetails.add(saved);
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteScheduleDetail(int schDtlIdx) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _repository.deleteLogic2(schDtlIdx);
      _scheduleDetails.removeWhere((d) => d.schDtlIdx == schDtlIdx);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _scheduleMaster = null;
    _scheduleDetails = [];
    _lastError = null;
    notifyListeners();
  }
}
