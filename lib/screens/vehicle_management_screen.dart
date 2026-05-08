import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../utils/app_colors.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleService>().searchLogic1();
    });
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openVehicleForm({
    VehicleModel? vehicle,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VehicleFormSheet(vehicle: vehicle),
    );

    if (result == true && mounted) {
      // 저장 성공 시 목록 최신화
      await context.read<VehicleService>().searchLogic1();
    }
  }

  Future<void> _deleteVehicle(VehicleModel vehicle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차량 삭제'),
        content: Text('`${vehicle.displayName}` 차량을 삭제하시겠습니까?'.replaceAll('`', '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final vehicleService = context.read<VehicleService>();
    final ok = await vehicleService.saveLogic3(vehicle.vehIdx);
    if (!mounted) return;

    if (ok) {
      _showSnackBar(
        context,
        message: '차량이 삭제되었습니다.',
        color: AppColors.success,
      );
    } else {
      _showSnackBar(
        context,
        message: '차량 삭제에 실패했습니다.',
        color: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차량 관리'),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => context.read<VehicleService>().searchLogic1(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openVehicleForm(),
        icon: const Icon(Icons.add),
        label: const Text('차량 추가'),
      ),
      body: Consumer<VehicleService>(
        builder: (context, vehicleService, child) {
          final vehicles = vehicleService.vehicles;

          if (vehicleService.isLoading && vehicles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehicles.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => vehicleService.searchLogic1(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 64),
                  Icon(
                    Icons.directions_car_outlined,
                    size: 56,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '등록된 차량이 없습니다.\n하단의 “차량 추가”로 등록해 주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vehicleService.searchLogic1(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return _VehicleTile(
                  vehicle: v,
                  onEdit: () => _openVehicleForm(vehicle: v),
                  onDelete: () => _deleteVehicle(v),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleTile({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.purple.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_filled_outlined,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if ((vehicle.vehicleType ?? '').isNotEmpty)
                      _Chip(text: vehicle.vehicleType!),
                    if ((vehicle.color ?? '').isNotEmpty) _Chip(text: vehicle.color!),
                    if (vehicle.year != null) _Chip(text: '${vehicle.year}년식'),
                  ],
                ),
                if ((vehicle.remark ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    vehicle.remark!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: '수정',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: '삭제',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _VehicleFormSheet extends StatefulWidget {
  final VehicleModel? vehicle;
  const _VehicleFormSheet({required this.vehicle});

  @override
  State<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<_VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _modelController;
  late final TextEditingController _numberController;
  late final TextEditingController _colorController;
  late final TextEditingController _yearController;
  late final TextEditingController _remarkController;
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _selectedVehicleType = v?.vehicleType;
    _modelController = TextEditingController(text: v?.model ?? '');
    _numberController = TextEditingController(text: v?.vehicleNumber ?? '');
    _colorController = TextEditingController(text: v?.color ?? '');
    _yearController = TextEditingController(text: v?.year?.toString() ?? '');
    _remarkController = TextEditingController(text: v?.remark ?? '');
  }

  @override
  void dispose() {
    _modelController.dispose();
    _numberController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _showSnackBar({
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        message: '필수 항목을 확인해 주세요.',
        color: AppColors.warning, // 유효성
      );
      return;
    }

    final vehicleService = context.read<VehicleService>();
    final isEdit = widget.vehicle != null;

    final vehicleType = (_selectedVehicleType ?? '준중형').trim();
    final model = _modelController.text.trim();
    final vehicleNumber = _numberController.text.trim();
    final color = _colorController.text.trim().isEmpty
        ? null
        : _colorController.text.trim();
    final year = _yearController.text.trim().isEmpty
        ? null
        : int.tryParse(_yearController.text.trim());
    final remark = _remarkController.text.trim().isEmpty
        ? null
        : _remarkController.text.trim();

    bool ok;
    if (!isEdit) {
      ok = await vehicleService.saveLogic1(
        vehicleType: vehicleType,
        model: model,
        vehicleNumber: vehicleNumber,
        color: color,
        year: year,
        remark: remark,
      );
    } else {
      ok = await vehicleService.saveLogic2(
        vehIdx: widget.vehicle!.vehIdx,
        vehicleType: vehicleType,
        model: model,
        vehicleNumber: vehicleNumber,
        color: color,
        year: year,
        remark: remark,
      );
    }

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
      _showSnackBar(
        message: isEdit ? '차량 정보가 수정되었습니다.' : '차량이 등록되었습니다.',
        color: AppColors.success,
      );
    } else {
      _showSnackBar(
        message: isEdit ? '차량 수정에 실패했습니다.' : '차량 등록에 실패했습니다.',
        color: AppColors.error, // CRUD 에러
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.vehicle != null;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight * 0.9;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + bottomInset,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEdit ? '차량 수정' : '차량 추가',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context, false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleType,
                      items: const ['경차', '소형', '준중형', '중형', '대형', 'SUV', 'RV']
                          .map(
                            (t) => DropdownMenuItem<String>(
                              value: t,
                              child: Text(t),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: '차종',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (v) => setState(() => _selectedVehicleType = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: '모델명',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '모델명을 입력해주세요'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: '차량 번호',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '차량 번호를 입력해주세요'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            decoration: const InputDecoration(
                              labelText: '색상(선택)',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '연식(선택)',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _remarkController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '비고(선택)',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<VehicleService>(
                      builder: (context, vehicleService, child) => ElevatedButton(
                        onPressed: vehicleService.isLoading ? null : _submit,
                        child: vehicleService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isEdit ? '수정하기' : '등록하기'),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

