import '../models/face_model.dart';
import '../models/profile_model.dart';

class User {
  final String? id;
  final String userName;
  final String email;
  final String? password;
  final List<String> roles;
  final ProfileModel? profile;
  final FaceModel? face;
  final bool isFamilyMember;

  User({
    this.id,
    required this.userName,
    required this.email,
    this.password,
    required this.roles,
    this.profile,
    this.face,
    required this.isFamilyMember,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> rolesList = [];
    if (json['roles'] != null) {
      rolesList = List<String>.from(json['roles']);
    }

    return User(
      id: json['id'].toString(),
      userName: json['userName'] ?? 'Unknown',
      email: json['email'] ?? 'No Email',
      password: json['password'],
      roles: rolesList,
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
      face: json['face'] != null ? FaceModel.fromJson(json['face']) : null,
      isFamilyMember: true,
    );
  }
}
