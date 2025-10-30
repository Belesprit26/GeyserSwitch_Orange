import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/services/push_notifications/notification_router.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: Text('Please sign in to view notifications.')),
      );
    }

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('receivedAt', descending: true)
        .limit(100);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              final snap = await query.get();
              final batch = FirebaseFirestore.instance.batch();
              for (final d in snap.docs) {
                batch.set(d.reference, {'seen': true}, SetOptions(merge: true));
              }
              await batch.commit();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final title = (data['title'] as String?) ?? 'Notification';
              final body = (data['body'] as String?) ?? '';
              final seen = (data['seen'] as bool?) ?? false;
              final payload = (data['data'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
              return ListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: seen ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                subtitle: body.isNotEmpty ? Text(body) : null,
                trailing: seen ? null : const Icon(Icons.circle, size: 10, color: Colors.blueAccent),
                onTap: () async {
                  await doc.reference.set({'seen': true}, SetOptions(merge: true));
                  NotificationRouter.navigateFromData(context, payload);
                },
              );
            },
          );
        },
      ),
    );
  }
}


