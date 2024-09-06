import 'package:gs_orange/src/auth/data/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  LocalUserModel? _user;
  String? _cachedProfileImagePath;

  LocalUserModel? get user => _user;
  String? get cachedProfileImagePath => _cachedProfileImagePath;

  // Initialize user
  void initUser(LocalUserModel? user) {
    if (_user != user) _user = user;
    loadProfileImagePath(); // Load the cached image path on initialization
  }

  // Set user with notification
  set user(LocalUserModel? user) {
    if (_user != user) {
      _user = user;
      Future.delayed(Duration.zero, notifyListeners);
    }
  }

  // Load profile image path from SharedPreferences
  Future<void> loadProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedProfileImagePath = prefs.getString('profileImagePath');
    notifyListeners(); // Notify listeners to update the UI when the image is loaded
  }

  // Save and update cached profile image path
  Future<void> updateProfileImage(String imagePath) async {
    _cachedProfileImagePath = imagePath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', imagePath);
    notifyListeners();
  }

  // Save profile image path to SharedPreferences
  Future<void> saveProfileImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', imagePath);
    _cachedProfileImagePath = imagePath;
    notifyListeners(); // Notify listeners to update the UI when the image is saved
  }

  // Clear the cached profile image path (if needed)
  Future<void> clearProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImagePath');
    _cachedProfileImagePath = null;
    notifyListeners(); // Notify listeners to clear the UI
  }
}