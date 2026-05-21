import 'package:flutter/material.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/core/services/data.dart';
import 'package:sugar_production/core/constants/globals.dart' as globals;

class HomeController extends ChangeNotifier {
  List<int> accessibleModuleIds = [];
  bool isLoading = true;

  HomeController() {
    DataNotifier.instance.addListener(_onDataChanged);
    loadPermissions();
  }

  void _onDataChanged() => loadPermissions();

  Future<void> loadPermissions() async {
    final userId = globals.globalusernameid;
    if (userId != null) {
      accessibleModuleIds = await DBHelper.getAccessibleModuleIds();
    }
    isLoading = false;
    notifyListeners();
  }

  // 👇 add this alias
  Future<void> loadModules() async {
    await loadPermissions();
  }

  bool canAccess(int moduleId) => accessibleModuleIds.contains(moduleId);

  @override
  void dispose() {
    DataNotifier.instance.removeListener(_onDataChanged);
    super.dispose();
  }
}
