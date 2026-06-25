import 'package:flutter/material.dart';

/// 사업장 등록·수정 기본 정보 폼
class BusinessLocationBasicForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController businessNumberController;
  final TextEditingController addressController;
  final TextEditingController addressDetailController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController depositAmountController;
  final TextEditingController remarkController;
  final bool isLoading;
  final bool depositYn;
  final String? businessType;
  final double? latitude;
  final double? longitude;
  final VoidCallback onAddressSearch;
  final VoidCallback onSave;
  final ValueChanged<bool> onDepositYnChanged;
  final ValueChanged<String?> onBusinessTypeChanged;

  const BusinessLocationBasicForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.businessNumberController,
    required this.addressController,
    required this.addressDetailController,
    required this.phoneController,
    required this.emailController,
    required this.depositAmountController,
    required this.remarkController,
    required this.isLoading,
    required this.depositYn,
    required this.businessType,
    required this.latitude,
    required this.longitude,
    required this.onAddressSearch,
    required this.onSave,
    required this.onDepositYnChanged,
    required this.onBusinessTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: nameController,
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
            controller: businessNumberController,
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
            initialValue: businessType,
            decoration: const InputDecoration(
              labelText: '사업장 종류',
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(value: 'OUT', child: Text('출장')),
              DropdownMenuItem(value: 'PARTNER', child: Text('제휴')),
            ],
            onChanged: isLoading ? null : onBusinessTypeChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사업장 종류를 선택해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: addressController,
            readOnly: true,
            onTap: onAddressSearch,
            decoration: const InputDecoration(
              labelText: '주소',
              hintText: '주소를 검색하세요',
              prefixIcon: Icon(Icons.location_on),
              suffixIcon: Icon(Icons.search),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '주소를 입력해주세요';
              }
              if (latitude == null || longitude == null) {
                return '주소 검색 후 선택해주세요 (위도/경도 필요)';
              }
              return null;
            },
          ),
          if (latitude != null && longitude != null) ...[
            const SizedBox(height: 8),
            Text(
              '위도: ${latitude!.toStringAsFixed(6)}, 경도: ${longitude!.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: addressDetailController,
            decoration: const InputDecoration(
              labelText: '상세주소',
              hintText: '상세주소를 입력하세요',
              prefixIcon: Icon(Icons.home),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
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
            controller: emailController,
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
            value: depositYn,
            onChanged: isLoading
                ? null
                : (value) {
                    onDepositYnChanged(value);
                    if (!value) depositAmountController.text = '';
                  },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: depositAmountController,
            decoration: const InputDecoration(
              labelText: '예약금',
              hintText: '0',
              prefixIcon: Icon(Icons.payments),
            ),
            enabled: depositYn && !isLoading,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (!depositYn) return null;
              final v = value?.trim() ?? '';
              if (v.isEmpty) return '예약금을 입력해주세요';
              final amount = int.tryParse(v);
              if (amount == null || amount < 0) {
                return '예약금은 0 이상의 숫자여야 합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: '비고',
              hintText: '비고를 입력하세요',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSave(),
          ),
        ],
      ),
    );
  }
}
