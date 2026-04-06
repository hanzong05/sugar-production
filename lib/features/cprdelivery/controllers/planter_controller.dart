import 'package:flutter/material.dart';
import 'package:sugar_production/core/services/planter_service.dart';
import 'package:sugar_production/models/modplanter.dart';

class PlanterController extends ChangeNotifier {
  final PlanterServices _planterServices = PlanterServices();
  final TextEditingController searchController = TextEditingController();

  List<Planter> _planters = [];
  List<Planter> _filteredPlanters = [];
  bool isLoading = true;

  List<Planter> get filteredPlanters => _filteredPlanters;

  CPRController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final planters = await _planterServices.getAllPlanters();
      _planters = planters;
      _filteredPlanters = planters;
    } catch (e) {
      debugPrint('Error loading planters: $e');
      rethrow; // let the screen handle the SnackBar
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPlanters(String query) async {
    if (query.isEmpty) {
      _filteredPlanters = _planters;
      notifyListeners();
      return;
    }

    try {
      final results = await _planterServices.searchPlanters(query);
      _filteredPlanters = results;
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching planters: $e');
    }
  }

  void clearSearch() {
    searchController.clear();
    searchPlanters('');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
