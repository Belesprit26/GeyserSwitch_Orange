import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class TempRadio extends StatefulWidget {
  @override
  State<TempRadio> createState() => _TempRadioState();
}

class _TempRadioState extends State<TempRadio> {
  int _value = 0;
  var setTemp;

  //Realtime Database Reference Details
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final user = _firebaseAuth.currentUser!;
  get userID => user.uid;

  final _firebaseDB = FirebaseDatabase.instance.ref().child('Orange');

  Future<void> onUpdate() async {
    await _firebaseDB
        .child(userID)
        .child("setTemp")
        .get()
        .then((DataSnapshot snapshot) {
      int? spot = snapshot.value! as int?;

      setState(() {
        setTemp = spot!;

        if (setTemp == 65) {
          _value = 1;
        } else if (setTemp == 60) {
          _value = 2;
        } else if (setTemp == 50) {
          _value = 3;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    onUpdate();
  }

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Radio(
                activeColor: Colours.redColour,
                value: 1,
                groupValue: _value,
                onChanged: (value) {
                  setState(() {
                    _value = value!;
                  });

                  _firebaseDB.child(userID).update({"setTemp": 65});

                  if (_value == 1) {
                    CoreUtils.showSnackBar(context,
                        'Your desired maximum temperature is set to 65°C. \nThe geyser will switch off at 65°C');
                  }
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.pop(context, true);
                  });
                },
              ),
              const SizedBox(
                width: 6,
              ),
              const Text('65°C (Winter)'),
            ],
          ),
          Row(
            children: [
              Radio(
                activeColor: Colours.secondaryColour,
                value: 2,
                groupValue: _value,
                onChanged: (value) {
                  setState(() {
                    _value = value!;
                  });

                  _firebaseDB.child(userID).update({"setTemp": 60});

                  if (_value == 2) {
                    CoreUtils.showSnackBar(context,
                        'Your desired maximum temperature is set to 60°C. \nThe geyser will switch off at 60°C');
                  }
                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.pop(context, true);
                  });
                },
              ),
              const SizedBox(
                width: 6,
              ),
              const Text('60°C'),
            ],
          ),
          Row(
            children: [
              Radio(
                activeColor: Colours.greenColour,
                value: 3,
                groupValue: _value,
                onChanged: (value) {
                  setState(() {
                    _value = value!;
                  });

                  _firebaseDB.child(userID).update({"setTemp": 50});

                  if (_value == 3) {
                    CoreUtils.showSnackBar(context,
                        'Your desired maximum temperature is set to 50°C. \nThe geyser will switch off at 50°C');
                  }

                  Future.delayed(Duration(milliseconds: 300), () {
                    Navigator.pop(context, true);
                  });
                },
              ),
              const SizedBox(
                width: 6,
              ),
              const Text('50°C (Summer)'),
            ],
          ),
        ],
      ),
    );
  }
}
