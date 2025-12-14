import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signup(name: _nameController.text.trim(), email: _emailController.text.trim(), phone: _phoneController.text.trim(), password: _passwordController.text);
      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 64, height: 64, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person_add_rounded, size: 32, color: Colors.white))),
                const SizedBox(height: 24),
                const Text('회원가입', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                const Text('출장세차 서비스를 시작하세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: '이름', hintText: '이름을 입력하세요', prefixIcon: Icon(Icons.person_outline)), validator: (value) => value == null || value.isEmpty ? '이름을 입력해주세요' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: '이메일', hintText: '이메일을 입력하세요', prefixIcon: Icon(Icons.email_outlined)), validator: (value) => value == null || value.isEmpty ? '이메일을 입력해주세요' : !value.contains('@') ? '올바른 이메일 형식이 아닙니다' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: '전화번호', hintText: '010-1234-5678', prefixIcon: Icon(Icons.phone_outlined)), validator: (value) => value == null || value.isEmpty ? '전화번호를 입력해주세요' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: '비밀번호', hintText: '비밀번호를 입력하세요', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (value) => value == null || value.isEmpty ? '비밀번호를 입력해주세요' : value.length < 6 ? '비밀번호는 6자 이상이어야 합니다' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호 확인', hintText: '비밀번호를 다시 입력하세요', prefixIcon: Icon(Icons.lock_outline)), validator: (value) => value != _passwordController.text ? '비밀번호가 일치하지 않습니다' : null),
                const SizedBox(height: 32),
                Consumer<AuthService>(builder: (context, authService, child) => ElevatedButton(onPressed: authService.isLoading ? null : _handleSignup, child: authService.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('가입하기'))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('이미 계정이 있으신가요?', style: TextStyle(color: AppColors.textSecondary)), TextButton(onPressed: () => Navigator.pop(context), child: const Text('로그인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)))]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

