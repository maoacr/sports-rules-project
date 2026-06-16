import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user.
class User extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
