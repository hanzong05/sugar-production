import 'package:flutter/material.dart';
import 'package:sugar_production/core/services/sync_service.dart';
import 'package:sugar_production/core/services/data.dart';

class SyncController extends ChangeNotifier {
  final _syncService = SyncService();

  bool isSyncing = false;
  double progress = 0.0;
  String statusText = '';

  Future<bool> sync(BuildContext context, int conntype) async {
    isSyncing = true;
    progress = 0.0;
    statusText = 'Connecting...';
    notifyListeners();

    _syncService.onProgress = (p, s) {
      progress = p;
      statusText = s;
      notifyListeners();
    };

    try {
      final success = await _syncService.checkiffirst(context, conntype);
      if (success) DataNotifier.instance.notifyListeners();
      return success;
    } catch (e) {
      rethrow;
    } finally {
      isSyncing = false;
      _syncService.onProgress = null;
      notifyListeners();
    }
  }
}
