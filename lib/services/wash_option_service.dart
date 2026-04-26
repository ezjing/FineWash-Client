import 'package:flutter/foundation.dart';

import '../models/wash_option_master_model.dart';
import '../repositories/wash_option_repository.dart';

class WashOptionService extends ChangeNotifier {
  final WashOptionRepository _repository = WashOptionRepository();

  List<WashOptionMasterModel> _masters = [];
  bool _isLoading = false;

  List<WashOptionMasterModel> get masters => _masters;
  bool get isLoading => _isLoading;

  void clear() {
    _masters = [];
    notifyListeners();
  }

  /// SearchLogic1 — 사업장별 MST(+DTL) 목록
  Future<void> searchLogic1(int busMstIdx, {bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final response = await _repository.searchLogic1(busMstIdx: busMstIdx);
      if (response['success'] == true && response['rows'] != null) {
        _masters = (response['rows'] as List)
            .map(
              (e) => WashOptionMasterModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } else {
        _masters = [];
      }
    } catch (e) {
      _masters = [];
    }
    if (showLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> reload(int busMstIdx) =>
      searchLogic1(busMstIdx, showLoading: false);

  Future<bool> saveMaster({
    required int busMstIdx,
    required String optionName,
    required String vehicleType,
    required int seq,
    int? value1,
    int? value2,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.saveLogic1({
        'busMstIdx': busMstIdx,
        'optionName': optionName.trim(),
        'vehicleType': vehicleType.trim(),
        'seq': seq,
        'value1': value1,
        'value2': value2,
      });
      _isLoading = false;
      notifyListeners();
      if (response['success'] == true) {
        await reload(busMstIdx);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMaster({
    required int woptMstIdx,
    required int busMstIdx,
    required String optionName,
    required String vehicleType,
    required int seq,
    int? value1,
    int? value2,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.saveLogic2(woptMstIdx, {
        'optionName': optionName.trim(),
        'vehicleType': vehicleType.trim(),
        'seq': seq,
        'value1': value1,
        'value2': value2,
      });
      _isLoading = false;
      notifyListeners();
      if (response['success'] == true) {
        await reload(busMstIdx);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMaster({
    required int woptMstIdx,
    required int busMstIdx,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.deleteLogic1(woptMstIdx);
      _isLoading = false;
      notifyListeners();
      if (response['success'] == true) {
        await reload(busMstIdx);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveDetail({
    required int woptMstIdx,
    required int busMstIdx,
    required String optionName,
    required String vehicleType,
    required int seq,
    int? value1,
    int? value2,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.saveLogic3({
        'woptMstIdx': woptMstIdx,
        'optionName': optionName.trim(),
        'vehicleType': vehicleType.trim(),
        'seq': seq,
        'value1': value1,
        'value2': value2,
      });
      _isLoading = false;
      notifyListeners();
      if (response['success'] == true) {
        await reload(busMstIdx);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDetail({
    required int woptDtlIdx,
    required int busMstIdx,
    required String optionName,
    required String vehicleType,
    required int seq,
    int? value1,
    int? value2,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.saveLogic4(woptDtlIdx, {
        'optionName': optionName.trim(),
        'vehicleType': vehicleType.trim(),
        'seq': seq,
        'value1': value1,
        'value2': value2,
      });
      _isLoading = false;
      notifyListeners();
      if (response['success'] == true) {
        await reload(busMstIdx);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDetail({
    required int woptDtlIdx,
    required int busMstIdx,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.deleteLogic2(woptDtlIdx);
      _isLoading = false;
      notifyListeners();
      if (response['success'] == true) {
        await reload(busMstIdx);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
