import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Poppins';

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double lineHeight,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: lineHeight / fontSize,
      decoration: decoration,
      letterSpacing: 0,
    );
  }

  static TextStyle get h1Bold => _style(fontSize: 26, fontWeight: FontWeight.w700, lineHeight: 39);
  static TextStyle get h1SemiBold => _style(fontSize: 26, fontWeight: FontWeight.w600, lineHeight: 39);
  static TextStyle get h1Medium => _style(fontSize: 26, fontWeight: FontWeight.w500, lineHeight: 39);
  static TextStyle get h1Regular => _style(fontSize: 26, fontWeight: FontWeight.w400, lineHeight: 39);

  static TextStyle get h2Bold => _style(fontSize: 24, fontWeight: FontWeight.w700, lineHeight: 36);
  static TextStyle get h2SemiBold => _style(fontSize: 24, fontWeight: FontWeight.w600, lineHeight: 36);
  static TextStyle get h2Medium => _style(fontSize: 24, fontWeight: FontWeight.w500, lineHeight: 36);
  static TextStyle get h2Regular => _style(fontSize: 24, fontWeight: FontWeight.w400, lineHeight: 36);

  static TextStyle get h3Bold => _style(fontSize: 22, fontWeight: FontWeight.w700, lineHeight: 33);
  static TextStyle get h3SemiBold => _style(fontSize: 22, fontWeight: FontWeight.w600, lineHeight: 33);
  static TextStyle get h3Medium => _style(fontSize: 22, fontWeight: FontWeight.w500, lineHeight: 33);
  static TextStyle get h3Regular => _style(fontSize: 22, fontWeight: FontWeight.w400, lineHeight: 33);

  static TextStyle get h4Bold => _style(fontSize: 20, fontWeight: FontWeight.w700, lineHeight: 30);
  static TextStyle get h4SemiBold => _style(fontSize: 20, fontWeight: FontWeight.w600, lineHeight: 30);
  static TextStyle get h4Medium => _style(fontSize: 20, fontWeight: FontWeight.w500, lineHeight: 30);
  static TextStyle get h4Regular => _style(fontSize: 20, fontWeight: FontWeight.w400, lineHeight: 30);

  static TextStyle get subtitleBold => _style(fontSize: 18, fontWeight: FontWeight.w700, lineHeight: 27);
  static TextStyle get subtitleSemiBold => _style(fontSize: 18, fontWeight: FontWeight.w600, lineHeight: 27);
  static TextStyle get subtitleMedium => _style(fontSize: 18, fontWeight: FontWeight.w500, lineHeight: 27);
  static TextStyle get subtitleRegular => _style(fontSize: 18, fontWeight: FontWeight.w400, lineHeight: 27);

  static TextStyle get largeTextBold => _style(fontSize: 16, fontWeight: FontWeight.w700, lineHeight: 24);
  static TextStyle get largeTextSemiBold => _style(fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 24);
  static TextStyle get largeTextMedium => _style(fontSize: 16, fontWeight: FontWeight.w500, lineHeight: 24);
  static TextStyle get largeTextRegular => _style(fontSize: 16, fontWeight: FontWeight.w400, lineHeight: 24);

  static TextStyle get mediumTextBold => _style(fontSize: 14, fontWeight: FontWeight.w700, lineHeight: 21);
  static TextStyle get mediumTextSemiBold => _style(fontSize: 14, fontWeight: FontWeight.w600, lineHeight: 21);
  static TextStyle get mediumTextMedium => _style(fontSize: 14, fontWeight: FontWeight.w500, lineHeight: 21);
  static TextStyle get mediumTextRegular => _style(fontSize: 14, fontWeight: FontWeight.w400, lineHeight: 21);

  static TextStyle get smallTextBold => _style(fontSize: 12, fontWeight: FontWeight.w700, lineHeight: 18);
  static TextStyle get smallTextSemiBold => _style(fontSize: 12, fontWeight: FontWeight.w600, lineHeight: 18);
  static TextStyle get smallTextMedium => _style(fontSize: 12, fontWeight: FontWeight.w500, lineHeight: 18);
  static TextStyle get smallTextRegular => _style(fontSize: 12, fontWeight: FontWeight.w400, lineHeight: 18);

  static TextStyle get captionBold => _style(fontSize: 10, fontWeight: FontWeight.w700, lineHeight: 15);
  static TextStyle get captionSemiBold => _style(fontSize: 10, fontWeight: FontWeight.w600, lineHeight: 15);
  static TextStyle get captionMedium => _style(fontSize: 10, fontWeight: FontWeight.w500, lineHeight: 15);
  static TextStyle get captionRegular => _style(fontSize: 10, fontWeight: FontWeight.w400, lineHeight: 15);

  static TextStyle get linkSmall => _style(fontSize: 10, fontWeight: FontWeight.w500, lineHeight: 15, decoration: TextDecoration.underline);
  static TextStyle get linkMedium => _style(fontSize: 12, fontWeight: FontWeight.w500, lineHeight: 18, decoration: TextDecoration.underline);
  static TextStyle get linkBig => _style(fontSize: 14, fontWeight: FontWeight.w500, lineHeight: 21, decoration: TextDecoration.underline);
}
