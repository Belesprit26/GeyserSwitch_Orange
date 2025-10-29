import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/home_button_provider.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/presentation/geyser_entity.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/core/services/injection_container.dart';

class GeyserStatus extends StatefulWidget {
  final Geyser geyser;

  GeyserStatus({Key? key, required this.geyser}) : super(key: key);

  @override
  State<GeyserStatus> createState() => _GeyserStatusState();
}

class _GeyserStatusState extends State<GeyserStatus> {
  String? customName;

  late TextEditingController _customName;

  // Firebase references
  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();

  final _firebaseDB = sl<FirebaseDatabase>().ref().child('GeyserSwitch');

  // Get userID from FirebaseAuth
  String get userID => _firebaseAuth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _customName = TextEditingController();
  }

  @override
  void dispose() {
    _customName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<HomeButtonProvider>(context);

    return ChangeNotifierProvider<Geyser>.value(
      value: widget.geyser,
      child: Consumer<Geyser>(
        builder: (context, geyser, _) {
          final isGeyserOn = geyser.isOn;

          return Container(
            width: double.infinity,
            height: 70, // Adjusted height to accommodate additional text
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 7),
                // Existing geyser status text
                GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Geyser Label'),
                          content: TextField(
                            controller: _customName,
                            decoration: InputDecoration(hintText: "${geyser.name}"),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Update'),
                              onPressed: () async {
                                customName = _customName.text;

                                await _firebaseDB
                                    .child(userID)
                                    .child("Geysers")
                                    .child("${geyser.id}")
                                    .update({"name": customName});

                                 Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    isGeyserOn ? "${geyser.name} is On" : "${geyser.name} is Off",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}