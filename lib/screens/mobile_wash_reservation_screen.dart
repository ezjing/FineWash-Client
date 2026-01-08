import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_type_model.dart';
import '../services/vehicle_service.dart';
import '../services/reservation_service.dart';
import '../services/address_service.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'vehicle_registration_screen.dart';
import 'reservation_confirmation_screen.dart';
import 'address_search_screen.dart';

class MobileWashReservationScreen extends StatefulWidget {
  const MobileWashReservationScreen({super.key});

  @override
  State<MobileWashReservationScreen> createState() =>
      _MobileWashReservationScreenState();
}

class _MobileWashReservationScreenState
    extends State<MobileWashReservationScreen> {
  int? _selectedVehicleId;
  String _selectedServiceId = 'basic';
  DateTime? _selectedDate;
  String? _selectedTime;
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  AddressResult? _selectedAddress;
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

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final result = await Navigator.push<AddressResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedAddress = result;
        _addressController.text = result.fullAddress;
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
    // 입력 검증
    if (_selectedVehicleId == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 정보를 입력해주세요.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selectedService = mobileWashServices.firstWhere(
      (s) => s.id == _selectedServiceId,
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
      amount: selectedService.price,
      merchantUid: merchantUid,
      name: '${selectedService.name} - 출장 세차',
      buyerName: user.name ?? '고객',
      buyerTel: user.phone ?? '010-0000-0000',
      buyerEmail: user.email ?? 'customer@example.com',
      callback: (result) async {
        // 결제 결과 처리
        if (PaymentService.verifyPaymentResult(result)) {
          // 결제 성공 - 예약 저장
          final fullAddress = _detailAddressController.text.isNotEmpty
              ? '${_selectedAddress!.fullAddress} ${_detailAddressController.text}'
              : _selectedAddress!.fullAddress;
          final dateStr =
              '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

          final success = await reservationService.saveLogic1(
            vehicleId: _selectedVehicleId!,
            mainOption: '출장',
            midOption: selectedService.name,
            subOption: selectedService.description,
            date: dateStr,
            time: _selectedTime!,
            vehicleLocation: fullAddress,
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

  @override
  Widget build(BuildContext context) {
    final vehicleService = Provider.of<VehicleService>(context);
    final vehicles = vehicleService.vehicles;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('출장 세차 예약'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
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
                  if (result == true) setState(() {});
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
                      Icon(Icons.add, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        '차량 정보 등록하기',
                        style: TextStyle(
                          color: AppColors.primary,
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
                    items: vehicles
                        .map(
                          (v) => DropdownMenuItem<int>(
                            value: v.vehIdx,
                            child: Text(v.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedVehicleId = value),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              '세차 종류',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...mobileWashServices.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedServiceId = service.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedServiceId == service.id
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedServiceId == service.id
                            ? AppColors.primary
                            : AppColors.border,
                        width: _selectedServiceId == service.id ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedServiceId == service.id
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${service.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedServiceId == service.id
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '세차 주소',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _searchAddress,
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
                        _selectedAddress != null
                            ? _selectedAddress!.fullAddress
                            : '주소를 검색하세요',
                        style: TextStyle(
                          color: _selectedAddress != null
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
            if (_selectedAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                '우편번호: ${_selectedAddress!.zonecode}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _detailAddressController,
                decoration: const InputDecoration(
                  hintText: '상세 주소를 입력하세요 (동/호수 등)',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 24),
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
                      onSelected: (selected) => setState(
                        () => _selectedTime = selected ? time : null,
                      ),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedTime == time
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: _selectedTime == time
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
            Consumer<ReservationService>(
              builder: (context, reservationService, child) => ElevatedButton(
                onPressed: reservationService.isLoading
                    ? null
                    : _handleReservation,
                child: reservationService.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('예약하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
