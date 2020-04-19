import 'dart:ui';

import 'package:covid_tracker/colors/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  //final ButtonWidgetBloc mBloc;
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

  CustomButton({
    //  this.mBloc,
    @required this.onPressed,
    @required this.label,
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
    this.textWeight = FontWeight.w500,
  });

  @override
  CustomButtonState createState() {
    return new CustomButtonState();
  }
}

class CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (!widget.multiTap)
          ? widget.disabled
              ? () {}
              : () async {
                  await widget.onPressed();
                  setState(() {
                    widget.disabled = true;
                  });
                }
          : () async {
              await widget.onPressed();
            },
      child: new Container(
        width: widget.width ?? MediaQuery.of(context).size.width,
        height: widget.height,
        decoration: new BoxDecoration(
          color: widget.disabled ? widget.disableColor : widget.color,
          border: new Border.all(
            color: widget.disabled
                ? widget.disableBorderColor
                : widget.borderColor,
            width: 1.0,
          ),
          borderRadius: new BorderRadius.circular(widget.bottonRadius),
          boxShadow: widget.shadow
              ? [
                  BoxShadow(
                      color: Colors.grey[200], blurRadius: 4.0, spreadRadius: 2)
                ]
              : [],
        ),
        child: new Center(
          child: widget.showLoader
              ? Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
              : Text(
                  widget.label,
                  style: widget.style == null
                      ? new TextStyle(
                          fontSize: widget.textFontSize,
                          color: widget.disabled
                              ? widget.disableBorderColor
                              : Colors.white,
                          fontWeight: widget.textWeight,
                        )
                      : widget.style,
                ),
        ),
      ),
    );
  }
}
