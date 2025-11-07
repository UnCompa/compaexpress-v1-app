class UserInfo {
  final String userId;
  final String username;
  final String? email;
  final List<String> groups;
  final String negocioId;

  UserInfo({
    required this.userId,
    required this.username,
    this.email,
    required this.groups,
    required this.negocioId,
  });

  @override
  String toString() {
    return 'UserInfo(userId: $userId, username: $username, email: $email, groups: $groups)';
  }

  /// Verifica si el usuario pertenece a un grupo específico
  bool hasGroup(String group) {
    return groups.contains(group);
  }

  /// Verifica si el usuario es superadmin
  bool get isSuperAdmin => hasGroup('superadmin');

  /// Verifica si el usuario es admin
  bool get isAdmin => hasGroup('admin');

  /// Verifica si el usuario es vendedor
  bool get isVendedor => hasGroup('vendedor');
}
