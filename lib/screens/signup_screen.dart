import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'address_search_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String _gender = 'M';
  final _addressController = TextEditingController();
  final _addressDetailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _addressDetailController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        gender: _gender,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        addressDetail: _addressDetailController.text.trim().isEmpty ? null : _addressDetailController.text.trim(),
      );
      if (success && mounted) {
        // 완료 다이얼로그를 보여주고 사용자가 확인하면 화면을 닫음
        await showDialog(
          context: context,
          barrierDismissible: false, // 확인을 반드시 누르게 함
          builder: (ctx) => AlertDialog(
            title: const Text('회원가입'),
            content: const Text('회원가입이 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(), // 다이얼로그 닫기
                child: const Text('확인'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.pop(context); // 가입 화면 닫기
      }
      else {
        if (mounted) {
          final error = authService.lastError ?? '회원가입에 실패했습니다. 다시 시도해주세요.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: bottomPadding + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '출장세차 서비스를 시작하세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력하세요',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '이름을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: '이메일을 입력하세요',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? '이메일을 입력해주세요'
                    : !value.contains('@')
                    ? '올바른 이메일 형식이 아닙니다'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-1234-5678',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '전화번호를 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? '비밀번호를 입력해주세요'
                    : value.length < 6
                    ? '비밀번호는 6자 이상이어야 합니다'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '비밀번호를 다시 입력하세요',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) => value != _passwordController.text
                    ? '비밀번호가 일치하지 않습니다'
                    : null,
              ),
              const SizedBox(height: 16),
              // Gender selection
	            Row(
	              children: [
	                Expanded(
	                  child: ListTile(
	                    contentPadding: EdgeInsets.zero,
	                    title: const Text('남'),
	                    leading: Radio<String>(
	                      value: 'M',
	                      groupValue: _gender,
	                      onChanged: (v) => setState(() => _gender = v!),
	                    ),
	                  ),
	                ),
	                Expanded(
	                  child: ListTile(
	                    contentPadding: EdgeInsets.zero,
	                    title: const Text('여'),
	                    leading: Radio<String>(
	                      value: 'F',
	                      groupValue: _gender,
	                      onChanged: (v) => setState(() => _gender = v!),
	                    ),
	                  ),
	                ),
	              ],
	            ),
	          const SizedBox(height: 8),
                // Address search (Daum postcode)
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  onTap: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressSearchScreen()));
                    if (result != null) {
                      setState(() => _addressController.text = (result as dynamic).fullAddress as String);
                    }
                  },
                  decoration: const InputDecoration(labelText: '주소', hintText: '주소를 검색하세요', prefixIcon: Icon(Icons.location_on_outlined)),
                ),
                const SizedBox(height: 8),
                TextFormField(controller: _addressDetailController, decoration: const InputDecoration(labelText: '상세주소', hintText: '상세주소를 입력하세요', prefixIcon: Icon(Icons.edit_outlined))),
                const SizedBox(height: 16),                
                Consumer<AuthService>(builder: (context, authService, child) => ElevatedButton(onPressed: authService.isLoading ? null : _handleSignup, child: authService.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('가입하기'))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('이미 계정이 있으신가요?', style: TextStyle(color: AppColors.textSecondary)), TextButton(onPressed: () => Navigator.pop(context), child: const Text('로그인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)))]),
              const SizedBox(height: 32),
              Consumer<AuthService>(
                builder: (context, authService, child) => ElevatedButton(
                  onPressed: authService.isLoading ? null : _handleSignup,
                  child: authService.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('가입하기'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
