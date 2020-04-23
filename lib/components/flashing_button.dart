import 'dart:async';

import 'package:covid_tracker/colors/colors.dart';
import 'package:covid_tracker/components/custom_button.dart';
import 'package:flutter/material.dart';

class FlashingButton extends CustomButton {
  final String label;
  final TextStyle style;
  final double width;
  final double height;
  final Function onPressed;
  final Color color;
  final bool multiTap;
  final Color disableColor;
  final bool showLoader;
  final Color disableBorderColor;
  final Color borderColor;
  bool disabled;
  final bool shadow;
  final double bottonRadius;
  final double textFontSize;
  final FontWeight textWeight;

  FlashingButton(
      {this.label,
      this.onPressed,
      this.width = 300,
      this.height = 60,
      this.style,
      this.showLoader = false,
      this.color = CommonColors.primaryColor,
      this.borderColor = Colors.transparent,
      this.disableColor = Colors.transparent,
      this.disableBorderColor = Colors.grey,
      this.disabled = false,
      this.shadow = false,
      this.multiTap = false,
      this.bottonRadius = 200.0,
      this.textFontSize = 16.0,
      this.textWeight = FontWeight.w500})
      : super(
          onPressed: () => onPressed,
          label: label,
          height: height,
          multiTap: multiTap,
          disabled: disabled,
          width: width,
          color: color,
          style: style,
        );
  @override
  _FlashingButtonState createState() => _FlashingButtonState();
}

class _FlashingButtonState extends CustomButtonState {
  bool _showLight;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _showLight = true;
    _timer = new Timer.periodic(
        const Duration(seconds: 2),
        (time) => this.setState(() {
              this._showLight = !this._showLight;
            }));
  }

  @override
  void dispose() {
    print('dispose timer');
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(child: super.build(context)),
        _showLight
            ? Container(
                height: 12,
                width: 12,
                decoration: new BoxDecoration(
                  color: Colors.red,
                  border: new Border.all(
                    color: widget.disabled
                        ? widget.disableBorderColor
                        : widget.borderColor,
                    width: 1.0,
                  ),
                  borderRadius: new BorderRadius.circular(20),
                ))
            : SizedBox(),
      ],
    );
  }
}
