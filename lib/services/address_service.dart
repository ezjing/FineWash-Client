import 'package:flutter/foundation.dart';
import '../repositories/address_repository.dart';

class AddressService extends ChangeNotifier {
  final AddressRepository _addressRepository = AddressRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Map<String, double>?> geocodeAddress({required String address}) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _addressRepository.searchLogic1Geocode(query: address);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
