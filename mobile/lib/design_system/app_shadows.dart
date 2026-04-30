import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static BoxShadow cardShadow() {
    return const BoxShadow(
      color: Color(0x121D1617),
      blurRadius: 40,
      offset: Offset(0, 10),
      spreadRadius: 0,
    );
  }

  static BoxShadow blueShadow() {
    return const BoxShadow(
      color: Color(0x4D95ADFE),
      blurRadius: 22,
      offset: Offset(0, 10),
      spreadRadius: 0,
    );
  }

  static BoxShadow purpleShadow() {
    return const BoxShadow(
      color: Color(0x4DC58BF2),
      blurRadius: 22,
      offset: Offset(0, 10),
      spreadRadius: 0,
    );
  }

  static List<BoxShadow> get card => [cardShadow()];
  static List<BoxShadow> get blue => [blueShadow()];
  static List<BoxShadow> get purple => [purpleShadow()];
}
