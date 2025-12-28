import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vehicle_service.dart';
import '../utils/app_colors.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _numberController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _remarkController = TextEditingController();
  String? _selectedVehicleType;

  @override
  void dispose() {
    _modelController.dispose();
    _numberController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final vehicleService = Provider.of<VehicleService>(context, listen: false);
      final success = await vehicleService.saveLogic1(
        vehicleType: _selectedVehicleType ?? '준중형',
        model: _modelController.text.trim(),
        vehicleNumber: _numberController.text.trim(),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        year: _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim()),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      );
      if (success && mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('차량 정보 등록'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  children: [
                    Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.directions_car_rounded, size: 32, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    const Text('세차 예약을 위해\n차량 정보를 등록해주세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('차종', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedVehicleType,
                    hint: const Text('차종을 선택하세요'),
                    isExpanded: true,
                    items: ['경차', '소형', '준중형', '중형', '대형', 'SUV', 'RV'].map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedVehicleType = value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: '모델명', hintText: '예: 그랜저, 소나타', prefixIcon: Icon(Icons.edit_outlined), filled: true, fillColor: Colors.white), validator: (value) => value == null || value.isEmpty ? '모델명을 입력해주세요' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _numberController, decoration: const InputDecoration(labelText: '차량 번호', hintText: '12가 3456', prefixIcon: Icon(Icons.confirmation_number_outlined), filled: true, fillColor: Colors.white), validator: (value) => value == null || value.isEmpty ? '차량 번호를 입력해주세요' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _colorController, decoration: const InputDecoration(labelText: '색상 (선택)', hintText: '예: 검정, 흰색', prefixIcon: Icon(Icons.color_lens_outlined), filled: true, fillColor: Colors.white)),
              const SizedBox(height: 16),
              TextFormField(controller: _yearController, decoration: const InputDecoration(labelText: '연식 (선택)', hintText: '예: 2020', prefixIcon: Icon(Icons.calendar_today_outlined), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextFormField(controller: _remarkController, decoration: const InputDecoration(labelText: '비고 (선택)', hintText: '추가 정보를 입력하세요', prefixIcon: Icon(Icons.note_outlined), filled: true, fillColor: Colors.white), maxLines: 3),
              const SizedBox(height: 32),
              Consumer<VehicleService>(builder: (context, vehicleService, child) => ElevatedButton(onPressed: vehicleService.isLoading ? null : _handleRegister, child: vehicleService.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('등록하기'))),
            ],
          ),
        ),
      ),
    );
  }
}

