class UserProfile {
  final String id;
  final String fullName;
  final String? phone;
  final double balance;
  final String? profileImage;

  UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    this.balance = 0.0,
    this.profileImage,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['name'] as String? ?? 'User',
      phone: map['phone_no'] as String?,
      balance: (map['wallet_balanc'] as num?)?.toDouble() ?? 0.0,
      profileImage: map['profile_image'] as String?,
    );
  }
}
