import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/business_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/business_location_basic_form.dart';
import 'address_search_screen.dart';

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
  double? _latitude;
  double? _longitude;

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
      _addressDetailController.text = business.addressDetail ?? '';
      _emailController.text = business.email ?? '';
      _depositYn = (business.depositYn ?? 'N') == 'Y';
      _depositAmountController.text =
          (business.depositAmount != null && business.depositAmount! > 0)
          ? business.depositAmount.toString()
          : '';
      _remarkController.text = business.remark ?? '';
      _businessType = business.businessType;
      _latitude = business.latitude;
      _longitude = business.longitude;
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

  Future<void> _openAddressSearch() async {
    if (_isLoading) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressSearchScreen()),
    );
    if (!mounted || result == null) return;

    final fullAddress = (result as dynamic).fullAddress as String?;
    final lat = (result as dynamic).latitude as double?;
    final lng = (result as dynamic).longitude as double?;
    if (fullAddress == null || fullAddress.trim().isEmpty) return;
    if (lat == null || lng == null) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: '주소에서 위도/경도를 가져오지 못했습니다.',
          type: AppSnackBarType.warning,
        );
      }
      return;
    }

    setState(() {
      _addressController.text = fullAddress.trim();
      _latitude = lat;
      _longitude = lng;
    });
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final businessNumber = _businessNumberController.text.trim();
    final companyName = _nameController.text.trim();
    final address = _addressController.text.trim();
    final addressDetail = _addressDetailController.text.trim().isEmpty
        ? null
        : _addressDetailController.text.trim();
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
        addressDetail: addressDetail,
        phone: phone,
        latitude: _latitude,
        longitude: _longitude,
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
        showAppSnackBar(
          context,
          message: widget.locationId != null
              ? '사업장 정보가 수정되었습니다'
              : '사업장이 등록되었습니다',
          type: AppSnackBarType.success,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          message: '오류가 발생했습니다: $e',
          type: AppSnackBarType.error,
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
                BusinessLocationBasicForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  businessNumberController: _businessNumberController,
                  addressController: _addressController,
                  addressDetailController: _addressDetailController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  depositAmountController: _depositAmountController,
                  remarkController: _remarkController,
                  isLoading: _isLoading,
                  depositYn: _depositYn,
                  businessType: _businessType,
                  latitude: _latitude,
                  longitude: _longitude,
                  onAddressSearch: _openAddressSearch,
                  onSave: _saveLocation,
                  onDepositYnChanged: (value) =>
                      setState(() => _depositYn = value),
                  onBusinessTypeChanged: (value) =>
                      setState(() => _businessType = value),
                ),
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
}
