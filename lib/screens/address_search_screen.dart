import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/address_result.dart';
import '../repositories/address_repository.dart';
import '../utils/app_colors.dart';

/// 다음 우편번호 서비스를 이용한 주소 검색 화면
class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'onComplete',
        onMessageReceived: (message) {
          _handleAddressSelected(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // debugPrint('페이지 로드 시작: $url');
          },
          onPageFinished: (url) {
            // debugPrint('페이지 로드 완료: $url');
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView 에러: ${error.description}');
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_getHtmlContent(), baseUrl: 'https://t1.daumcdn.net');
  }

  Future<void> _handleAddressSelected(String message) async {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final result = AddressResult.fromJson(data);

      final query = result.fullAddress.trim();
      if (query.isEmpty) return;

      setState(() => _isGeocoding = true);
      final repo = AddressRepository();
      final coords = await repo.searchLogic1Geocode(query: query);
      final lat = coords?['latitude'];
      final lng = coords?['longitude'];
      if (lat == null || lng == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('좌표 정보를 찾을 수 없습니다.')));
        }
        return;
      }

      if (!mounted) return;
      Navigator.pop(context, result.copyWith(latitude: lat, longitude: lng));
    } catch (e) {
      debugPrint('주소 파싱 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('주소 처리 중 오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>주소 검색</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        #wrap {
            width: 100%;
            height: 100%;
            position: absolute;
            top: 0;
            left: 0;
        }
    </style>
</head>
<body>
    <div id="wrap"></div>
    <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script>
        new daum.Postcode({
            oncomplete: function(data) {
                // 도로명 주소 우선, 없으면 지번 주소
                var address = data.roadAddress || data.jibunAddress;
                
                var result = {
                    address: address,
                    jibunAddress: data.jibunAddress || '',
                    zonecode: data.zonecode || '',
                    buildingName: data.buildingName || '',
                    sido: data.sido || '',
                    sigungu: data.sigungu || '',
                    bname: data.bname || '',
                    roadAddress: data.roadAddress || ''
                };
                
                // Flutter로 결과 전송
                onComplete.postMessage(JSON.stringify(result));
            },
            width: '100%',
            height: '100%'
        }).embed(document.getElementById('wrap'));
    </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading || _isGeocoding)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: SizedBox(height: mediaQuery.padding.bottom),
            ),
          ),
        ],
      ),
    );
  }
}
