import 'package:flutter/material.dart';

class ElevatedContainer extends StatelessWidget {
  const ElevatedContainer(
      { required this.child, this.radius,this.borderWidth, this.padding, this.height, this.width, this.boxConstraints, this.color, this.margin, this.borderColor, this.alignment, this.elevation});

  final Widget child;
  final double? radius;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final Color? color;
  final EdgeInsets? margin;
  final Color? borderColor;
  final double? elevation;
  final double? borderWidth;
  final BoxConstraints? boxConstraints;
  final Alignment? alignment;
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Container(
          height: height,
          width: width,
          alignment: alignment,
          constraints: boxConstraints,
          margin: margin,
          padding: padding ,
          decoration: BoxDecoration(
              color: color ?? Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x29000000),
                    offset: Offset(0, 0),
                    blurRadius:elevation ?? 2.0),
              ],
              border: borderColor == null? null : Border.all(color: borderColor!,width: borderWidth ?? 0.8),
              borderRadius: BorderRadius.circular(radius ?? 0)),
          child: child,
        ));
  }
}
