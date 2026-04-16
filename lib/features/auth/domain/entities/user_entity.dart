class UserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
  });
}