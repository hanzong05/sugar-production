import 'package:flutter/foundation.dart';

/// Notifies listeners when CPR delivery data changes.
class DataNotifier extends ChangeNotifier {
  DataNotifier._();
  static final DataNotifier instance = DataNotifier._();

  void notify() => notifyListeners();
}

/// Notifies listeners when lot pictures data changes.
/// Kept separate from [DataNotifier] so CPR controllers don't react to
/// lot-picture saves, and vice versa.
class LotPicNotifier extends ChangeNotifier {
  LotPicNotifier._();
  static final LotPicNotifier instance = LotPicNotifier._();

  void notify() => notifyListeners();
}
