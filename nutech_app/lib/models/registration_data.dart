/// Data collected during signup, passed from Signup → Password → Verify OTP.
class RegistrationData {
  const RegistrationData({
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.birthdate,
  });

  final String fullName;
  final String email;
  final String contactNumber;
  final String address;
  final String birthdate;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'contactNumber': contactNumber,
        'address': address,
        'birthdate': birthdate,
      };
}
