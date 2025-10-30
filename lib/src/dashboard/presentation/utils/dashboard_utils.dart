import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/src/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardUtils {
  const DashboardUtils._();

  static Stream<LocalUserModel> get userDataStream => sl<FirebaseFirestore>()
      .collection('users')
      .doc(sl<FirebaseAuth>().currentUser!.uid)
      .snapshots()
      .map((event) => LocalUserModel.fromMap(event.data()!));
}
