import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 30.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce(color: color ?? Colors.white, size: size),
    );
  }

  /// สำหรับใช้เต็มหน้าจอ หรือตอนโหลดข้อมูล
  static Widget loadingScreen({Color? color}) {
    return Center(
      child: SpinKitFadingCircle(color: color ?? AppColors.primary, size: 50.0),
    );
  }

  /// สำหรับใช้ในปุ่ม (Button Loading)
  static Widget buttonLoader({double size = 20.0, Color color = Colors.white}) {
    return SpinKitThreeBounce(color: color, size: size);
  }
}
