import 'package:flutter/material.dart';

class CommonColors {
  static const Color backgroundColor = Color.fromRGBO(33, 42, 61, 1);
  static final Color greyff = Color(0xff141414);
  static final Color flow = Color(0xffbab9c7);
  static final Color titleColor = Color(0xff4d5567);
  static final Color subtitleColor = Color(0x994d5567);
  static const Color primaryColor = Color(0xFFff5f65);
  static const Color secondaryColor = Color.fromRGBO(255, 81, 88, 1);
  static const Color disabledColor = Color(0xFF6e7584);
  static const Color purple = Color(0xff1D253C);
  static const Color pink = Color(0xffED4E56);
  static const Color white = Colors.white;
  static const Color blueGrey = Color(0xFF46517c);
  static const Color cardBackground = Color(0xFF424b61);
  static const Color disabledIconColor = Color(0x66eeeeee);
  static const Color basePageGradient1 = Color(0xff404e72);
  static const Color basePageGradient2 = Color(0xff212a3d);
  static const Color filledColor = Color.fromRGBO(59, 68, 88, 1);
  static const Color slateColor = Color.fromRGBO(66, 75, 97, 1);
  static const Color blueHyperLink = Color(0xff209be1);
  static const Color cursorColor = Color(0xfffc4452);
  static const Color watermelon = Color(0xffff5158);
  static const Color orangeError = Color(0xffff7b46);
  static const Color moderateCyan = Color(0xff44d7b6);
  static const Color grey = Color(0x88ffffff);
  static const Color greyBlack = Color(0x33ffffff);
  static const Color grey60 = Color(0x88141414);
  static final Color grey99 = Color(0x99141414);
  static final Color grey19 = Color(0x19141414);
  static final Color grey66 = Color(0x66141414);
  static final Color watermelonPink = Color(0xffff5f65);
  static final Color black1text = Color(0xff141414);
  static final Color offwhite = Color(0xffeeeeee);
  static final Color offPurple = Color(0xff242c42);
  static final Color tilePurple = Color(0xff383f52);
  static final Color dullGrey = Color(0xff424c64);
  static final Color green = Colors.green;
  static final Color black = Color(0xff000000);
  static final Color whiteText = Color(0xfff3f3f3);
  static final Color baseblack = Color(0xFF292F3F);
  static final Color baseblack2 = Color(0xff3C4049);
  static final Color slateBase = Color(0xFF424b61);
  static final Color slateBase2 = Color(0xFF4c5771);
  static final Color slateBaseDark = Color(0xff1A1D25);
  static final Color bluelink = Color(0xff131df5);
  static final Color grey7a = Color(0xff7a7a7a);
  static const Color paleRed = Color(0xffff4c5a);
  static const Color darkRed = Color(0xffa50000);
  static final Color fadedLightGrey = Color(0x77d8d8d8);
  static final Color grey97 = Color(0xff979797);
  static final Color darkGreyBlue = Color(0xff697084);
  static final Color veryLightGrey = Color(0xfff1f1f1);
  static final Color fadedVeryLightGrey = Color(0xbbf1f1f1);
  static final Color greyd0 = Color(0xffd0d0d0);
  static final Color greyc0 = Color(0xffc0c0c0);
  static final Color greyb0 = Color(0xffb0b0b0);
  static final Color desaturatedBlue = Color(0xff252c3d);
  static final Color softRed = Color(0xfffe4e56);
  static final Color grey68 = Color(0xff686868);
}

class HexColor extends Color {
  static int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(getColorFromHex(hexColor));
}
