import 'package:flutter/material.dart';
import 'package:sugar_production/core/services/request_service.dart';
import 'package:sugar_production/core/services/data.dart';

class PlanterReqController extends ChangeNotifier {
  final RequestService _requestService = RequestService();
  final TextEditingController searchController = TextEditingController();

  List<dynamic> _requests = [];
  List<dynamic> _filteredRequests = [];
  bool isLoading = true;

  List<dynamic> get filteredRequests => _filteredRequests;

  PlanterReqController(String plcode) {
    loadData(plcode);
    DataNotifier.instance.addListener(() => loadData(plcode));
  }

  Future<void> loadData(String plcode) async {
    isLoading = true;
    notifyListeners();
    try {
      final requests = await _requestService.getRequestsByPlanterWithDetails(
        plcode,
      );
      _requests = requests;
      _filteredRequests = requests;
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRequests(String query) async {
    if (query.isEmpty) {
      _filteredRequests = _requests;
      notifyListeners();
      return;
    }
    try {
      final results = await _requestService.searchRequest(query);
      _filteredRequests = results;
      notifyListeners();
    } catch (e) {
      debugPrint('Error Searching Requests: $e');
    }
  }

  void clearSearch() {
    searchController.clear();
    searchRequests('');
  }

  @override
  void dispose() {
    searchController.dispose();
    DataNotifier.instance.removeListener(() {});
    super.dispose();
  }
}
