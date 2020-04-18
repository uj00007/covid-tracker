class ScreenRatio {
  static double heightRatio;
  static double widthRatio;
  static double screenheight;
  static double screenwidth;

  static setScreenRatio(
      {double currentScreenHeight, double currentScreenWidth}) {
    screenheight = currentScreenHeight;
    screenwidth = currentScreenWidth;
    heightRatio = currentScreenHeight / 640.0;
    widthRatio = currentScreenWidth / 360.0;
  }
}
