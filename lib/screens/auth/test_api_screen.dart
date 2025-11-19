// lib/screens/auth/api_test_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// 서비스 및 유틸리티 import
import '../../services/auth_service.dart';
import '../../utils/dialog.dart'; 

// 주의: 백엔드 서버의 실제 주소로 변경하세요.
const String BACKEND_BASE_URL = 'http://localhost:3000';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

enum TestStatus {
  signUpForm,
  verificationPending,
  readyToTestApi,
  apiTesting,
  apiResult,
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  TestStatus _currentStatus = TestStatus.signUpForm;
  String _statusMessage = '회원가입을 진행하여 테스트를 시작합니다.';
  String _apiResultBody = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 로그인 상태 확인 및 상태 업데이트
    _checkInitialState();
  }

  void _checkInitialState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      // 이미 로그인 & 인증 완료 상태라면 바로 API 테스트로 이동
      _currentStatus = TestStatus.readyToTestApi;
      _statusMessage = '✅ 로그인/인증 완료! API 호출 준비됨.';
    }
  }

  // 1. 회원가입 및 인증 메일 발송 처리
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signUpAndSendVerification(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _currentStatus = TestStatus.verificationPending;
        _statusMessage = '메일 발송됨. 팝업을 닫고 메일 확인 후 "인증 완료"를 눌러주세요.';
        _isLoading = false;
      });

      // 2. 인증 확인 팝업 호출 (팝업 내에서 인증 완료 후 상태 업데이트)
      showVerificationDialog(context); 

    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = '가입 오류: ${e.code}';
        _isLoading = false;
      });
      // 실제 앱에서는 SnackBar로 표시
      print("Firebase Auth Error: ${e.message}");
    } catch (e) {
       setState(() => _isLoading = false);
    }
  }

  // 3. 보호된 API 호출 테스트
  Future<void> _testProtectedApi() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 로그인 필수

    setState(() {
      _currentStatus = TestStatus.apiTesting;
      _isLoading = true;
    });

    try {
      final String? idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$BACKEND_BASE_URL/social/friends'), 
        headers: {'Authorization': 'Bearer $idToken'},
      );

      setState(() {
        _currentStatus = TestStatus.apiResult;
        _isLoading = false;
        _apiResultBody = '상태 코드: ${response.statusCode}\n';
        _apiResultBody += '응답 내용: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...';
      });

    } catch (e) {
      setState(() {
        _apiResultBody = '네트워크 오류: $e';
        _isLoading = false;
      });
    }
  }

  // 4. 상태에 따른 UI 빌드 분기
  Widget _buildUI() {
    switch (_currentStatus) {
      case TestStatus.signUpForm:
      case TestStatus.verificationPending:
        return _buildSignUpForm();
      case TestStatus.readyToTestApi:
      case TestStatus.apiTesting:
      case TestStatus.apiResult:
        return _buildApiTestUI();
    }
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: '이메일'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? '이메일 필수' : null,),
          TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: '비밀번호'), obscureText: true, validator: (v) => v!.length < 6 ? '6자 이상' : null,),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            child: Text(_currentStatus == TestStatus.verificationPending ? '메일 발송 완료' : '회원가입/메일 발송'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildApiTestUI() {
    return Column(
      children: [
        const Text('✅ 인증 완료! 백엔드 테스트를 시작합니다.'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _testProtectedApi,
          child: Text(_currentStatus == TestStatus.apiTesting ? '호출 중...' : '보호된 API 호출'),
        ),
        const SizedBox(height: 30),
        Text(_apiResultBody, style: const TextStyle(fontFamily: 'monospace')),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('통합 인증/API 테스트 화면')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_statusMessage, style: TextStyle(color: _apiResultBody.contains('403') ? Colors.red : Colors.green)),
              const SizedBox(height: 30),
              if (_isLoading) const CircularProgressIndicator(),
              _buildUI(),
              
            ],
          ),
        ),
      ),
    );
  }
}