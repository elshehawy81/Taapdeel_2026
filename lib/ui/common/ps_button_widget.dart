import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';

class PSButtonWidget extends StatelessWidget {
  const PSButtonWidget({
    Key? key,
    this.onPressed,
    this.titleText = '',
    this.titleTextAlign = TextAlign.center,
    this.colorData,
    this.textColor,
    this.width,
    this.gradient,
    this.hasShadow = false,
    this.withBorder = false,
  }) : super(key: key);

  final Function? onPressed;
  final String titleText;
  final Color? colorData;
  final Color? textColor;
  final double? width;
  final Gradient? gradient;
  final bool hasShadow;
  final TextAlign titleTextAlign;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = colorData == null && !withBorder;
    final bool outlined = withBorder;

    return TaapdeelButton(
      label: titleText,
      onPressed: onPressed as void Function()?,
      isPrimary: isPrimary,
      isExpanded: true,
      outlined: outlined,
      width: width ?? MediaQuery.of(context).size.width,
      backgroundColorOverride: colorData,
      foregroundColorOverride: textColor ?? PsColors.textColor4,
      textAlign: titleTextAlign,
    );
  }
}

class PSButtonWithIconWidget extends StatelessWidget {
  const PSButtonWithIconWidget({
    Key? key,
    this.onPressed,
    this.titleText = '',
    this.colorData,
    this.width,
    this.gradient,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
    this.hasShadow = false,
    this.iconColor,
  }) : super(key: key);

  final Function? onPressed;
  final String titleText;
  final Color? colorData;
  final double? width;
  final IconData? icon;
  final Gradient? gradient;
  final MainAxisAlignment iconAlignment;
  final bool hasShadow;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = colorData == null;
    final Color? fgOverride = PsColors.textColor4;

    final Widget? iconWidget = icon != null
        ? Icon(
      icon,
      color: iconColor ?? PsColors.white,
    )
        : null;

    final bool isExpanded = width == null;

    return Align(
      alignment: Alignment.center,
      child: TaapdeelButton(
        label: titleText,
        onPressed: onPressed as void Function()?,
        isPrimary: isPrimary,
        isExpanded: isExpanded,
        width: width,
        outlined: false,
        backgroundColorOverride: colorData,
        foregroundColorOverride: fgOverride,
        icon: iconWidget,
        textAlign: TextAlign.center,
      ),
    );
  }
}
