import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/storage/hive_manager.dart';
import 'package:flutter_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/otp_viewmodel.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        setState(() {}); // update button state
      });
    }
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get isOtpComplete =>
      _controllers.every((c) => c.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpViewModelProvider);
    final email =  HiveManager.box.get('user_email');


    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Your custom logic here (e.g. clear Hive, reset state, etc.)

              //  Then call default back action
              ref.read(authViewModelProvider.notifier).resetSentEmail();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AuthScreen()),
                ); // fallback
              }
            },
          ),
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "OTP Verification",
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verify your Email to Get Started",
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Type the code we have just sent you on\n$email",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 55,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOtpComplete &&
                    !otpState.isLoading
                    ? (){

                  final otp = _controllers.map((c) => c.text).join();
                  ref.read(otpViewModelProvider.notifier).verifyOtp(otp);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isOtpComplete ? const Color(0xFFFF5F6D) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: otpState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account", style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: _secondsRemaining == 0 ? _startTimer : null,
                child: Text(
                  "Resend Code ${_secondsRemaining > 0 ? '(${_secondsRemaining.toString().padLeft(2, '0')})' : ''}",
                  style: TextStyle(
                    color: _secondsRemaining == 0 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

