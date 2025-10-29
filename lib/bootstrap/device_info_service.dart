import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gs_orange/core/models/device_info_record_model.dart';
import 'package:gs_orange/core/services/injection_container.dart';
import 'package:gs_orange/core/utils/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  Future<DeviceInfoRecordModel> collect({String? fcmToken}) async {
    final package = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    String model = '';
    String brand = '';
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      model = android.model;
      brand = android.brand;
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      model = ios.utsname.machine;
      brand = 'Apple';
    }

    return DeviceInfoRecordModel(
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      deviceModel: model,
      deviceBrand: brand,
      appVersion: package.version,
      buildNumber: package.buildNumber,
      fcmToken: fcmToken,
    );
  }

  Future<void> upsertForCurrentUser({String? preferredDocId}) async {
    final auth = sl<FirebaseAuth>();
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e, s) {
      Log.e(e, s, 'getTokenForDeviceInfo');
    }
    final rec = await collect(fcmToken: token);
    final firestore = sl<FirebaseFirestore>();
    final docId = token ?? preferredDocId ?? 'bootstrap';
    await firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(docId)
        .set({
      ...rec.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}


