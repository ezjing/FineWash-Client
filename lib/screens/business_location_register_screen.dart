import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/business_service.dart';

class BusinessLocationRegisterScreen extends StatefulWidget {
  final int? locationId; // 수정 모드인 경우

  const BusinessLocationRegisterScreen({super.key, this.locationId});

  @override
  State<BusinessLocationRegisterScreen> createState() =>
      _BusinessLocationRegisterScreenState();
}

class _BusinessLocationRegisterScreenState
    extends State<BusinessLocationRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressDetailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _depositAmountController = TextEditingController();
  final _remarkController = TextEditingController();

  bool _depositYn = false;
  String? _businessType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.locationId != null) {
      // 수정 모드: 기존 데이터 로드
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocationData());
    }
  }

  Future<void> _loadLocationData() async {
    if (widget.locationId == null) return;
    setState(() => _isLoading = true);
    try {
      final businessService = context.read<BusinessService>();
      final business = await businessService.getBusinessDetail(
        widget.locationId!,
      );
      if (!mounted || business == null) return;

      _nameController.text = business.companyName ?? '';
      _businessNumberController.text = business.businessNumber ?? '';
      _phoneController.text = business.phone ?? '';
      _addressController.text = business.address ?? '';
      _addressDetailController.text = '';
      _emailController.text = business.email ?? '';
      _depositYn = (business.depositYn ?? 'N') == 'Y';
      _depositAmountController.text =
          (business.depositAmount != null && business.depositAmount! > 0)
          ? business.depositAmount.toString()
          : '';
      _remarkController.text = business.remark ?? '';
      _businessType = business.businessType;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNumberController.dispose();
    _addressController.dispose();
    _addressDetailController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _depositAmountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final businessNumber = _businessNumberController.text.trim();
    final companyName = _nameController.text.trim();
    final address =
        '${_addressController.text.trim()} ${_addressDetailController.text.trim()}'
            .trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim();
    final depositYn = _depositYn ? 'Y' : 'N';
    final depositAmount = _depositYn
        ? int.tryParse(_depositAmountController.text.trim()) ?? 0
        : 0;
    final remark = _remarkController.text.trim().isEmpty
        ? null
        : _remarkController.text.trim();

    try {
      final businessService = context.read<BusinessService>();
      final saved = await businessService.saveBusinessMaster(
        busMstIdx: widget.locationId,
        businessNumber: businessNumber,
        companyName: companyName,
        address: address,
        phone: phone,
        email: email,
        businessType: _businessType,
        depositYn: depositYn,
        depositAmount: depositAmount,
        remark: remark,
      );
      if (saved == null) {
        throw Exception('저장에 실패했습니다.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.locationId != null ? '사업장 정보가 수정되었습니다' : '사업장이 등록되었습니다',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationId != null ? '사업장 수정' : '사업장 등록'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBasicInfoForm(),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isLoading ? null : _saveLocation,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(widget.locationId != null ? '수정 저장' : '등록 저장'),
                ),
                SizedBox(height: mediaQuery.padding.bottom),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            controller: _businessNumberController,
            decoration: const InputDecoration(
              labelText: '사업자 번호',
              hintText: '000-00-00000',
              prefixIcon: Icon(Icons.badge),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사업자 번호를 입력해주세요';
              }
              final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (digitsOnly.length != 10) {
                return '사업자 번호 10자리를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _businessType,
            decoration: const InputDecoration(
              labelText: '사업장 종류',
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(value: 'OUT', child: Text('출장')),
              DropdownMenuItem(value: 'PARTNER', child: Text('제휴')),
            ],
            onChanged: _isLoading
                ? null
                : (value) => setState(() => _businessType = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사업장 종류를 선택해주세요';
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
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '전화번호를 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'example@domain.com',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final v = value.trim();
              final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
              if (!ok) return '이메일 형식이 올바르지 않습니다';
              return null;
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('예약금 사용'),
            subtitle: const Text('예약금 Y/N'),
            value: _depositYn,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _depositYn = value;
                      if (!value) _depositAmountController.text = '';
                    });
                  },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _depositAmountController,
            decoration: const InputDecoration(
              labelText: '예약금',
              hintText: '0',
              prefixIcon: Icon(Icons.payments),
            ),
            enabled: _depositYn && !_isLoading,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (!_depositYn) return null;
              final v = value?.trim() ?? '';
              if (v.isEmpty) return '예약금을 입력해주세요';
              final amount = int.tryParse(v);
              if (amount == null || amount < 0) return '예약금은 0 이상의 숫자여야 합니다';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _remarkController,
            decoration: const InputDecoration(
              labelText: '비고',
              hintText: '비고를 입력하세요',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _saveLocation(),
          ),
        ],
      ),
    );
  }
}
