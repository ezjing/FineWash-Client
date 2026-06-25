import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_result.dart';
import '../services/auth_service.dart';
import '../services/business_service.dart';
import '../services/payment_service.dart';
import '../services/reservation_service.dart';
import '../services/vehicle_service.dart';
import '../services/wash_option_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../utils/date_format_util.dart';
import '../widgets/reservation/partner_wash_location_step.dart';
import '../widgets/reservation/reservation_datetime_step.dart';
import '../widgets/reservation/reservation_payment_step.dart';
import '../widgets/reservation/reservation_step_config.dart';
import '../widgets/reservation/reservation_vehicle_option_step.dart';
import '../widgets/reservation_step_footer.dart';
import '../widgets/reservation_step_indicator.dart';
import 'address_search_screen.dart';
import 'reservation_confirmation_screen.dart';
import 'vehicle_registration_screen.dart';

class PartnerWashReservationScreen extends StatefulWidget {
  const PartnerWashReservationScreen({super.key});

  @override
  State<PartnerWashReservationScreen> createState() =>
      _PartnerWashReservationScreenState();
}

class _PartnerWashReservationScreenState
    extends State<PartnerWashReservationScreen> {
  static const _stepConfig = ReservationStepConfig.partner;
  static const _availableTimes = [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  int _currentStep = 1;
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
  AddressResult? _currentLocation;

  int get _totalPrice => _selectedPrice;

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
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleService>().searchLogic1();
    });
  }

  void _nextStep() {
    if (_canProceedToNextStep && _currentStep < 4) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) setState(() => _currentStep--);
  }

  void _clearOptionSelection() {
    _selectedWoptMstIdx = null;
    _selectedWoptDtlIdx = null;
    _selectedMidOptionName = null;
    _selectedSubOptionName = null;
    _selectedPrice = 0;
  }

  Future<void> _searchCurrentLocation() async {
    final result = await Navigator.push<AddressResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );
    if (!mounted || result == null) return;

    final businessService = context.read<BusinessService>();
    final washOptionService = context.read<WashOptionService>();

    setState(() {
      _currentLocation = result;
      _selectedBusDtlIdx = null;
      _selectedBusMstIdx = null;
      _clearOptionSelection();
    });
    washOptionService.clear();
    await businessService.searchLogic2(
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }

  Future<void> _onPartnerSelected({
    required int busMstIdx,
    required int busDtlIdx,
  }) async {
    final washOptionService = context.read<WashOptionService>();
    setState(() {
      _selectedBusDtlIdx = busDtlIdx;
      _selectedBusMstIdx = busMstIdx;
      _clearOptionSelection();
    });
    washOptionService.clear();
    await washOptionService.searchLogic2(busMstIdx);
  }

  Future<void> _openVehicleRegistration() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen()),
    );
    if (!mounted || result != true) return;

    final vehicleService = context.read<VehicleService>();
    await vehicleService.searchLogic1();
    if (vehicleService.vehicles.isNotEmpty) {
      setState(() {
        _selectedVehicleId = vehicleService.vehicles.last.vehIdx;
      });
    }
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
    final authService = context.read<AuthService>();
    final reservationService = context.read<ReservationService>();
    final vehicleService = context.read<VehicleService>();

    final user = authService.currentUser;
    if (user == null) {
      showAppSnackBar(
        context,
        message: '로그인이 필요합니다.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final merchantUid = PaymentService.generateMerchantUid();

    await PaymentService.requestPayment(
      context: context,
      amount: _totalPrice,
      merchantUid: merchantUid,
      name: '$selectedMidName $selectedSubName - 제휴 세차장',
      buyerName: user.name ?? '고객',
      buyerTel: user.phone ?? '010-0000-0000',
      buyerEmail: user.email ?? 'customer@example.com',
      callback: (result) async {
        if (!PaymentService.verifyPaymentResult(result)) {
          if (mounted) {
            final errorMsg =
                result['error_msg'] ?? result['message'] ?? '결제에 실패했습니다.';
            showAppSnackBar(
              context,
              message: '$errorMsg',
              type: AppSnackBarType.error,
            );
          }
          return;
        }

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

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        }

        final isVerified = await PaymentService.verifyPaymentWithBackend(
          impUid: impUid,
          merchantUid: merchantUid,
          amount: _totalPrice,
        );

        if (mounted) Navigator.pop(context);

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

        final success = await reservationService.saveLogic2(
          vehicleId: _selectedVehicleId!,
          mainOption: '방문',
          midOption: selectedMidName,
          subOption: selectedSubName,
          date: DateFormatUtil.toDateKey(_selectedDate!),
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
      },
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return PartnerWashLocationStep(
          currentLocation: _currentLocation,
          selectedBusDtlIdx: _selectedBusDtlIdx,
          onSearchLocation: _searchCurrentLocation,
          onPartnerSelected: _onPartnerSelected,
        );
      case 2:
        return ReservationVehicleOptionStep(
          config: _stepConfig,
          busMstIdx: _selectedBusMstIdx,
          selectedVehicleId: _selectedVehicleId,
          selectedWoptMstIdx: _selectedWoptMstIdx,
          selectedWoptDtlIdx: _selectedWoptDtlIdx,
          totalPrice: _totalPrice,
          onAddVehicle: _openVehicleRegistration,
          onVehicleSelected: (value) => setState(() => _selectedVehicleId = value),
          onMidOptionSelected: (woptMstIdx, name) => setState(() {
            _selectedWoptMstIdx = woptMstIdx;
            _selectedWoptDtlIdx = null;
            _selectedMidOptionName = name;
            _selectedSubOptionName = null;
            _selectedPrice = 0;
          }),
          onSubOptionSelected: (woptDtlIdx, name, price) => setState(() {
            _selectedWoptDtlIdx = woptDtlIdx;
            _selectedSubOptionName = name;
            _selectedPrice = price;
          }),
        );
      case 3:
        return ReservationDateTimeStep(
          config: _stepConfig,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          midOptionName: _selectedMidOptionName,
          subOptionName: _selectedSubOptionName,
          totalPrice: _totalPrice,
          availableTimes: _availableTimes,
          onSelectDate: _selectDate,
          onTimeSelected: (time) => setState(() => _selectedTime = time),
        );
      case 4:
        return ReservationPaymentStep(
          config: _stepConfig,
          selectedDate: _selectedDate!,
          selectedTime: _selectedTime!,
          midOptionName: _selectedMidOptionName,
          subOptionName: _selectedSubOptionName,
          totalPrice: _totalPrice,
          onPay: _handleReservation,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentStep > 1) _previousStep();
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
            ReservationStepIndicator(
              currentStep: _currentStep,
              activeColor: AppColors.secondary,
              stepTitles: const [
                '위치/세차장\n선택',
                '차량/옵션\n선택',
                '날짜/시간\n선택',
                '결제\n완료',
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: 24,
                ),
                child: _buildStepContent(),
              ),
            ),
            ReservationStepFooter(
              currentStep: _currentStep,
              totalSteps: 4,
              canProceed: _canProceedToNextStep,
              onPrevious: _previousStep,
              onNext: _nextStep,
              primaryColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
