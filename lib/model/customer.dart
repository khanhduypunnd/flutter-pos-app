class Customer {
  final String id;
  final String name;
  final DateTime dob;
  final String address;
  final String email;
  final String phone;
  final String pass;

  Customer({
    required this.id,
    required this.name,
    required this.dob,
    required this.address,
    required this.email,
    required this.phone,
    required this.pass,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dob: json['dateOfBirth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateOfBirth']['_seconds'] * 1000)
          : DateTime.now(),
        address: json['address'] ?? '',
        email: json['email'] ?? '',
        phone: json['phoneNumber'] ?? '',
        pass: json['password'] ?? '',
    );
  }
}