import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/auth_state.dart';
import '../../utils/custom_dialog.dart';
import '../../utils/loading_overlay.dart';
import '../viewmodels/auth_viewmodel.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Keep initState clean for controller initialization
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the authViewModelProvider inside the build method
    ref.listen<AuthState>(
      authViewModelProvider,
          (previous, next) {
        debugPrint("LISTEN TRIGGERED. sentEmail: ${next.sentEmail}");
        debugPrint("Previous state: ${previous?.sentEmail}, Next state: ${next.sentEmail}");

        // Only navigate if sentEmail changes from false to true
        if (next.sentEmail && !(previous?.sentEmail ?? false)) {
          if (mounted) { // Check if the widget is still mounted
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VerifyEmailScreen(),
              ),
            );
            // Reset the sentEmail state in the ViewModel
            ref.read(authViewModelProvider.notifier).resetSentEmail();
          }
        }

        // Handle messages (e.g., success, error)
        if (next.message != null && next.message != previous?.message) {
          // You might want to differentiate between error and info messages
          showCustomDialog(
            context: context,
            title: "Info", // Adjust title based on message type
            message: next.message!,
          );
        }
      },
    );

    final authState = ref.watch(authViewModelProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 32),
                const Text("Join us and Secure your\ndigital Identity",
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Create your account to tokenise your ID",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Email Field
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: "Enter your email",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: "Create a strong Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Re-Type Password",
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: "Type your password again",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      final confirmPassword = confirmPasswordController.text;

                      if (password != confirmPassword) {
                        showCustomDialog(
                          context: context,
                          title: "Error",
                          message: "Passwords do not match.",
                        );
                        return;
                      }

                      ref.read(authViewModelProvider.notifier).signup(email, password);
                    },
                    child: const Text("Continue", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Show loading overlay
        if (authState.isLoading)
          const LoadingOverlay(message: 'Creating Account...'),
      ],
    );
  }
}