import 'package:flutter/material.dart';
import '../auth/terms_aggreement_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TermsAgreementScreen()), // 로그인
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.asset('assets/images/_splash.png'),
      ),
    ));
  }
}
