import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

renderAssetSvg(String image, {height, width, fit = BoxFit.contain}) {
  return image.isNotEmpty
      ? SvgPicture.asset(
          image,
          width: width.toDouble(),
          height: height.toDouble(),
          fit: fit,
          semanticsLabel: 'A shark?!',
        )
      : SizedBox(height: height.toDouble(), width: width.toDouble());
}
