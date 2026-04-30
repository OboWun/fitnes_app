import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color gray1 = Color(0xFF7B6F72);
  static const Color gray2 = Color(0xFFADA4A5);
  static const Color gray3 = Color(0xFFDDDADA);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF1D1617);
  static const Color borderColor = Color(0xFFF7F8F8);
  static const Color success = Color(0xFF42D742);
  static const Color warning = Color(0xFFFFD600);
  static const Color danger = Color(0xFFFF0000);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient blueLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF92A3FD), Color(0xFF9DCEFF)],
  );

  static const LinearGradient purpleLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC58BF2), Color(0xFFEEA4CE)],
  );

  static const LinearGradient caloriesLinear = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC58BF2), Color(0xFFB4C0FE)],
  );

  static const LinearGradient progressBarLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC58BF2), Color(0xFF92A3FD)],
  );

  static const LinearGradient waterIntakeLinear = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC58BF2), Color(0xFFB4C0FE)],
  );

  static const LinearGradient logoLinear = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCC8FED), Color(0xFF9DCEFF)],
  );
}
