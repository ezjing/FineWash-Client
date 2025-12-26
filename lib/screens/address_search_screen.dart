import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/address_service.dart';
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

  void _handleAddressSelected(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final result = AddressResult.fromJson(data);
      Navigator.pop(context, result);
    } catch (e) {
      debugPrint('주소 파싱 오류: $e');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('주소 검색'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
