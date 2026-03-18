import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'register_page.dart';
import '../../../home/presentation/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CherryToast.warning(
        title: const Text('กรุณากรอกข้อมูล', style: TextStyle(fontWeight: FontWeight.bold)),
        description: const Text('กรุณากรอกอีเมลและรหัสผ่าน'),
        animationType: AnimationType.fromTop,
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.signIn(email, password);
      if (mounted) {
        CherryToast.success(
          title: const Text('สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('เข้าสู่ระบบสำเร็จ!'),
          animationType: AnimationType.fromTop,
          autoDismiss: true,
        ).show(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('เข้าสู่ระบบไม่สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(e.message),
          animationType: AnimationType.fromTop,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('เกิดข้อผิดพลาด', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('กรุณาตรวจสอบการเชื่อมต่อของคุณ'),
          animationType: AnimationType.fromTop,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo with soft shadow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App Name & Greeting
              Text('SAFE SEAT', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'บริการผู้ขับขี่แทนทั่วไทย', // Welcome back
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 48),
              // Email Input
              _buildTextField(
                controller: _emailController,
                hintText: 'อีเมล',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              // Password Input
              _buildTextField(
                controller: _passwordController,
                hintText: 'รหัสผ่าน',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 12),
              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? AppLoader.buttonLoader()
                    : const Text('เข้าสู่ระบบ'),
              ),
              const SizedBox(height: 40),
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ยังไม่ได้สมัครสมาชิกหรอ? ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text('สมัครที่นี่.'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}
