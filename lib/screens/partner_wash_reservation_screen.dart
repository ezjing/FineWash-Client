import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_result.dart';
import '../models/business_detail_model.dart';
import '../models/business_master_model.dart';
import '../services/business_service.dart';
import '../services/vehicle_service.dart';
import '../services/reservation_service.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../services/wash_option_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_snackbar.dart';
import '../widgets/reservation_step_indicator.dart';
import 'vehicle_registration_screen.dart';
import 'reservation_confirmation_screen.dart';
import 'address_search_screen.dart';

class PartnerWashReservationScreen extends StatefulWidget {
  const PartnerWashReservationScreen({super.key});

  @override
  State<PartnerWashReservationScreen> createState() =>
      _PartnerWashReservationScreenState();
}

class _PartnerWashReservationScreenState
    extends State<PartnerWashReservationScreen> {
  int _currentStep = 1; // 현재 단계 (1-4)
  int? _selectedVehicleId;
  int? _selectedBusDtlIdx;
  int? _selectedBusMstIdx;
  int? _selectedWoptMstIdx;
  int? _selectedWoptDtlIdx;
  String? _selectedMidOptionName;
  String? _selectedSubOptionName;
  int _selectedPrice = 0;
  DateTime? _selectedDate;
  String? _selectedTime;
  AddressResult? _currentLocation; // 현재 위치 (사용자 위치)
  final _currentLocationController = TextEditingController();

  final List<String> _availableTimes = [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  int get _totalPrice {
    return _selectedPrice;
  }

  bool get _canProceedToNextStep {
    switch (_currentStep) {
      case 1:
        return _currentLocation != null && _selectedBusDtlIdx != null;
      case 2:
        return _selectedVehicleId != null &&
            _selectedWoptMstIdx != null &&
            _selectedWoptDtlIdx != null;
      case 3:
        return _selectedDate != null && _selectedTime != null;
      case 4:
        return false; // 결제 단계는 버튼으로 진행
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep && _currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 차량 목록 조회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicleService = Provider.of<VehicleService>(
        context,
        listen: false,
      );
      vehicleService.searchLogic1();
    });
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    super.dispose();
  }

  Future<void> _searchCurrentLocation() async {
    final result = await Navigator.push<AddressResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );
    if (!mounted) return;
    if (result != null) {
      final businessService = Provider.of<BusinessService>(
        context,
        listen: false,
      );
      final washOptionService = Provider.of<WashOptionService>(
        context,
        listen: false,
      );
      setState(() {
        _currentLocation = result;
        _currentLocationController.text = result.fullAddress;
        _selectedBusDtlIdx = null;
        _selectedBusMstIdx = null;
        _selectedWoptMstIdx = null;
        _selectedWoptDtlIdx = null;
        _selectedMidOptionName = null;
        _selectedSubOptionName = null;
        _selectedPrice = 0;
      });
      washOptionService.clear();
      await businessService.searchLogic2(
        latitude: result.latitude,
        longitude: result.longitude,
      );
    }
  }

  BusinessDetailModel? _getSelectableRoom(BusinessMasterModel business) {
    if (business.businessDetails.isEmpty) return null;
    final active = business.businessDetails.where((d) => d.isActive).toList();
    if (active.isNotEmpty) return active.first;
    return business.businessDetails.first;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _handleReservation() async {
    // 입력 검증
    if (_selectedVehicleId == null ||
        _selectedBusDtlIdx == null ||
        _selectedWoptMstIdx == null ||
        _selectedWoptDtlIdx == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      showAppSnackBar(
        context,
        message: '모든 정보를 입력해주세요.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final selectedMidName = _selectedMidOptionName ?? '-';
    final selectedSubName = _selectedSubOptionName ?? '-';
    final authService = Provider.of<AuthService>(context, listen: false);
    final reservationService = Provider.of<ReservationService>(
      context,
      listen: false,
    );
    final vehicleService = Provider.of<VehicleService>(context, listen: false);

    // 사용자 정보 가져오기
    final user = authService.currentUser;
    if (user == null) {
      showAppSnackBar(
        context,
        message: '로그인이 필요합니다.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    // 주문 고유번호 생성
    final merchantUid = PaymentService.generateMerchantUid();

    // 결제 요청
    await PaymentService.requestPayment(
      context: context,
      amount: _totalPrice,
      merchantUid: merchantUid,
      name: '$selectedMidName $selectedSubName - 제휴 세차장',
      buyerName: user.name ?? '고객',
      buyerTel: user.phone ?? '010-0000-0000',
      buyerEmail: user.email ?? 'customer@example.com',
      callback: (result) async {
        // 결제 결과 처리
        if (PaymentService.verifyPaymentResult(result)) {
          // 백엔드 서버에 결제 검증 요청
          final impUid = result['imp_uid'] as String?;
          if (impUid == null) {
            if (mounted) {
              showAppSnackBar(
                context,
                message: '결제 정보를 확인할 수 없습니다. 고객센터로 문의해주세요.',
                type: AppSnackBarType.warning,
              );
            }
            return;
          }

          // 로딩 표시
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          }

          // 백엔드 결제 검증
          final isVerified = await PaymentService.verifyPaymentWithBackend(
            impUid: impUid,
            merchantUid: merchantUid,
            amount: _totalPrice,
          );

          // 로딩 닫기
          if (mounted) {
            Navigator.pop(context);
          }

          if (!isVerified) {
            if (mounted) {
              showAppSnackBar(
                context,
                message: '결제 검증에 실패했습니다. 고객센터로 문의해주세요.',
                type: AppSnackBarType.error,
              );
            }
            return;
          }

          // 결제 검증 성공 - 예약 저장
          final dateStr =
              '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
          final success = await reservationService.saveLogic2(
            vehicleId: _selectedVehicleId!,
            mainOption: '방문',
            midOption: selectedMidName,
            subOption: selectedSubName,
            date: dateStr,
            time: _selectedTime!,
            busMstIdx: _selectedBusMstIdx!,
            impUid: impUid,
            merchantUid: merchantUid,
            paymentAmount: _totalPrice,
          );

          if (success && mounted) {
            final vehicle = vehicleService.getVehicleById(_selectedVehicleId!);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationConfirmationScreen(
                  reservation: reservationService.currentReservation!,
                  vehicle: vehicle!,
                ),
              ),
            );
          } else if (mounted) {
            showAppSnackBar(
              context,
              message: '예약 저장에 실패했습니다. 고객센터로 문의해주세요.',
              type: AppSnackBarType.error,
            );
          }
        } else {
          // 결제 실패
          if (mounted) {
            final errorMsg =
                result['error_msg'] ?? result['message'] ?? '결제에 실패했습니다.';
            showAppSnackBar(
              context,
              message: '$errorMsg',
              type: AppSnackBarType.error,
            );
          }
        }
      },
    );
  }

  Widget _buildStepIndicator() {
    return ReservationStepIndicator(
      currentStep: _currentStep,
      activeColor: AppColors.secondary,
      stepTitles: const [
        '위치/세차장\n선택',
        '차량/옵션\n선택',
        '날짜/시간\n선택',
        '결제\n완료',
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    final businessService = Provider.of<BusinessService>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '현재 위치',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _searchCurrentLocation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentLocation != null
                        ? _currentLocation!.fullAddress
                        : '현재 위치를 검색하세요',
                    style: TextStyle(
                      color: _currentLocation != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '세차장 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_currentLocation == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '위치를 입력하면 가까운 세차장을 찾아드립니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          if (businessService.isNearbyLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
            )
          else if (businessService.nearbyErrorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '가까운 세차장 목록을 불러오지 못했습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final loc = _currentLocation;
                      if (loc == null) return;
                      await businessService.searchLogic2(
                        latitude: loc.latitude,
                        longitude: loc.longitude,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else ...[
            Builder(
              builder: (context) {
                final allNearby = businessService.nearbyBusinesses;
                final partners =
                    allNearby.where((b) => b.businessType == 'PARTNER').toList();

                if (partners.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            allNearby.isEmpty
                                ? '주변 제휴 세차장이 없습니다'
                                : '조회된 사업장(${allNearby.length}개) 중 제휴(PARTNER) 세차장이 없습니다',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: partners.asMap().entries.map((entry) {
              final index = entry.key;
              final business = entry.value;
              final isLast = index == partners.length - 1;
              final room = _getSelectableRoom(business);
              final busDtlIdx = room?.busDtlIdx;
              final isSelectable = busDtlIdx != null;
              final isSelected =
                  isSelectable && _selectedBusDtlIdx == busDtlIdx;
              final distanceText = business.distanceKm != null
                  ? '${business.distanceKm!.toStringAsFixed(1)}km'
                  : '-';
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: InkWell(
                  onTap: isSelectable
                      ? () async {
                          final washOptionService =
                              context.read<WashOptionService>();
                          setState(() {
                            _selectedBusDtlIdx = busDtlIdx;
                            _selectedBusMstIdx = business.busMstIdx;
                            _selectedWoptMstIdx = null;
                            _selectedWoptDtlIdx = null;
                            _selectedMidOptionName = null;
                            _selectedSubOptionName = null;
                            _selectedPrice = 0;
                          });
                          washOptionService.clear();
                          await washOptionService.searchLogic2(
                            business.busMstIdx,
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary.withAlpha((0.1 * 255).round())
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.companyName ?? '세차장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                business.address ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (room?.roomName != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.meeting_room_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  room!.roomName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isSelectable)
                              const Text(
                                '예약 가능한 룸 정보가 없습니다',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              distanceText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStep2() {
    final vehicleService = Provider.of<VehicleService>(context);
    final vehicles = vehicleService.vehicles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '차량 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (vehicles.isEmpty)
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VehicleRegistrationScreen(),
                ),
              );
              if (result == true) {
                // 차량 등록 후 목록 새로고침
                await vehicleService.searchLogic1();
                setState(() {});
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text(
                    '차량 정보 등록하기',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedVehicleId,
                hint: const Text('차량을 선택하세요'),
                isExpanded: true,
                items: [
                  ...vehicles.map(
                    (v) => DropdownMenuItem<int>(
                      value: v.vehIdx,
                      child: Text(v.displayName),
                    ),
                  ),
                  const DropdownMenuItem<int>(
                    value: -1,
                    child: Row(
                      children: [
                        Icon(Icons.add, color: AppColors.secondary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '신규 차량 등록',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == -1) {
                    // 신규 차량 등록 화면으로 이동
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VehicleRegistrationScreen(),
                      ),
                    );
                    if (!mounted) return;
                    if (result == true) {
                      // 차량 등록 후 목록 새로고침
                      final vehicleService = Provider.of<VehicleService>(
                        context,
                        listen: false,
                      );
                      await vehicleService.searchLogic1();
                      // 새로 등록한 차량을 자동으로 선택
                      if (vehicleService.vehicles.isNotEmpty) {
                        setState(() {
                          _selectedVehicleId =
                              vehicleService.vehicles.last.vehIdx;
                        });
                      }
                    }
                  } else {
                    setState(() => _selectedVehicleId = value);
                  }
                },
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          '중옵션 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<WashOptionService>(
          builder: (context, washOptionService, child) {
            final masters = washOptionService.masters;
            if (_selectedBusMstIdx == null) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '먼저 세차장을 선택해주세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (washOptionService.isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              );
            }
            if (masters.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '해당 세차장에 등록된 세차 옵션이 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: masters
                  .map(
                    (m) => InkWell(
                      onTap: () => setState(() {
                        _selectedWoptMstIdx = m.woptMstIdx;
                        _selectedWoptDtlIdx = null;
                        _selectedMidOptionName = m.optionName;
                        _selectedSubOptionName = null;
                        _selectedPrice = 0;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedWoptMstIdx == m.woptMstIdx
                              ? AppColors.secondary
                                  .withAlpha((0.1 * 255).round())
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedWoptMstIdx == m.woptMstIdx
                                ? AppColors.secondary
                                : AppColors.border,
                            width: _selectedWoptMstIdx == m.woptMstIdx ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          m.optionName ?? '-',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedWoptMstIdx == m.woptMstIdx
                                ? AppColors.secondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          '소옵션 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<WashOptionService>(
          builder: (context, washOptionService, child) {
            final master = _selectedWoptMstIdx == null
                ? null
                : (() {
                    final list = washOptionService.masters
                        .where((m) => m.woptMstIdx == _selectedWoptMstIdx)
                        .toList();
                    return list.isEmpty ? null : list.first;
                  })();
            final details = master?.details ?? const [];
            if (_selectedWoptMstIdx == null) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '중옵션을 먼저 선택해주세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (details.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '소옵션이 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: details
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedWoptDtlIdx = d.woptDtlIdx;
                          _selectedSubOptionName = d.optionName;
                          _selectedPrice = d.value2 ?? 0;
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _selectedWoptDtlIdx == d.woptDtlIdx
                                ? AppColors.secondary
                                    .withAlpha((0.1 * 255).round())
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedWoptDtlIdx == d.woptDtlIdx
                                  ? AppColors.secondary
                                  : AppColors.border,
                              width: _selectedWoptDtlIdx == d.woptDtlIdx ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d.optionName ?? '-',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedWoptDtlIdx == d.woptDtlIdx
                                      ? AppColors.secondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${(d.value2 ?? 0).toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]},')}원',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedWoptDtlIdx == d.woptDtlIdx
                                      ? AppColors.secondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        if (_selectedWoptMstIdx != null && _selectedWoptDtlIdx != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  formatWonWithSuffix(_totalPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '날짜',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                      : '날짜를 선택하세요',
                  style: TextStyle(
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '시간',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTimes
              .map(
                (time) => ChoiceChip(
                  label: Text(time),
                  selected: _selectedTime == time,
                  onSelected: (selected) =>
                      setState(() => _selectedTime = selected ? time : null),
                  selectedColor:
                      AppColors.secondary.withAlpha((0.2 * 255).round()),
                  labelStyle: TextStyle(
                    color: _selectedTime == time
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                    fontWeight: _selectedTime == time
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '예약 정보 요약',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedMidOptionName != null)
                _buildSummaryRow(
                  '중옵션',
                  _selectedMidOptionName ?? '-',
                ),
              if (_selectedMidOptionName != null) const SizedBox(height: 8),
              if (_selectedSubOptionName != null)
                _buildSummaryRow(
                  '소옵션',
                  _selectedSubOptionName ?? '-',
                ),
              if (_selectedSubOptionName != null) const SizedBox(height: 8),
              _buildSummaryRow(
                '날짜',
                _selectedDate != null
                    ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                    : '-',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow('시간', _selectedTime ?? '-'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 결제 금액',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Consumer<ReservationService>(
      builder: (context, reservationService, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최종 결제 정보',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(
                  '중옵션',
                  _selectedMidOptionName ?? '-',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  '소옵션',
                  _selectedSubOptionName ?? '-',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  '날짜',
                  '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                ),
                const SizedBox(height: 8),
                _buildSummaryRow('시간', _selectedTime!),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '총 결제 금액',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: reservationService.isLoading ? null : _handleReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: reservationService.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '결제하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return PopScope(
      canPop: _currentStep <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 1) {
          _previousStep();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('제휴 세차장 예약'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 1) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: 24,
                ),
                child: _buildStepContent(),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: bottomPadding + 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('이전'),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentStep == 1 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _canProceedToNextStep && _currentStep < 4
                          ? _nextStep
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentStep < 4 ? '다음' : '완료',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
