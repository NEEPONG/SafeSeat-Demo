import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/home_repository.dart';
import '../../domain/vehicle_model.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  
  String? _selectedColor;
  int _selectedGearTypeId = 1; // Default to Automatic (1)
  bool _isLoading = false;

  final List<String> _colors = [
    'ขาว', 'ดำ', 'เทา', 'เงิน', 'แดง', 'น้ำเงิน', 'เขียว', 'เหลือง', 'ส้ม', 'น้ำตาล'
  ];

  final ProfileRepository _repository = ProfileRepository();

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedColor == null) {
      CherryToast.warning(
        title: const Text('กรุณาเลือกสี', style: TextStyle(fontWeight: FontWeight.bold)),
        description: const Text('กรุณาระบุสีของรถของคุณ'),
        animationType: AnimationType.fromTop,
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.addVehicle({
        'carBrand': _brandController.text.trim(),
        'carModel': _modelController.text.trim(),
        'carPlate': _plateController.text.trim(),
        'carColor': _selectedColor,
        'carTypeId': _selectedGearTypeId,
      });

      if (mounted) {
        CherryToast.success(
          title: const Text('สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('เพิ่มข้อมูลยานพาหนะเรียบร้อยแล้ว'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'เพิ่มข้อมูลยานพาหนะ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withAlpha(30), height: 1),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.directions_car_rounded, 'ข้อมูลยานพาหนะ'),
                  const SizedBox(height: 16),
                  _buildLabel('ยี่ห้อรถ'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _brandController,
                    hint: 'ระบุยี่ห้อรถ (เช่น Toyota, Honda)',
                    icon: Icons.factory_outlined,
                    validator: (v) => v!.isEmpty ? 'กรุณากรอกยี่ห้อรถ' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('รุ่นรถ'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _modelController,
                    hint: 'ระบุรุ่นรถ (เช่น Camry, Civic)',
                    icon: Icons.directions_car_outlined,
                    validator: (v) => v!.isEmpty ? 'กรุณากรอกรุ่นรถ' : null,
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(Icons.pin_outlined, 'ข้อมูลทะเบียนรถ'),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ทะเบียนรถ'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _plateController,
                              hint: 'กข 1234',
                              validator: (v) => v!.isEmpty ? 'กรุณากรอกทะเบียน' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('สี'),
                            const SizedBox(height: 8),
                            _buildColorDropdown(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(Icons.settings_input_component_rounded, 'สเปคเกียร์'),
                  const SizedBox(height: 16),
                  _buildLabel('ประเภทเกียร์'),
                  const SizedBox(height: 12),
                  _buildGearTypeSelection(),

                  const SizedBox(height: 48),
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        suffixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
        filled: true,
        fillColor: Colors.grey.withAlpha(10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildColorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedColor,
          hint: Text('เลือกสี', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          isExpanded: true,
          items: _colors.map((color) {
            return DropdownMenuItem(
              value: color,
              child: Text(color, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedColor = val),
        ),
      ),
    );
  }

  Widget _buildGearTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildGearOption(1, 'Automatic', Icons.sync_rounded),
          _buildGearOption(2, 'Manual', Icons.settings_rounded),
          _buildGearOption(3, 'Electric', Icons.bolt_rounded),
        ],
      ),
    );
  }

  Widget _buildGearOption(int id, String label, IconData icon) {
    bool isSelected = _selectedGearTypeId == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGearTypeId = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withAlpha(60),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _handleSave,
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text(
          'บันทึกยานพาหนะใหม่',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: AppColors.primary.withAlpha(100),
        ),
      ),
    );
  }
}
