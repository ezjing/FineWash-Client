import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BusinessLocationRegisterScreen extends StatefulWidget {
  final int? locationId; // 수정 모드인 경우

  const BusinessLocationRegisterScreen({
    super.key,
    this.locationId,
  });

  @override
  State<BusinessLocationRegisterScreen> createState() =>
      _BusinessLocationRegisterScreenState();
}

class _BusinessLocationRegisterScreenState
    extends State<BusinessLocationRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressDetailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  int _currentStep = 0; // 0: 기본정보, 1: 상세(room) 등록, 2: 옵션 등록

  @override
  void initState() {
    super.initState();
    if (widget.locationId != null) {
      // 수정 모드: 기존 데이터 로드
      _loadLocationData();
    }
  }

  Future<void> _loadLocationData() async {
    // TODO: API에서 기존 데이터 로드
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _addressDetailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: API 호출하여 저장
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.locationId != null
                ? '사업장 정보가 수정되었습니다'
                : '사업장이 등록되었습니다'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationId != null ? '사업장 수정' : '사업장 등록'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _saveLocation();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('기본 정보'),
            content: _buildBasicInfoStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('상세(room) 등록'),
            content: _buildRoomStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('옵션 등록'),
            content: _buildOptionStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '사업장명',
              hintText: '사업장명을 입력하세요',
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사업장명을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: '주소',
              hintText: '주소를 입력하세요',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '주소를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressDetailController,
            decoration: const InputDecoration(
              labelText: '상세주소',
              hintText: '상세주소를 입력하세요',
              prefixIcon: Icon(Icons.home),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '전화번호',
              hintText: '02-1234-5678',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '전화번호를 입력해주세요';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사업장 상세(room) 정보를 등록하세요',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // TODO: room 목록 추가/수정 UI 구현
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Room 이름',
                    hintText: '예: 세차실 1호',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '설명',
                    hintText: 'Room에 대한 설명',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 옵션을 설정하세요 (최초 등록 시 기본값 설정 가능)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // TODO: 옵션 설정 UI 구현
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('기본 옵션 1'),
                  subtitle: const Text('이 옵션을 기본값으로 설정'),
                  value: true,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('기본 옵션 2'),
                  subtitle: const Text('이 옵션을 기본값으로 설정'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
