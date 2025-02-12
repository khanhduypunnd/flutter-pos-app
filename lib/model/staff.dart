class Staff {
  final String sid;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;
  final List<int> roleDetail;

  Staff({
    required this.sid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
    required this.roleDetail,
  });

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
      'role_detail': roleDetail,
    };
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      sid: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      roleDetail: json['role_detail'] != null
          ? List<int>.from(json['role_detail'])
          : List.filled(12, 1),
    );
  }
}
