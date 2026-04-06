import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_production/models/moduser.dart';
import 'package:sugar_production/core/constants/globals.dart' as globals;
import 'package:sugar_production/core/constants/api_constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sugar_production/core/db.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  static const _keyUsernameId = 'session_usernameid';
  static const _keyUsername = 'session_username';
  static const _keyFullname = 'session_fullname';
  static const _keyPassword = 'session_password';
  static const _keyLastActive = 'session_last_active';
  static const _sessionTimeout = Duration(hours: 8);

  Future<void> seedDefaultUsers() async {
    // Check if the default user already exists
    final existingUser = await DBHelper.getUserByUsername('1266');

    if (existingUser == null) {
      // Insert the default user
      await DBHelper.insertUser({
        'usernameid': 319,
        'username': '1266',
        'password': '12660',
        'fullname': 'Sample User',
      });

      // final permissions = [
      //   {'id': 1, 'user_id': 319, 'module_id': 1, 'has_access': 1},
      //   {'id': 2, 'user_id': 319, 'module_id': 2, 'has_access': 1},
      //   {'id': 3, 'user_id': 319, 'module_id': 3, 'has_access': 1},
      //   {'id': 4, 'user_id': 319, 'module_id': 4, 'has_access': 1},
      // ];

      // for (var p in permissions) await DBHelper.insertUserpermission(p);
    }
  }

  Future<String?> login(String username, String password) async {
    if (password.isEmpty) return 'Username and password are required';

    try {
      final localUser = await DBHelper.getUserByUsername(username);

      if (localUser != null) {
        if (localUser['password'] == password) {
          _currentUser = User(
            localUser['usernameid'] as int,
            localUser['username'] as String,
            localUser['password'] as String,
            localUser['fullname'] as String,
          );
          await _saveSession(_currentUser!);
          await _notifyBackgroundService(_currentUser!.usernameid);
          return null;
        } else {
          return 'Invalid password';
        }
      }

      final apiData = await _fetchUserFromApi(username);
      if (apiData == null) {
        return 'User not found. Please check your credentialsss.';
      }

      final apiPassword = apiData['user']['password'] as String;
      if (password != username.toString() && password != apiPassword) {
        return 'Invalid password';
      }

      await _saveUserDataLocally(apiData, password);

      _currentUser = User(
        apiData['user']['usernameid'] as int,
        apiData['user']['username'] as String,
        password,
        apiData['user']['fullname'] as String,
      );

      await _saveSession(_currentUser!);
      await _notifyBackgroundService(_currentUser!.usernameid);
      return null;
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>?> _fetchUserFromApi(String username) async {
    try {
      final url =
          "${ApiConstants.baseUrl}/${ApiConstants.users}?username=$username";
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              HttpHeaders.authorizationHeader: globals.globalhttpauth
                  .toString(),
            },
          )
          .timeout(const Duration(seconds: 10));

      print('API Status: ${response.statusCode}');
      print('API Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['data'] == null || decoded['data'].isEmpty) return null;

        final userData = decoded['data'][0];

        return {
          'user': {
            'usernameid': int.tryParse(userData['usernameid'].toString()) ?? 0,
            'username': userData['username'],
            'fullname': userData['fullname'],
            'password': userData['password'],
          },
        };
      } else {
        print('API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('API fetch error: $e');
      return null;
    }
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyUsernameId);
    if (id == null) return;

    final lastActiveMs = prefs.getInt(_keyLastActive);
    if (lastActiveMs != null) {
      final elapsed = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastActiveMs),
      );
      if (elapsed > _sessionTimeout) {
        await logout();
        return;
      }
    }

    _currentUser = User(
      id,
      prefs.getString(_keyUsername) ?? '',
      prefs.getString(_keyPassword) ?? '',
      prefs.getString(_keyFullname) ?? '',
    );

    globals.globalusernameid = id;
  }

  Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActive, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUsernameId, user.usernameid);
    await prefs.setString(_keyUsername, user.username);
    await prefs.setString(_keyFullname, user.fullname);
    await prefs.setString(_keyPassword, user.password);
    await prefs.setInt(_keyLastActive, DateTime.now().millisecondsSinceEpoch);

    globals.globalusernameid = user.usernameid;
  }

  Future<void> _notifyBackgroundService(int userid) async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('setUserId', {'user_id': userid.toString()});
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsernameId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyFullname);
    await prefs.remove(_keyLastActive);
    _currentUser = null;
  }

  Future<void> _saveUserDataLocally(
    Map<String, dynamic> apiData,
    String password,
  ) async {
    final user = apiData['user'];
    await DBHelper.insertUser({
      'usernameid': user['usernameid'],
      'username': user['username'],
      'fullname': user['fullname'],
      'password': password,
    });
  }

  Future<String?> syncUserOnly(String username) async {
    try {
      final apiData = await _fetchUserFromApi(username);
      if (apiData == null) return 'Failed to sync user from server';

      final user = apiData['user'];

      await DBHelper.insertUser({
        'usernameid': user['usernameid'],
        'username': user['username'],
        'fullname': user['fullname'],
        'password': user['password'],
      });

      return null;
    } catch (e) {
      return 'User sync failed: ${e.toString()}';
    }
  }
}
