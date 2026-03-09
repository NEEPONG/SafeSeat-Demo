import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_profile_model.dart';

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
        .eq('id', user.id);
    print("DEBUG: Response data: $response");

    if (response.isEmpty) return null;
    return UserProfile.fromMap(response.first);
  }

  /// สตรีมข้อมูลเพื่อให้อัปเดตเงินในกระเป๋าตลอดเวลา
  Stream<Map<String, dynamic>> profileStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((list) => list.isNotEmpty ? list.first : {});
  }
}
