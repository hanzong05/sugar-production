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

  late final VoidCallback _dataListener;
  bool _disposed = false;

  PlanterReqController(String plcode) {
    _dataListener = () => loadData(plcode);
    loadData(plcode);
    DataNotifier.instance.addListener(_dataListener);
  }

  Future<void> loadData(String plcode) async {
    if (_disposed) return;
    isLoading = true;
    notifyListeners();
    try {
      final requests = await _requestService.getRequestsByPlanterWithDetails(
        plcode,
      );
      _requests = requests;
      _filteredRequests = List.from(requests);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void searchRequests(String query) {
    if (query.isEmpty) {
      _filteredRequests = List.from(_requests);
      notifyListeners();
      return;
    }
    final q = query.toLowerCase();
    _filteredRequests = _requests.where((r) {
      final req = r as Map<String, dynamic>;
      return (req['lot_location'] as String? ?? '').toLowerCase().contains(q) ||
          (req['request_no']?.toString() ?? '').contains(q);
    }).toList();
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    searchRequests('');
  }

  @override
  void dispose() {
    _disposed = true;
    DataNotifier.instance.removeListener(_dataListener);
    searchController.dispose();
    super.dispose();
  }
}
