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

  static TextStyle h1Bold() => _style(fontSize: 26, fontWeight: FontWeight.w700, lineHeight: 39);
  static TextStyle h1SemiBold() => _style(fontSize: 26, fontWeight: FontWeight.w600, lineHeight: 39);
  static TextStyle h1Medium() => _style(fontSize: 26, fontWeight: FontWeight.w500, lineHeight: 39);
  static TextStyle h1Regular() => _style(fontSize: 26, fontWeight: FontWeight.w400, lineHeight: 39);

  static TextStyle h2Bold() => _style(fontSize: 24, fontWeight: FontWeight.w700, lineHeight: 36);
  static TextStyle h2SemiBold() => _style(fontSize: 24, fontWeight: FontWeight.w600, lineHeight: 36);
  static TextStyle h2Medium() => _style(fontSize: 24, fontWeight: FontWeight.w400, lineHeight: 36);
  static TextStyle h2Regular() => _style(fontSize: 24, fontWeight: FontWeight.w400, lineHeight: 36);

  static TextStyle h3Bold() => _style(fontSize: 22, fontWeight: FontWeight.w700, lineHeight: 33);
  static TextStyle h3SemiBold() => _style(fontSize: 22, fontWeight: FontWeight.w600, lineHeight: 33);
  static TextStyle h3Medium() => _style(fontSize: 22, fontWeight: FontWeight.w500, lineHeight: 33);
  static TextStyle h3Regular() => _style(fontSize: 22, fontWeight: FontWeight.w400, lineHeight: 33);

  static TextStyle h4Bold() => _style(fontSize: 20, fontWeight: FontWeight.w700, lineHeight: 30);
  static TextStyle h4SemiBold() => _style(fontSize: 20, fontWeight: FontWeight.w600, lineHeight: 30);
  static TextStyle h4Medium() => _style(fontSize: 20, fontWeight: FontWeight.w500, lineHeight: 30);
  static TextStyle h4Regular() => _style(fontSize: 20, fontWeight: FontWeight.w400, lineHeight: 30);

  static TextStyle subtitleBold() => _style(fontSize: 18, fontWeight: FontWeight.w700, lineHeight: 27);
  static TextStyle subtitleSemiBold() => _style(fontSize: 18, fontWeight: FontWeight.w600, lineHeight: 27);
  static TextStyle subtitleMedium() => _style(fontSize: 18, fontWeight: FontWeight.w500, lineHeight: 27);
  static TextStyle subtitleRegular() => _style(fontSize: 18, fontWeight: FontWeight.w400, lineHeight: 27);

  static TextStyle largeTextBold() => _style(fontSize: 16, fontWeight: FontWeight.w700, lineHeight: 24);
  static TextStyle largeTextSemiBold() => _style(fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 24);
  static TextStyle largeTextMedium() => _style(fontSize: 16, fontWeight: FontWeight.w500, lineHeight: 24);
  static TextStyle largeTextRegular() => _style(fontSize: 16, fontWeight: FontWeight.w400, lineHeight: 24);

  static TextStyle mediumTextBold() => _style(fontSize: 14, fontWeight: FontWeight.w700, lineHeight: 21);
  static TextStyle mediumTextSemiBold() => _style(fontSize: 14, fontWeight: FontWeight.w600, lineHeight: 21);
  static TextStyle mediumTextMedium() => _style(fontSize: 14, fontWeight: FontWeight.w500, lineHeight: 21);
  static TextStyle mediumTextRegular() => _style(fontSize: 14, fontWeight: FontWeight.w400, lineHeight: 21);

  static TextStyle smallTextBold() => _style(fontSize: 12, fontWeight: FontWeight.w700, lineHeight: 18);
  static TextStyle smallTextSemiBold() => _style(fontSize: 12, fontWeight: FontWeight.w600, lineHeight: 18);
  static TextStyle smallTextMedium() => _style(fontSize: 12, fontWeight: FontWeight.w500, lineHeight: 18);
  static TextStyle smallTextRegular() => _style(fontSize: 12, fontWeight: FontWeight.w400, lineHeight: 18);

  static TextStyle captionBold() => _style(fontSize: 10, fontWeight: FontWeight.w700, lineHeight: 15);
  static TextStyle captionSemiBold() => _style(fontSize: 10, fontWeight: FontWeight.w600, lineHeight: 15);
  static TextStyle captionMedium() => _style(fontSize: 10, fontWeight: FontWeight.w500, lineHeight: 15);
  static TextStyle captionRegular() => _style(fontSize: 10, fontWeight: FontWeight.w400, lineHeight: 15);

  static TextStyle linkSmall() => _style(fontSize: 10, fontWeight: FontWeight.w500, lineHeight: 15, decoration: TextDecoration.underline);
  static TextStyle linkMedium() => _style(fontSize: 12, fontWeight: FontWeight.w500, lineHeight: 18, decoration: TextDecoration.underline);
  static TextStyle linkBig() => _style(fontSize: 14, fontWeight: FontWeight.w500, lineHeight: 21, decoration: TextDecoration.underline);
}
