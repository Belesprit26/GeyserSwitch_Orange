import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/auth/domain/entities/user_entity.dart';

class LocalUserModel extends LocalUserEntity {
  const LocalUserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    required super.temperature,
    super.profilePic,
    super.bio,
  });

  const LocalUserModel.empty()
      : this(
          uid: '',
          email: '',
          fullName: '',
          temperature: 0.0,
        );

  LocalUserModel.fromMap(DataMap map)
      : super(
          uid: map['uid'] as String,
          email: map['email'] as String,
          fullName: map['fullName'] as String,
          profilePic: map['profilePic'] as String?,
          bio: map['bio'] as String?,
          temperature: (map['temperature'] as num).toDouble(),
        );

  LocalUserModel copyWith({
    String? uid,
    String? email,
    String? profilePic,
    String? bio,
    String? fullName,
    double? temperature,
  }) {
    return LocalUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      fullName: fullName ?? this.fullName,
      temperature: temperature ?? this.temperature,
    );
  }

  DataMap toMap() {
    return {
      'uid': uid,
      'email': email,
      'profilePic': profilePic,
      'bio': bio,
      'fullName': fullName,
      'temperature': temperature,
    };
  }
}
