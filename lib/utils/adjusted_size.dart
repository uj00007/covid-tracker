import 'package:covid_tracker/utils/screen_ratio.dart';

double getAdjustedSizeHeight(double size) => size * ScreenRatio.heightRatio;
double getAdjustedSizeWidth(double size) => size * ScreenRatio.widthRatio;
