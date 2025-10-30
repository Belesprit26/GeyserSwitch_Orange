import 'dart:convert';

import 'package:flutter/material.dart';

class NotificationTarget {
  const NotificationTarget({required this.routeName, this.arguments});
  final String routeName;
  final Object? arguments;
}

class NotificationRouter {
  static const Set<String> _allowedRoutes = <String>{
    '/',
    '/dashboard',
    '/notifications',
    '/sign-in',
    '/sign-up',
  };

  static NotificationTarget? mapFromData(Map<String, dynamic> data) {
    final route = (data['route'] ?? data['screen']) as String?;
    if (route == null || !_allowedRoutes.contains(route)) {
      return null;
    }

    Object? args;
    if (data.containsKey('args')) {
      final raw = data['args'];
      if (raw is String) {
        try {
          args = json.decode(raw);
        } catch (_) {
          args = raw;
        }
      } else if (raw is Map<String, dynamic>) {
        args = raw;
      }
    }
    return NotificationTarget(routeName: route, arguments: args);
  }

  static void navigateFromData(BuildContext context, Map<String, dynamic> data) {
    final target = mapFromData(data);
    if (target == null) return;
    Navigator.of(context).pushNamed(target.routeName, arguments: target.arguments);
  }
}


