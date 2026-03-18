import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_profile_model.dart';
import '../domain/vehicle_model.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<UserProfile?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print("DEBUG: No current user session found!");
      return null;
    }
    print(
      "DEBUG: Fetching profile for ID: ${user.id}",
    ); // ตรวจสอบ ID นี้ในตาราง profiles

    // ลอง query แบบไม่ใช้ .single() ก่อนเพื่อดูว่ามันพ่นอะไรออกมา
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    print("DEBUG: Response data: $response");

    if (response.isEmpty) return null;
    return UserProfile.fromMap(response);
  }

  Future<void> updateUserProfile({
    required String name,
    required String phoneNo,
    required int gender,
    required String mainAddress,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('profiles').update({
      'name': name,
      'phone_no': phoneNo,
      'gender': gender,
      'main_address': mainAddress,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  Future<List<Vehicle>> getVehicles() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('usercar')
        .select()
        .eq('userId', user.id); // Fixed: using userId as shown in schema

    return (response as List).map((json) => Vehicle.fromJson(json)).toList();
  }

  Future<List<VehicleType>> getVehicleTypes() async {
    final response = await _supabase.from('cartype').select();
    return (response as List).map((json) => VehicleType.fromJson(json)).toList();
  }

  Future<void> addVehicle(Map<String, dynamic> vehicleData) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Add user ID to vehicle data using the correct column name 'userId'
    vehicleData['userId'] = user.id;

    await _supabase.from('usercar').insert(vehicleData);
  }
}
