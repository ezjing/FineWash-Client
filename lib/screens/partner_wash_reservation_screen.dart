import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_result.dart';
import '../services/vehicle_service.dart';
import '../services/reservation_service.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
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
  String? _selectedLocationId;
  String? _selectedMidOption; // 중옵션: 'internal', 'external', 'both'
  String? _selectedSubOption; // 소옵션: 'basic', 'premium', 'full'
  DateTime? _selectedDate;
  String? _selectedTime;
  AddressResult? _currentLocation; // 현재 위치 (사용자 위치)
  final _currentLocationController = TextEditingController();

  // 더미 세차장 데이터 (서버 API 연동 전 임시 사용)
  List<Map<String, dynamic>> _dummyWashLocations = [
    {
      'id': '1',
      'name': '클린세차장 강남점',
      'address': '서울 강남구 테헤란로 123',
      'distance': '1.2km',
      'rating': 4.8,
      'reviewCount': 245,
    },
    {
      'id': '2',
      'name': '프리미엄세차 역삼점',
      'address': '서울 강남구 역삼동 456',
      'distance': '2.5km',
      'rating': 4.6,
      'reviewCount': 189,
    },
    {
      'id': '3',
      'name': '스피드세차 선릉점',
      'address': '서울 강남구 선릉로 789',
      'distance': '3.1km',
      'rating': 4.7,
      'reviewCount': 312,
    },
  ];

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

  // 중옵션 데이터
  final List<Map<String, dynamic>> _midOptions = [
    {'id': 'internal', 'name': '내부'},
    {'id': 'external', 'name': '외부'},
    {'id': 'both', 'name': '내/외부'},
  ];

  // 소옵션 데이터
  final List<Map<String, dynamic>> _subOptions = [
    {'id': 'basic', 'name': '기본선택', 'price': 10000},
    {'id': 'premium', 'name': '프리미엄 세차', 'price': 40000},
    {'id': 'full', 'name': '풀 패키지', 'price': 65000},
  ];

  int get _totalPrice {
    if (_selectedSubOption == null) return 0;
    final subOption = _subOptions.firstWhere(
      (opt) => opt['id'] == _selectedSubOption,
    );
    return subOption['price'] as int;
  }

  bool get _canProceedToNextStep {
    switch (_currentStep) {
      case 1:
        return _currentLocation != null && _selectedLocationId != null;
      case 2:
        return _selectedVehicleId != null &&
            _selectedMidOption != null &&
            _selectedSubOption != null;
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
    if (result != null) {
      setState(() {
        _currentLocation = result;
        _currentLocationController.text = result.fullAddress;
        _sortLocationsByDistance();
      });
    }
  }

  // 위치 기반으로 세차장 목록을 거리순으로 정렬
  void _sortLocationsByDistance() {
    if (_currentLocation == null) return;

    // TODO: 실제로는 서버에서 거리 계산된 데이터를 받아와야 함
    // 현재는 더미 데이터의 distance 값을 기준으로 정렬
    _dummyWashLocations.sort((a, b) {
      final distanceA =
          double.tryParse((a['distance'] as String).replaceAll('km', '')) ??
          0.0;
      final distanceB =
          double.tryParse((b['distance'] as String).replaceAll('km', '')) ??
          0.0;
      return distanceA.compareTo(distanceB);
    });
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
        _selectedLocationId == null ||
        _selectedMidOption == null ||
        _selectedSubOption == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 정보를 입력해주세요.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selectedSubOption = _subOptions.firstWhere(
      (opt) => opt['id'] == _selectedSubOption,
    );
    final selectedMidOption = _midOptions.firstWhere(
      (opt) => opt['id'] == _selectedMidOption,
    );
    final authService = Provider.of<AuthService>(context, listen: false);
    final reservationService = Provider.of<ReservationService>(
      context,
      listen: false,
    );
    final vehicleService = Provider.of<VehicleService>(context, listen: false);

    // 사용자 정보 가져오기
    final user = authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다.'),
          backgroundColor: AppColors.warning,
        ),
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
      name:
          '${selectedMidOption['name']} ${selectedSubOption['name']} - 제휴 세차장',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('결제 정보를 확인할 수 없습니다. 고객센터로 문의해주세요.'),
                  backgroundColor: AppColors.warning,
                ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('결제 검증에 실패했습니다. 고객센터로 문의해주세요.'),
                  backgroundColor: AppColors.warning,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            return;
          }

          // 결제 검증 성공 - 예약 저장
          final dateStr =
              '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
          // TODO: busDtlIdx는 실제로는 선택한 세차장의 bus_dtl_idx를 사용해야 함
          final success = await reservationService.saveLogic2(
            vehicleId: _selectedVehicleId!,
            mainOption: '방문',
            midOption: selectedMidOption['name'] as String,
            subOption: selectedSubOption['name'] as String,
            date: dateStr,
            time: _selectedTime!,
            busDtlIdx: int.tryParse(_selectedLocationId ?? '0') ?? 0,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('예약 저장에 실패했습니다. 고객센터로 문의해주세요.'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        } else {
          // 결제 실패
          if (mounted) {
            final errorMsg =
                result['error_msg'] ?? result['message'] ?? '결제에 실패했습니다.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final step = index + 1;
          final isActive = step == _currentStep;
          final isCompleted = step < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive || isCompleted
                              ? AppColors.secondary
                              : AppColors.border,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '$step',
                                  style: TextStyle(
                                    color: isActive || isCompleted
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStepTitle(step),
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive || isCompleted
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (step < 4)
                  Container(
                    width: 20,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isCompleted ? AppColors.secondary : AppColors.border,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return '위치/세차장\n선택';
      case 2:
        return '차량/옵션\n선택';
      case 3:
        return '날짜/시간\n선택';
      case 4:
        return '결제\n완료';
      default:
        return '';
    }
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
        else
          ..._dummyWashLocations.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            final isLast = index == _dummyWashLocations.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: InkWell(
                onTap: () =>
                    setState(() => _selectedLocationId = location['id']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedLocationId == location['id']
                        ? AppColors.secondary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedLocationId == location['id']
                          ? AppColors.secondary
                          : AppColors.border,
                      width: _selectedLocationId == location['id'] ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedLocationId == location['id']
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
                              location['address'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.yellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${location['rating']} (${location['reviewCount']})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            location['distance'],
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
          }),
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
                  ...vehicles
                      .map(
                        (v) => DropdownMenuItem<int>(
                          value: v.vehIdx,
                          child: Text(v.displayName),
                        ),
                      )
                      .toList(),
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _midOptions
              .map(
                (option) => InkWell(
                  onTap: () =>
                      setState(() => _selectedMidOption = option['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedMidOption == option['id']
                          ? AppColors.secondary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedMidOption == option['id']
                            ? AppColors.secondary
                            : AppColors.border,
                        width: _selectedMidOption == option['id'] ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      option['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedMidOption == option['id']
                            ? AppColors.secondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
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
        ..._subOptions.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedSubOption = option['id']),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedSubOption == option['id']
                      ? AppColors.secondary.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedSubOption == option['id']
                        ? AppColors.secondary
                        : AppColors.border,
                    width: _selectedSubOption == option['id'] ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedSubOption == option['id']
                            ? AppColors.secondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(option['price'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedSubOption == option['id']
                            ? AppColors.secondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_selectedMidOption != null && _selectedSubOption != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
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
                  '${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
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
                  selectedColor: AppColors.secondary.withOpacity(0.2),
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
              if (_selectedMidOption != null)
                _buildSummaryRow(
                  '중옵션',
                  _midOptions.firstWhere(
                    (opt) => opt['id'] == _selectedMidOption,
                  )['name'],
                ),
              if (_selectedMidOption != null) const SizedBox(height: 8),
              if (_selectedSubOption != null)
                _buildSummaryRow(
                  '소옵션',
                  _subOptions.firstWhere(
                    (opt) => opt['id'] == _selectedSubOption,
                  )['name'],
                ),
              if (_selectedSubOption != null) const SizedBox(height: 8),
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
                  _midOptions.firstWhere(
                    (opt) => opt['id'] == _selectedMidOption,
                  )['name'],
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  '소옵션',
                  _subOptions.firstWhere(
                    (opt) => opt['id'] == _selectedSubOption,
                  )['name'],
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

    return Scaffold(
      appBar: AppBar(title: const Text('제휴 세차장 예약')),
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
    );
  }
}
