import 'package:flutter/foundation.dart';
import '../models/business_master_model.dart';
import '../models/business_detail_model.dart';
import '../models/reservation_model.dart';
import '../repositories/business_repository.dart';

class BusinessService extends ChangeNotifier {
  final BusinessRepository _businessRepository = BusinessRepository();

  List<BusinessMasterModel> _businesses = [];
  List<BusinessMasterModel> _nearbyBusinesses = [];
  String? _nearbyErrorMessage;
  bool _isNearbyLoading = false;
  BusinessMasterModel? _currentBusiness;
  BusinessDetailModel? _currentRoom;
  List<ReservationModel> _roomReservations = [];
  int _roomTotalRevenue = 0;
  bool _isLoading = false;

  List<BusinessMasterModel> get businesses => _businesses;
  List<BusinessMasterModel> get nearbyBusinesses => _nearbyBusinesses;
  String? get nearbyErrorMessage => _nearbyErrorMessage;
  bool get isNearbyLoading => _isNearbyLoading;
  BusinessMasterModel? get currentBusiness => _currentBusiness;
  BusinessDetailModel? get currentRoom => _currentRoom;
  List<ReservationModel> get roomReservations => _roomReservations;
  int get roomTotalRevenue => _roomTotalRevenue;
  bool get isLoading => _isLoading;

  /// 사업장 목록 조회 (SearchLogic1)
  Future<bool> searchLogic1() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _businessRepository.searchLogic2();
      if (response['success'] == true && response['businesses'] != null) {
        _businesses = (response['businesses'] as List)
            .map((json) => BusinessMasterModel.fromJson(json))
            .toList();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 좌표 기반 거리순 사업장 목록 조회 (SearchLogic2)
  /// - 백엔드에서 거리계산/정렬을 수행하고 거리순 목록을 반환해야 함
  /// - 응답 예: { success: true, businesses: [...] }
  Future<bool> searchLogic2({
    required double latitude,
    required double longitude,
  }) async {
    _isNearbyLoading = true;
    _nearbyErrorMessage = null;
    notifyListeners();
    try {
      final response = await _businessRepository.searchLogic4(
        latitude: latitude,
        longitude: longitude,
      );
      if (response['success'] == true && response['businesses'] != null) {
        _nearbyBusinesses = (response['businesses'] as List)
            .map((json) => BusinessMasterModel.fromJson(json))
            .toList();
        _isNearbyLoading = false;
        notifyListeners();
        return true;
      }
      _nearbyBusinesses = [];
      _nearbyErrorMessage = response['message']?.toString();
      _isNearbyLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _nearbyBusinesses = [];
      _nearbyErrorMessage = e.toString();
      _isNearbyLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearNearbyBusinesses() {
    _nearbyBusinesses = [];
    _nearbyErrorMessage = null;
    _isNearbyLoading = false;
    notifyListeners();
  }

  /// 사업장 상세 조회 (BusinessMaster + BusinessDetail 목록)
  Future<BusinessMasterModel?> getBusinessDetail(int busMstIdx) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _businessRepository.searchLogic3(busMstIdx);
      if (response['success'] == true && response['business'] != null) {
        _currentBusiness = BusinessMasterModel.fromJson(response['business']);
        _isLoading = false;
        notifyListeners();
        return _currentBusiness;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 사업장(MST) 저장 - 등록/수정 공용
  Future<BusinessMasterModel?> saveBusinessMaster({
    int? busMstIdx,
    required String businessNumber,
    required String companyName,
    required String address,
    String? detailAddress,
    required String phone,
    double? latitude,
    double? longitude,
    String? email,
    String? businessType,
    String depositYn = 'N',
    int depositAmount = 0,
    String? remark,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'businessNumber': businessNumber.trim(),
        'companyName': companyName.trim(),
        'address': address.trim(),
        if (detailAddress != null && detailAddress.trim().isNotEmpty)
          'detailAddress': detailAddress.trim(),
        'phone': phone.trim(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (email != null) 'email': email.trim(),
        if (businessType != null) 'businessType': businessType,
        'depositYn': depositYn,
        'depositAmount': depositAmount,
        if (remark != null) 'remark': remark,
      };

      final response = busMstIdx == null
          ? await _businessRepository.saveLogic1(body)
          : await _businessRepository.saveLogic2(busMstIdx, body);

      if (response['success'] == true && response['business'] != null) {
        final saved = BusinessMasterModel.fromJson(
          response['business'] as Map<String, dynamic>,
        );
        _currentBusiness = saved;

        final idx = _businesses.indexWhere(
          (b) => b.busMstIdx == saved.busMstIdx,
        );
        if (idx >= 0) {
          _businesses[idx] = saved;
        } else {
          _businesses = [saved, ..._businesses];
        }

        _isLoading = false;
        notifyListeners();
        return saved;
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 룸(DTL) 상세 조회 - 해당 룸 정보 + 예약 목록 + 매출
  Future<BusinessDetailModel?> getRoomDetail(int busDtlIdx) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _businessRepository.searchLogic1(busDtlIdx);
      if (response['success'] == true && response['room'] != null) {
        _currentRoom = BusinessDetailModel.fromJson(
          response['room'] as Map<String, dynamic>,
        );
        _roomReservations = (response['reservations'] as List? ?? [])
            .map((json) => ReservationModel.fromJson(json))
            .toList();
        _roomTotalRevenue = response['totalRevenue'] as int? ?? 0;
        _isLoading = false;
        notifyListeners();
        return _currentRoom;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearCurrentRoom() {
    _currentRoom = null;
    _roomReservations = [];
    _roomTotalRevenue = 0;
    notifyListeners();
  }

  /// 룸(DTL) 추가 - 해당 사업장에 룸만 추가
  Future<bool> addRoom({
    required int busMstIdx,
    required String roomName,
    String? startDate,
    String? endDate,
    String activeYn = 'Y',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'busMstIdx': busMstIdx,
        'roomName': roomName.trim(),
        'activeYn': activeYn,
      };
      if (startDate != null && startDate.isNotEmpty) {
        body['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        body['endDate'] = endDate;
      }

      final response = await _businessRepository.saveLogic3(body);
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 룸(DTL) 수정
  Future<BusinessDetailModel?> updateRoom({
    required int busDtlIdx,
    String? roomName,
    String? activeYn,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{};
      if (roomName != null) body['roomName'] = roomName.trim();
      if (activeYn != null) body['activeYn'] = activeYn;
      if (startDate != null) body['startDate'] = startDate;
      if (endDate != null) body['endDate'] = endDate;

      final response = await _businessRepository.saveLogic4(busDtlIdx, body);
      if (response['success'] == true && response['room'] != null) {
        final updated = BusinessDetailModel.fromJson(
          response['room'] as Map<String, dynamic>,
        );
        _currentRoom = updated;
        _isLoading = false;
        notifyListeners();
        return updated;
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 룸(DTL) 삭제
  Future<bool> deleteRoom({required int busDtlIdx}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _businessRepository.saveLogic5(busDtlIdx);
      if (response['success'] == true) {
        if (_currentRoom?.busDtlIdx == busDtlIdx) {
          _currentRoom = null;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearCurrentBusiness() {
    _currentBusiness = null;
    notifyListeners();
  }

  /// 사업장(MST) 삭제 (SaveLogic6)
  Future<bool> deleteBusiness({required int busMstIdx}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _businessRepository.saveLogic6(busMstIdx);
      if (response['success'] == true && response['deleted'] == true) {
        _businesses = _businesses
            .where((b) => b.busMstIdx != busMstIdx)
            .toList();
        if (_currentBusiness?.busMstIdx == busMstIdx) {
          _currentBusiness = null;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
