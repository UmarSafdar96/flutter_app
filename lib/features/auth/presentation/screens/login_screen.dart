import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/screens/user_info_screen.dart';
import 'package:flutter_app/features/auth/utils/custom_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/auth_state.dart';
import '../../utils/loading_overlay.dart';
import '../../utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen to the authViewModelProvider inside the build method
    ref.listen<AuthState>(
      authViewModelProvider,
          (previous, next) {
        debugPrint("LISTEN TRIGGERED. sentEmail: ${next.sentEmail}");
        debugPrint("Previous state: ${previous?.sentEmail}, Next state: ${next.sentEmail}");

        // Only navigate if sentEmail changes from false to true
        if (next.isSuccess && !(previous?.isSuccess ?? false)) {
          if (mounted) { // Check if the widget is still mounted
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const UserInfoScreen(),
              ),
            );
            // Reset the sentEmail state in the ViewModel
            ref.read(authViewModelProvider.notifier).resetSentEmail();
          }
        }

        // Handle messages (e.g., success, error)
        // if (next.message != null && next.message != previous?.message) {
        //   // You might want to differentiate between error and info messages
        //   showCustomDialog(
        //     context: context,
        //     title: "Info", // Adjust title based on message type
        //     message: next.message!,
        //   );
        // }
      },
    );


    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text("Welcome Back!",
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Enter your credentials to securely access your\naccount and stay in control of your tokenized data",
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
                  controller: passController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: "Enter your password",
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
                const SizedBox(height: 24),

                // Login Button
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
                      final password = passController.text;

                      if (!Validators.isValidEmail(email)) {

                        showCustomDialog(context: context, title: 'Invalid Email', message: 'Please eneter a valid email');
                        return;
                      }

                      if (password.isEmpty) {
                        showCustomDialog(context: context, title: 'Empty Password', message: 'Password is required');
                        return;
                      }

                      ref.read(authViewModelProvider.notifier).login(email, password);
                    },
                    child: const Text("Login", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password
                    },
                    child: const Text("Forget your password?", style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Show Loading Overlay if loading
        if (authState.isLoading) const LoadingOverlay(message: 'Checking Credentials',),
      ],
    );
  }
}



