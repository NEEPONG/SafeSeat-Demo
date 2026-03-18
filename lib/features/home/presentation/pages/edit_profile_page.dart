import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/home_repository.dart';
import '../../domain/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import '../../domain/vehicle_model.dart';
import 'add_vehicle_page.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late String _selectedGender;
  bool _isLoading = false;
  final _profileRepository = ProfileRepository();
  late Future<List<Vehicle>> _vehicleFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _addressController = TextEditingController(text: widget.profile.mainAddress);
    _selectedGender = widget.profile.gender == 1 ? 'หญิง' : (widget.profile.gender == 2 ? 'อื่นๆ' : 'ชาย');
    _fetchVehicles();
  }

  void _fetchVehicles() {
     _vehicleFuture = _profileRepository.getVehicles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    
    int genderId = 0;
    if (_selectedGender == 'หญิง') genderId = 1;
    if (_selectedGender == 'อื่นๆ') genderId = 2;

    try {
      await _profileRepository.updateUserProfile(
        name: _nameController.text.trim(),
        phoneNo: _phoneController.text.trim(),
        gender: genderId,
        mainAddress: _addressController.text.trim(),
      );

      if (mounted) {
        CherryToast.success(
          title: const Text('สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('บันทึกข้อมูลสำเร็จ'),
          animationType: AnimationType.fromTop,
        ).show(context);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('เกิดข้อผิดพลาด', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(e.toString()),
          animationType: AnimationType.fromTop,
        ).show(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImagePicker(),
            const SizedBox(height: 32),
            _buildFieldLabel('ชื่อ-นามสกุล'),
            _buildTextField(
              controller: _nameController,
              hintText: 'นายวุฒิชัย ดวงยี่หวา',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('เบอร์มือถือ'),
            _buildTextField(
              controller: _phoneController,
              hintText: '0873944046',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('อีเมล'),
            _buildTextField(
              controller: TextEditingController(text: email),
              hintText: '',
              icon: Icons.email_outlined,
              enabled: false, // Email and PK normally shouldn't be edited here
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('เพศ'),
            _buildGenderDropdown(),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _addressController,
              hintText: 'ระบุที่อยู่ปัจจุบันของคุณ',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 32),
            _buildVehicleSection(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'บันทึกการแก้ไข',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: widget.profile.profileImage != null
                    ? NetworkImage(widget.profile.profileImage!)
                    : const NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=256&auto=format&fit=crop'),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF6200EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'แตะเพื่อเปลี่ยนรูปโปรไฟล์',
            style: TextStyle(
              color: Color(0xFF6200EE),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: enabled ? AppColors.textPrimary : Colors.grey[500],
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400]),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => _selectedGender = newValue);
          },
          items: <String>['ชาย', 'หญิง', 'อื่นๆ'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    value == 'ชาย' ? Icons.male_rounded : (value == 'หญิง' ? Icons.female_rounded : Icons.people_rounded),
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('ยานพาหนะของฉัน'),
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddVehiclePage()),
                );
                if (result == true) {
                  setState(() {
                    _fetchVehicles();
                  });
                }
              },
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Add Car', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF2D2D2D), // Dark style as mockup
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Vehicle>>(
          future: _vehicleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withAlpha(20)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.directions_car_filled_outlined, color: Colors.grey[300], size: 48),
                    const SizedBox(height: 12),
                    Text('ยังไม่มีข้อมูลยานพาหนะ', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final car = snapshot.data![index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9), // Gray/Silver as mockup
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(150),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car_rounded, color: Color(0xFF2D2D2D), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.carBrand} ${car.carModel}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'สี${car.carColor} • ${car.carPlate}',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF2D2D2D).withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_horiz_rounded, color: Color(0xFF2D2D2D)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
