import 'package:flutter/foundation.dart';

enum AppMode { remote, local }

class ModeProvider with ChangeNotifier {
  AppMode _mode = AppMode.remote;

  AppMode get mode => _mode;
  bool get isLocal => _mode == AppMode.local;
  bool get isRemote => _mode == AppMode.remote;

  void setLocal() {
    if (_mode != AppMode.local) {
      _mode = AppMode.local;
      notifyListeners();
    }
  }

  void setRemote() {
    if (_mode != AppMode.remote) {
      _mode = AppMode.remote;
      notifyListeners();
    }
  }
}


