import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/utils/utils.dart';

class PsTextFieldWidget extends StatelessWidget {
  const PsTextFieldWidget({
    Key? key,
    this.textEditingController,
    this.titleText = '',
    this.hintText,
    this.helperText,
    this.errorText,
    this.textAboutMe = false,
    this.height = PsDimens.space44,
    this.showTitle = true,
    this.keyboardType = TextInputType.text,
    this.isStar = false,
    this.isEnable = true,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  final TextEditingController? textEditingController;

  /// Title shown above the field (or used as label when showTitle = false).
  final String titleText;

  /// Placeholder / hint inside the field.
  final String? hintText;

  /// Optional helper text below the field.
  final String? helperText;

  /// Optional error text to display in error state.
  final String? errorText;

  /// Kept for backward compatibility. Actual height is driven by text content.
  final double height;

  /// When true, the field becomes multi-line for "About me" style text.
  final bool textAboutMe;

  final TextInputType keyboardType;

  /// When false, the title is hidden and titleText is used as the field label.
  final bool showTitle;

  /// Shows a required star (*) next to the title.
  final bool isStar;

  /// Enables / disables field interaction.
  final bool isEnable;

  /// Obscures the text (for passwords).
  final bool obscureText;

  /// Icon shown at the start of the field.
  final IconData? prefixIcon;

  /// Widget shown at the end of the field (icon, button, etc.).
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLight = Utils.isLightMode(context);

    final TextStyle? titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: isLight
          ? PsColors.textPrimaryLightColor
          : PsColors.textPrimaryDarkColor,
    );

    final TextStyle requiredStarStyle =
    (titleStyle ?? const TextStyle()).copyWith(
      color: PsColors.activeColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PsDimens.space16,
        vertical: PsDimens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showTitle && titleText.isNotEmpty) ...<Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  titleText,
                  style: titleStyle,
                ),
                if (isStar)
                  Text(
                    ' *',
                    style: requiredStarStyle,
                  ),
              ],
            ),
            const SizedBox(height: PsDimens.space8),
          ],
          Opacity(
            opacity: isEnable ? 1.0 : 0.6,
            child: TaapdeelTextField(
              controller: textEditingController,
              label: showTitle ? null : titleText,
              hint: hintText,
              keyboardType: keyboardType,
              enabled: isEnable,
              maxLines: textAboutMe ? 5 : 1,
              minLines: textAboutMe ? 3 : 1,
              helperText: helperText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              obscureText: obscureText,
              errorText: errorText,
            ),
          ),
        ],
      ),
    );
  }
}
