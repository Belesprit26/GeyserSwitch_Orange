import 'package:equatable/equatable.dart';

class LocalUserEntity extends Equatable {
  const LocalUserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.temperature,
    this.profilePic,
    this.bio,
  });

  const LocalUserEntity.empty()
      : this(
          uid: '',
          email: '',
          fullName: '',
          profilePic: '',
          bio: '',
          temperature: 0.0,
        );

  final String uid;
  final String email;
  final String? profilePic;
  final String? bio;
  final String fullName;
  final double temperature;

  @override
  List<Object?> get props => [
        uid,
        email,
        profilePic,
        bio,
        fullName,
        temperature,
      ];

  @override
  String toString() {
    return 'LocalUser{uid: $uid, email: $email, bio: '
        '$bio, fullName: $fullName}';
  }
}
