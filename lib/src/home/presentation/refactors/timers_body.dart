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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Early Birds',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 21),
        ),
        SizedBox(
          height: 15,
        ),
        //02h00
        Container(
          width: MediaQuery.of(context).size.width * .93,
          height: MediaQuery.of(context).size.height * .07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white70,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "02:00",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 27),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      is2AM = !is2AM;
                    });

                    final send =
                        await _firebaseDB.child(userID).update({"2AM": is2AM});

                    if (is2AM) {
                      CoreUtils.showSnackBar(context,
                          'Your 2AM Timer has been turned ON Successfully. \nThe geyser will run from 2am to 4am');
                    } else if (!is2AM) {
                      CoreUtils.showSnackBar(context,
                          'Your 2AM Timer has been turned OFF Successfully');
                    }
                  },
                  child: AnimatedContainer(
                    duration: animationDuration,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: is2AM
                          ? Colours.primaryOrange.withOpacity(.5)
                          : Colours.secondaryColour,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: is2AM
                              ? Colours.primaryOrange.withOpacity(.2)
                              : Colors.grey.shade400.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: is2AM ? 10 : 2,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: animationDuration,
                      alignment:
                          is2AM ? Alignment.centerRight : Alignment.centerLeft,
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        //04h00
        Container(
          width: MediaQuery.of(context).size.width * .93,
          height: MediaQuery.of(context).size.height * .07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white70,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "04:00",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 27),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      is4AM = !is4AM;
                    });

                    final send =
                        await _firebaseDB.child(userID).update({"4AM": is4AM});

                    if (is4AM) {
                      CoreUtils.showSnackBar(context,
                          'Your 4AM Timer has been turned ON Successfully. \nThe geyser will run from 4am to 6am');
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
                          ? Colours.primaryOrange.withOpacity(.5)
                          : Colours.secondaryColour,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: is4AM
                              ? Colours.primaryOrange.withOpacity(.2)
                              : Colors.grey.shade400.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: is4AM ? 10 : 2,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: animationDuration,
                      alignment:
                          is4AM ? Alignment.centerRight : Alignment.centerLeft,
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Container(
          width: MediaQuery.of(context).size.width * .93,
          height: MediaQuery.of(context).size.height * .07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white70,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "06:00",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 27),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      is6AM = !is6AM;
                    });

                    final send =
                        await _firebaseDB.child(userID).update({"6AM": is6AM});

                    if (is6AM) {
                      CoreUtils.showSnackBar(context,
                          'Your 6AM Timer has been turned ON Successfully. \nThe geyser will run from 6am to 8am');
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
                          ? Colours.primaryOrange.withOpacity(.5)
                          : Colours.secondaryColour,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: is6AM
                              ? Colours.primaryOrange.withOpacity(.2)
                              : Colors.grey.shade400.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: is6AM ? 10 : 2,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: animationDuration,
                      alignment:
                          is6AM ? Alignment.centerRight : Alignment.centerLeft,
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Text(
          'Evening Owls',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 21),
        ),
        SizedBox(
          height: 15,
        ),
        //15h00
        Container(
          width: MediaQuery.of(context).size.width * .93,
          height: MediaQuery.of(context).size.height * .07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white70,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "15:00",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 27),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      is3PM = !is3PM;
                    });

                    await _firebaseDB.child(userID).update({"3PM": is3PM});

                    if (is3PM) {
                      CoreUtils.showSnackBar(context,
                          'Your 3PM Timer has been turned ON Successfully. \nThe geyser will run from 3pm to 5pm');
                    } else if (!is3PM) {
                      CoreUtils.showSnackBar(context,
                          'Your 3PM Timer has been turned OFF Successfully');
                    }
                  },
                  child: AnimatedContainer(
                    duration: animationDuration,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: is3PM
                          ? Colours.primaryOrange.withOpacity(.5)
                          : Colours.secondaryColour,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: is3PM
                              ? Colours.primaryOrange.withOpacity(.2)
                              : Colors.grey.shade400.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: is3PM ? 10 : 2,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: animationDuration,
                      alignment:
                          is3PM ? Alignment.centerRight : Alignment.centerLeft,
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        //17h00
        Container(
          width: MediaQuery.of(context).size.width * .93,
          height: MediaQuery.of(context).size.height * .07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white70,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.7),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "17:00",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 27),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      is5PM = !is5PM;
                    });

                    final send =
                        await _firebaseDB.child(userID).update({"5PM": is5PM});

                    if (is5PM) {
                      CoreUtils.showSnackBar(context,
                          'Your 5PM Timer has been turned ON Successfully. \nThe geyser will run from 5pm to 7pm');
                    } else if (!is5PM) {
                      CoreUtils.showSnackBar(context,
                          'Your 5PM Timer has been turned OFF Successfully');
                    }
                  },
                  child: AnimatedContainer(
                    duration: animationDuration,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: is5PM
                          ? Colours.primaryOrange.withOpacity(.5)
                          : Colours.secondaryColour,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: is5PM
                              ? Colours.primaryOrange.withOpacity(.2)
                              : Colors.grey.shade400.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: is5PM ? 10 : 2,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: animationDuration,
                      alignment:
                          is5PM ? Alignment.centerRight : Alignment.centerLeft,
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
      ],
    );
  }
}
