import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/core/services/data.dart';

class ProfileController extends ChangeNotifier {
  int unsyncedCount = 0;
  int totalCount = 0;
  bool isLoading = true;

  bool hasUpdate = false;
  bool forceUpdate = false;
  String latestVersion = "";
  String appVersion = "";
  bool checkingUpdate = false;
  String apkUrl = "";
  ProfileController() {
    loadStats();
    loadVersion();
    DataNotifier.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() => loadStats();

  Future<void> loadVersion() async {
    final packageinfo = await PackageInfo.fromPlatform();

    appVersion = "${packageinfo.version}(${packageinfo.buildNumber})";

    notifyListeners();

    await checkForUpdate();
  }

  static const _channel = MethodChannel('native/http');

  Future<void> checkForUpdate() async {
    checkingUpdate = true;
    notifyListeners();

    try {
      final raw = await _channel.invokeMethod<String>('post', {
        'url': 'https://cattarlac.com/sp-version/',
        'body': jsonEncode({"version": appVersion}),
      });
      // raw is "[STATUS] body" — strip the prefix, log for debugging
      final bracketEnd = raw!.indexOf('] ');
      final statusCode = raw.substring(1, bracketEnd);
      final body = raw.substring(bracketEnd + 2);
      debugPrint("Update check: HTTP $statusCode");
      final data = jsonDecode(body) as Map<String, dynamic>;

      hasUpdate = data["update"] ?? false;
      forceUpdate = data["force_update"] ?? false;
      latestVersion = data["latest_version"] ?? "";
      apkUrl = data["apk_url"] ?? "";
    } catch (e) {
      debugPrint("Update error: $e");
    } finally {
      checkingUpdate = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    final stats = await CprService.getSyncStats();
    unsyncedCount = stats['unsynced'] ?? 0;
    totalCount = stats['total'] ?? 0;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    DataNotifier.instance.removeListener(_onDataChanged);
    super.dispose();
  }
}
