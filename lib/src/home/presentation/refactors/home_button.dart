import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/res/media_res.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class HomeButton extends StatefulWidget {
  const HomeButton({Key? key}) : super(key: key);

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  var isEnabled = false;
  final animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    onUpdate();
  }

  //Realtime Database Reference Details
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final user = _firebaseAuth.currentUser!;
  get userID => user.uid;

  final _firebaseDB = FirebaseDatabase.instance.ref().child('Orange');

  Future<void> onUpdate() async {
    await _firebaseDB
        .child(userID)
        .child("Switch_1")
        .get()
        .then((DataSnapshot snapshot) {
      bool? spot = snapshot.value! as bool?;

      setState(() {
        isEnabled = spot!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            isEnabled = !isEnabled;
          });

          _firebaseDB.child(userID).update({"Switch_1": isEnabled});

          if (isEnabled) {
            CoreUtils.showSnackBar(
                context, 'Your Geyser has been turned ON Successfully');
          } else if (!isEnabled) {
            CoreUtils.showSnackBar(
                context, 'Your Geyser has been turned OFF Successfully');
          }
        },
        child: AnimatedContainer(
          duration: animationDuration,
          height: 40,
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isEnabled
                ? Colours.primaryColour.withOpacity(.5)
                : Colours.secondaryColour,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: isEnabled
                    ? Colours.primaryColour.withOpacity(.4)
                    : Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: isEnabled ? 10 : 2,
              ),
            ],
          ),
          child: AnimatedAlign(
            duration: animationDuration,
            alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
