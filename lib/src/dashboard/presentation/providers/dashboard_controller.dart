import 'package:gs_orange/core/common/app/providers/tab_navigator.dart';
import 'package:gs_orange/core/common/views/persistent_view.dart';
import 'package:gs_orange/src/home/presentation/views/home_view.dart';
import 'package:gs_orange/src/loadshedding/presentation/pages/loadshedding_page.dart';
import 'package:gs_orange/src/profile/presentation/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardController extends ChangeNotifier {
  List<int> _indexHistory = [0];
  final List<Widget> _screens = [
    ChangeNotifierProvider(
      create: (_) => TabNavigator(TabItem(child: const HomeView())),
      child: const PersistentView(),
    ),
    //Eskom Se Push Api page
    /* ChangeNotifierProvider(
      create: (_) => TabNavigator(TabItem(child: const LoadSheddingPage())),
      child: const PersistentView(),
    ),*/
    ChangeNotifierProvider(
      create: (_) => TabNavigator(TabItem(child: const Placeholder())),
      child: const PersistentView(),
    ),
    ChangeNotifierProvider(
      create: (_) => TabNavigator(TabItem(child: const ProfileView())),
      child: const PersistentView(),
    ),
  ];

  List<Widget> get screens => _screens;
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    _indexHistory.add(index);
    notifyListeners();
  }

  void goBack() {
    if (_indexHistory.length == 1) return;
    _indexHistory.removeLast();
    _currentIndex = _indexHistory.last;
    notifyListeners();
  }

  void resetIndex() {
    _indexHistory = [0];
    _currentIndex = 0;
    notifyListeners();
  }
}
