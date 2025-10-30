import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ceat-logo-present-scaled.png',
              width: MediaQuery.of(context).size.width * 0.3,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 250.0,
              child: TypewriterAnimatedTextKit(
                text: const ['Secure by CEAT Dealer App'],
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 156, 157, 159),
                  letterSpacing: 1.1,
                ),
                speed: const Duration(milliseconds: 50),
                totalRepeatCount: 1,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF7300)),
            ),
          ],
        ),
      ),
    );
  }
}
