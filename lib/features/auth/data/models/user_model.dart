import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Data model for User with JSON serialization.
class UserModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Creates a UserModel from a JSON map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  /// Creates a UserModel from a User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  /// Creates a UserModel from Firebase User.
  factory UserModel.fromFirebase(dynamic fbUser) {
    return UserModel(
      uid: fbUser.uid,
      email: fbUser.email,
      displayName: fbUser.displayName,
      photoUrl: fbUser.photoURL,
    );
  }

  /// Converts this UserModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Converts this UserModel to a User entity.
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
