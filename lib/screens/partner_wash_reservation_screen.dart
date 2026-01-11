import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_type_model.dart';
import '../models/wash_location_model.dart';
import '../services/vehicle_service.dart';
import '../services/reservation_service.dart';
import '../utils/app_colors.dart';
import 'vehicle_registration_screen.dart';
import 'reservation_confirmation_screen.dart';

class PartnerWashReservationScreen extends StatefulWidget {
  const PartnerWashReservationScreen({super.key});

  @override
  State<PartnerWashReservationScreen> createState() =>
      _PartnerWashReservationScreenState();
}

class _PartnerWashReservationScreenState
    extends State<PartnerWashReservationScreen> {
  int? _selectedVehicleId;
  String? _selectedLocationId;
  String _selectedServiceId = 'basic';
  DateTime? _selectedDate;
  String? _selectedTime;
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
        _selectedLocationId == null ||
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
    final selectedService = partnerWashServices.firstWhere(
      (s) => s.id == _selectedServiceId,
    );
    final reservationService = Provider.of<ReservationService>(
      context,
      listen: false,
    );
    final vehicleService = Provider.of<VehicleService>(context, listen: false);
    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    // TODO: busDtlIdx는 실제로는 선택한 세차장의 bus_dtl_idx를 사용해야 함
    final success = await reservationService.saveLogic2(
      vehicleId: _selectedVehicleId!,
      mainOption: '방문',
      midOption: selectedService.name,
      subOption: selectedService.description,
      date: dateStr,
      time: _selectedTime!,
      busDtlIdx: int.tryParse(_selectedLocationId ?? '0') ?? 0,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleService = Provider.of<VehicleService>(context);
    final vehicles = vehicleService.vehicles;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('제휴 세차장 예약')),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: bottomPadding + 24,
        ),
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
              '세차장 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...dummyWashLocations.map(
              (location) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () =>
                      setState(() => _selectedLocationId = location.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedLocationId == location.id
                          ? AppColors.secondary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLocationId == location.id
                            ? AppColors.secondary
                            : AppColors.border,
                        width: _selectedLocationId == location.id ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedLocationId == location.id
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
                                location.address,
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
                                  '${location.rating} (${location.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              location.distance,
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
            ...partnerWashServices.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedServiceId = service.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedServiceId == service.id
                          ? AppColors.secondary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedServiceId == service.id
                            ? AppColors.secondary
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
                                    ? AppColors.secondary
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
            const SizedBox(height: 32),
            Consumer<ReservationService>(
              builder: (context, reservationService, child) => ElevatedButton(
                onPressed: reservationService.isLoading
                    ? null
                    : _handleReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
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
                    : const Text('예약하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
