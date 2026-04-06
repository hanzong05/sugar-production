import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/layout.dart';
import '../controller/login_controller.dart';
import '../widgets/login_button.dart';
import '../widgets/login_header.dart';
import '../widgets/login_text_field.dart';
import '../widgets/sync_success_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ctrl = LoginController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final result = await _ctrl.submit();
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(result.errorMessage!)),
            ],
          ),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    } else if (result.isNewUser) {
      await SyncSuccessDialog.show(context);
    } else if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _ctrl.formKey,
                child: Column(
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 36),

                    // Username
                    LoginTextField(
                      controller: _ctrl.codeController,
                      hint: 'Username',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter your username' : null,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    LoginTextField(
                      controller: _ctrl.passController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter your password' : null,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: const Color(0xFF6B7280),
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    LoginButton(isLoading: _isLoading, onPressed: _submit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
