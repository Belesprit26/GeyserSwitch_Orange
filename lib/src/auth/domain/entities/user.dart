import 'package:equatable/equatable.dart';

class LocalUser extends Equatable {
  const LocalUser({
    required this.uid,
    required this.email,
    required this.points,
    required this.fullName,
    required this.temperature,
    this.groupIds = const [],
    this.enrolledCourseIds = const [],
    this.profilePic,
    this.bio,
  });

  const LocalUser.empty()
      : this(
          uid: '',
          email: '',
          points: 0,
          fullName: '',
          profilePic: '',
          bio: '',
          groupIds: const [],
          enrolledCourseIds: const [],
          temperature: 0.0,
        );

  final String uid;
  final String email;
  final String? profilePic;
  final String? bio;
  final int points;
  final String fullName;
  final List<String> groupIds;
  final List<String> enrolledCourseIds;
  final double temperature;

  @override
  List<Object?> get props => [
        uid,
        email,
        profilePic,
        bio,
        points,
        fullName,
        groupIds.length,
        enrolledCourseIds.length,
        temperature,
      ];

  @override
  String toString() {
    return 'LocalUser{uid: $uid, email: $email, bio: '
        '$bio, points: $points, fullName: $fullName}';
  }
}
