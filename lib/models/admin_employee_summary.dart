/// Row from POST /webhook/admin/employees `employees` array.
class AdminEmployeeSummary {
  const AdminEmployeeSummary({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.address,
    required this.contactNumber,
    required this.birthdate,
    required this.profileImageUrl,
  });

  final String userId;
  final String fullName;
  final String email;
  final String address;
  final String contactNumber;
  final String birthdate;
  final String profileImageUrl;

  factory AdminEmployeeSummary.fromJson(Map<String, dynamic> json) {
    return AdminEmployeeSummary(
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      contactNumber: (json['contactNumber'] ?? '').toString(),
      birthdate: (json['birthdate'] ?? '').toString(),
      profileImageUrl: (json['profileImageUrl'] ?? '').toString(),
    );
  }
}
