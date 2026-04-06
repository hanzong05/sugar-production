import 'package:flutter/foundation.dart';

/// Global singleton that notifies all listeners whenever app data changes.
/// Call [DataNotifier.instance.notify()] after any insert, update, or delete.
class DataNotifier extends ChangeNotifier {
  DataNotifier._();
  static final DataNotifier instance = DataNotifier._();

  void notify() => notifyListeners();
}
