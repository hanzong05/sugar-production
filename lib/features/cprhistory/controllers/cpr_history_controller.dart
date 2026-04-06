import 'package:flutter/material.dart';
import 'package:sugar_production/models/modcpr.dart';
import 'package:sugar_production/core/services/cpr_service.dart';
import 'package:sugar_production/core/services/data.dart';

class CprHistoryController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  List<CPR> _cprs = [];
  List<CPR> filteredCprs = [];
  bool isLoading = true;

  bool get hasUnsynced => _cprs.any((c) => c.traflag != 'S');
  int get unsyncedCount => _cprs.where((c) => c.traflag != 'S').length;

  CprHistoryController() {
    loadCprs();
    DataNotifier.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() => loadCprs();

  Future<void> loadCprs() async {
    isLoading = true;
    notifyListeners();

    try {
      final cprs = await CprService.getAllcpr();
      _cprs = cprs;
      final q = searchController.text;
      filteredCprs = q.isEmpty
          ? cprs
          : cprs.where((t) {
              final ref = t.colccprrefno.toLowerCase() ?? '';
              return ref.contains(q.toLowerCase());
            }).toList();
    } catch (e) {
      debugPrint('Error loading cprs: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCprs(String query) async {
    if (query.isEmpty) {
      filteredCprs = _cprs;
      notifyListeners();
      return;
    }
    try {
      final results = await CprService.searchcprs(query);
      filteredCprs = results;
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching cprs: $e');
    }
  }

  void clearSearch() {
    searchController.clear();
    searchCprs('');
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateString;
    }
  }

  @override
  void dispose() {
    DataNotifier.instance.removeListener(_onDataChanged);
    searchController.dispose();
    super.dispose();
  }
}
