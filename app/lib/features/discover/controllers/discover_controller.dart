import 'dart:async';

import 'package:flutter/foundation.dart';

enum DiscoverLoadState { loading, ready, error }

enum DiscoverConnectivity { online, offline, reconnecting }

/// Coordinates the session-only loading and connectivity states for Discover.
class DiscoverController extends ChangeNotifier {
  DiscoverLoadState state = DiscoverLoadState.ready;
  DiscoverConnectivity connectivity = DiscoverConnectivity.online;
  Timer? _loadTimer;
  Timer? _connectivityTimer;

  void load({Duration delay = const Duration(milliseconds: 400)}) {
    _loadTimer?.cancel();
    state = DiscoverLoadState.loading;
    notifyListeners();
    _loadTimer = Timer(delay, () {
      state = DiscoverLoadState.ready;
      notifyListeners();
    });
  }

  /// Exercises the same recoverable content failure shown by the feature.
  void showError() {
    _loadTimer?.cancel();
    state = DiscoverLoadState.error;
    notifyListeners();
  }

  void setOnline(bool online) {
    if (!online) {
      if (connectivity == DiscoverConnectivity.offline) return;
      _connectivityTimer?.cancel();
      connectivity = DiscoverConnectivity.offline;
      notifyListeners();
      return;
    }
    if (connectivity != DiscoverConnectivity.offline) return;
    connectivity = DiscoverConnectivity.reconnecting;
    notifyListeners();
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer(const Duration(milliseconds: 600), () {
      connectivity = DiscoverConnectivity.online;
      notifyListeners();
    });
  }

  void reset() {
    _loadTimer?.cancel();
    _connectivityTimer?.cancel();
    state = DiscoverLoadState.ready;
    connectivity = DiscoverConnectivity.online;
    notifyListeners();
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _connectivityTimer?.cancel();
    super.dispose();
  }
}
