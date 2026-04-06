import 'package:flutter/material.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/core/services/auth_service.dart';
import 'package:sugar_production/core/constants/globals.dart' as globals;

class LoginController {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final passController = TextEditingController();
  final _authService = AuthService();

  void dispose() {
    codeController.dispose();
    passController.dispose();
  }

  /// [onNewUser] is called when the account was just synced (new local user).
  /// [onSuccess] is called when login succeeds for an existing local user.
  Future<LoginResult> submit() async {
    if (!formKey.currentState!.validate()) return LoginResult.validationFailed;

    final String username = codeController.text.trim();
    final existingUser = await DBHelper.getUserByUsername(username);
    final isNewUser = existingUser == null;

    final String? error = await _authService.login(
      username,
      passController.text,
    );

    if (error != null) {
      return LoginResult.error(error);
    }

    if (isNewUser) {
      _authService.logout();
      return LoginResult.newUser;
    }

    globals.globalusernameid = existingUser['usernameid'];
    return LoginResult.success;
  }
}

enum _LoginStatus { validationFailed, error, newUser, success }

class LoginResult {
  final _LoginStatus status;
  final String? errorMessage;

  const LoginResult._(this.status, {this.errorMessage});

  static const LoginResult validationFailed = LoginResult._(
    _LoginStatus.validationFailed,
  );
  static const LoginResult newUser = LoginResult._(_LoginStatus.newUser);
  static const LoginResult success = LoginResult._(_LoginStatus.success);
  static LoginResult error(String message) =>
      LoginResult._(_LoginStatus.error, errorMessage: message);

  bool get isValidationFailed => status == _LoginStatus.validationFailed;
  bool get isError => status == _LoginStatus.error;
  bool get isNewUser => status == _LoginStatus.newUser;
  bool get isSuccess => status == _LoginStatus.success;
}
