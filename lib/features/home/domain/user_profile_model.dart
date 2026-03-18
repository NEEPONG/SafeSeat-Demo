class UserProfile {
  final String id;
  final String fullName;
  final String? phone;
  final int? gender;
  final String? mainAddress;
  final double balance;
  final String? profileImage;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    this.phone,
    this.gender,
    this.mainAddress,
    this.balance = 0.0,
    this.profileImage,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['name'] as String? ?? 'User',
      phone: map['phone_no'] as String?,
      gender: map['gender'] as int?,
      mainAddress: map['main_address'] as String?,
      balance: (map['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      profileImage: map['profile_image_path'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }
}
