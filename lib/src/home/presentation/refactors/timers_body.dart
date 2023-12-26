import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class TimersBody extends StatefulWidget {
  const TimersBody({Key? key}) : super(key: key);

  @override
  State<TimersBody> createState() => _TimersBodyState();
}

class _TimersBodyState extends State<TimersBody> {
  var is2AM = false;
  var is4AM = false;
  var is6AM = false;

  var is3PM = false;
  var is5PM = false;

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
        .child("2AM")
        .get()
        .then((DataSnapshot snapshot) {
      bool? spot = snapshot.value! as bool?;

      setState(() {
        is2AM = spot!;
      });
    });
    await _firebaseDB
        .child(userID)
        .child("4AM")
        .get()
        .then((DataSnapshot snapshot) {
      bool? spot = snapshot.value! as bool?;

      setState(() {
        is4AM = spot!;
      });
    });
    await _firebaseDB
        .child(userID)
        .child("6AM")
        .get()
        .then((DataSnapshot snapshot) {
      bool? spot = snapshot.value! as bool?;

      setState(() {
        is6AM = spot!;
      });
    });
    await _firebaseDB
        .child(userID)
        .child("3PM")
        .get()
        .then((DataSnapshot snapshot) {
      bool? spot = snapshot.value! as bool?;

      setState(() {
        is3PM = spot!;
      });
    });
    await _firebaseDB
        .child(userID)
        .child("5PM")
        .get()
        .then((DataSnapshot snapshot) {
      bool? spot = snapshot.value! as bool?;

      setState(() {
        is5PM = spot!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Morning Birds
        Container(
          height: 180,
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colours.secondaryColour,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Early Birds',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
              ),
              SizedBox(
                height: 40,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                //2am
                Column(children: [
                  Text(
                    '2AM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        is2AM = !is2AM;
                      });

                      _firebaseDB.child(userID).update({"2AM": is2AM});

                      if (is2AM) {
                        CoreUtils.showSnackBar(context,
                            'Your 2AM Timer has been turned ON Successfully. \nThe geyser will switch off at 4AM');
                      } else if (!is2AM) {
                        CoreUtils.showSnackBar(context,
                            'Your Your 2AM Timer has been turned OFF Successfully');
                      }
                    },
                    child: AnimatedContainer(
                      duration: animationDuration,
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: is2AM
                            ? Colours.primaryColour.withOpacity(.6)
                            : Colours.secondaryColour,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: is2AM
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade400.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: is2AM ? 10 : 2,
                          ),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: animationDuration,
                        alignment: is2AM
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                //4am
                Column(children: [
                  Text(
                    '4AM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        is4AM = !is4AM;
                      });

                      _firebaseDB.child(userID).update({"4AM": is4AM});

                      if (is4AM) {
                        CoreUtils.showSnackBar(context,
                            'Your 4AM Timer has been turned ON Successfully. \nThe geyser will switch off at 6AM');
                      } else if (!is4AM) {
                        CoreUtils.showSnackBar(context,
                            'Your 4AM Timer has been turned OFF Successfully');
                      }
                    },
                    child: AnimatedContainer(
                      duration: animationDuration,
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: is4AM
                            ? Colours.primaryColour.withOpacity(.6)
                            : Colours.secondaryColour,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: is4AM
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade400.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: is4AM ? 10 : 2,
                          ),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: animationDuration,
                        alignment: is4AM
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                //6am
                Column(children: [
                  Text(
                    '6AM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        is6AM = !is6AM;
                      });

                      _firebaseDB.child(userID).update({"6AM": is6AM});

                      if (is6AM) {
                        CoreUtils.showSnackBar(context,
                            'Your 6AM Timer has been turned ON Successfully. \nThe geyser will switch off at 8AM');
                      } else if (!is6AM) {
                        CoreUtils.showSnackBar(context,
                            'Your 6AM Timer has been turned OFF Successfully');
                      }
                    },
                    child: AnimatedContainer(
                      duration: animationDuration,
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: is6AM
                            ? Colours.primaryColour.withOpacity(.6)
                            : Colours.secondaryColour,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: is6AM
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade400.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: is6AM ? 10 : 2,
                          ),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: animationDuration,
                        alignment: is6AM
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ],
          ),
        ),
        SizedBox(
          height: 45,
        ),
        //Evening Owls
        Container(
          height: 180,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colours.secondaryColour,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Evening Owls',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
              ),
              SizedBox(
                height: 40,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                //3pm
                Column(children: [
                  Text(
                    '3PM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        is3PM = !is3PM;
                      });

                      _firebaseDB.child(userID).update({"3PM": is3PM});

                      if (is3PM) {
                        CoreUtils.showSnackBar(context,
                            'Your 3PM Timer has been turned ON Successfully. \nThe geyser will switch off at 5PM');
                      } else if (!is3PM) {
                        CoreUtils.showSnackBar(context,
                            'Your 3PM Timer has been turned OFF Successfully');
                      }
                    },
                    child: AnimatedContainer(
                      duration: animationDuration,
                      height: 40,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: is3PM
                            ? Colours.primaryColour.withOpacity(.6)
                            : Colours.secondaryColour,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: is3PM
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade400.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: is3PM ? 10 : 2,
                          ),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: animationDuration,
                        alignment: is3PM
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
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
                ]),
                //5pm
                Column(children: [
                  Text(
                    '5PM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        is5PM = !is5PM;
                      });

                      _firebaseDB.child(userID).update({"5PM": is5PM});

                      if (is5PM) {
                        CoreUtils.showSnackBar(context,
                            'Your 5PM Timer has been turned ON Successfully. \nThe geyser will switch off at 7PM');
                      } else if (!is5PM) {
                        CoreUtils.showSnackBar(context,
                            'Your 5PM Timer has been turned OFF Successfully');
                      }
                    },
                    child: AnimatedContainer(
                      duration: animationDuration,
                      height: 40,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: is5PM
                            ? Colours.primaryColour.withOpacity(.6)
                            : Colours.secondaryColour,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: is5PM
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade400.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: is5PM ? 10 : 2,
                          ),
                        ],
                      ),
                      child: AnimatedAlign(
                        duration: animationDuration,
                        alignment: is5PM
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
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
                ]),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
