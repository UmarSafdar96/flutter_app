import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/sign_up.dart';
import 'package:flutter_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/auth_state.dart';
import '../../utils/loading_overlay.dart';
import '../viewmodels/auth_viewmodel.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _handledNavigation = false;

  @override
  void initState() {
    super.initState();

    // Wait until the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now it's safe to listen to providers
      ref.listen<AuthState>(authViewModelProvider, (prev, next) {
        if (next.sentEmail && !_handledNavigation) {
          _handledNavigation = true;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const VerifyEmailScreen(),
            ),
          );

          ref.read(authViewModelProvider.notifier).resetSentEmail();
        }
      });
    });
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    ref.read(authViewModelProvider.notifier).clearMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            foregroundColor: Colors.white,
           // leading: const BackButton(),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: !_isLogin ? null : _toggleAuthMode,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: _isLogin ? Colors.grey : Colors.white,
                          fontWeight: _isLogin ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text("/", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _isLogin ? null : _toggleAuthMode,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: _isLogin ? Colors.white : Colors.grey,
                          fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: _isLogin ? const LoginScreen() : const SignUpScreen(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}