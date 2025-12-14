import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../utils/app_colors.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  VehicleSize _selectedSize = VehicleSize.medium;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final vehicleService = Provider.of<VehicleService>(context, listen: false);
      final success = await vehicleService.saveLogic1(name: _nameController.text.trim(), number: _numberController.text.trim(), size: _selectedSize);
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
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '차량 이름', hintText: '예: 그랜저, 소나타', prefixIcon: Icon(Icons.edit_outlined), filled: true, fillColor: Colors.white), validator: (value) => value == null || value.isEmpty ? '차량 이름을 입력해주세요' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _numberController, decoration: const InputDecoration(labelText: '차량 번호', hintText: '12가 3456', prefixIcon: Icon(Icons.confirmation_number_outlined), filled: true, fillColor: Colors.white), validator: (value) => value == null || value.isEmpty ? '차량 번호를 입력해주세요' : null),
              const SizedBox(height: 24),
              const Text('차량 크기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                children: VehicleSize.values.map((size) {
                  final isSelected = _selectedSize == size;
                  return InkWell(
                    onTap: () => setState(() => _selectedSize = size),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white, border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(size.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(size.description, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Consumer<VehicleService>(builder: (context, vehicleService, child) => ElevatedButton(onPressed: vehicleService.isLoading ? null : _handleRegister, child: vehicleService.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('등록하기'))),
            ],
          ),
        ),
      ),
    );
  }
}

