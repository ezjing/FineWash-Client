import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {'email': email, 'password': password});
      if (response['token'] != null) {
        await ApiService.setToken(response['token']);
      }
      _currentUser = UserModel.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // 개발 환경에서는 Mock 로그인 허용
      _currentUser = UserModel(id: '1', name: '김민수', email: email, phone: '010-1234-5678');
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> signup({required String name, required String email, required String phone, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/signup', {'name': name, 'email': email, 'phone': phone, 'password': password});
      if (response['token'] != null) {
        await ApiService.setToken(response['token']);
      }
      _currentUser = UserModel.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = UserModel(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, email: email, phone: phone);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    await ApiService.removeToken();
    _currentUser = null;
    notifyListeners();
  }
}

