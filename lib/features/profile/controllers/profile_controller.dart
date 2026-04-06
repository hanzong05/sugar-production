import 'package:flutter/material.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/core/services/data.dart';

class ProfileController extends ChangeNotifier {
  int unsyncedCount = 0;
  int totalCount = 0;
  bool isLoading = true;

  ProfileController() {
    loadStats();
    DataNotifier.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() => loadStats();

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
