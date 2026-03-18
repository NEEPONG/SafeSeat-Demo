import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  String _selectedGender = 'ชาย';
  bool _acceptTerms = false;
  bool _isLoading = false;
  final _authRepository = AuthRepository();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _phoneController.text.isEmpty) {
      CherryToast.warning(
        title: const Text('ยังทำไม่เสร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
        description: const Text('กรุณากรอกหมายเลขโทรศัพท์'),
        animationType: AnimationType.fromRight,
      ).show(context);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSignUp() async {
    if (!_acceptTerms) {
      CherryToast.warning(
        title: const Text('ยอมรับเงื่อนไข', style: TextStyle(fontWeight: FontWeight.bold)),
        description: const Text('กรุณายอมรับข้อกำหนดและนโยบาย'),
        animationType: AnimationType.fromRight,
      ).show(context);
      return;
    }

    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      CherryToast.warning(
        title: const Text('ข้อมูลไม่ครบ', style: TextStyle(fontWeight: FontWeight.bold)),
        description: const Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
        animationType: AnimationType.fromRight,
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    // Map gender string to ID
    String genderId = '0'; // default ชาย
    if (_selectedGender == 'หญิง') genderId = '1';
    if (_selectedGender == 'อื่นๆ') genderId = '2';

    try {
      await _authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: genderId, // this is a string "0", "1", "2"
      );

      if (mounted) {
        CherryToast.success(
          title: const Text('สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('สมัครสมาชิกสำเร็จ!'),
          animationType: AnimationType.fromRight,
        ).show(context);
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('สมัครสมาชิกไม่สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(e.message),
          animationType: AnimationType.fromRight,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('เกิดข้อผิดพลาด', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('กรุณาลองใหม่อีกครั้ง'),
          animationType: AnimationType.fromRight,
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgressIndicator(0),
            const SizedBox(width: 8),
            _buildProgressIndicator(1),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [_buildStep1(theme), _buildStep2(theme)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'ขั้นตอนที่ 1 จาก 2', // Step 1 of 2
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'สร้างบัญชีผู้ใช้ใหม่', // Create new account
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'กรุณาป้อนหมายเลขโทรศัพท์มือถือของคุณเพื่อเริ่มต้น เราจะส่งรหัสยืนยันให้คุณเพื่อความปลอดภัย',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withAlpha(180),
            ),
          ),
          const SizedBox(height: 40),
          Text('เบอร์มือถือ', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            hintText: '081-234-5678',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('ดำเนินการต่อ'),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              text: 'เมื่อดำเนินการต่อหมายถึงคุณยอมรับ ',
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(
                  text: 'ข้อกำหนดในการใช้บริการ',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' และ '),
                TextSpan(
                  text: 'นโยบายความเป็นส่วนตัว',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'ขั้นตอนสุดท้าย', // Final step
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ตั้งค่าโปรไฟล์ของคุณ', // Set up your profile
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'กรอกรายละเอียดเพิ่มเติมเล็กน้อยเพื่อเริ่มต้นการเดินทางที่ปลอดภัยกับเรา',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary.withAlpha(180),
            ),
          ),
          const SizedBox(height: 32),
          _buildLabel('ชื่อ-นามสกุล', theme),
          _buildTextField(
            controller: _fullNameController,
            hintText: 'โปรดกรอกชื่อและนามสกุลจริง',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildLabel('เพศ', theme),
          _buildGenderDropdown(theme),
          const SizedBox(height: 20),
          _buildLabel('อีเมล (ถ้ามี)', theme),
          _buildTextField(
            controller: _emailController,
            hintText: 'example@gmail.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          _buildLabel('รหัสผ่าน', theme),
          _buildTextField(
            controller: _passwordController,
            hintText: 'ตั้งรหัสผ่านของคุณ',
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (val) => setState(() => _acceptTerms = val ?? false),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                  child: Text(
                    'ฉันยอมรับข้อกำหนดและนโยบายความเป็นส่วนตัว',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            child: _isLoading
                ? AppLoader.buttonLoader()
                : const Text('เริ่มใช้งานเลย'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }

  Widget _buildGenderDropdown(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: (String? newValue) {
            setState(() => _selectedGender = newValue!);
          },
          items: <String>['ชาย', 'หญิง', 'อื่นๆ'].map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: theme.textTheme.bodyLarge),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
