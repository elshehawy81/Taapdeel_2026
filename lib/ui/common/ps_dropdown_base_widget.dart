import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/utils/utils.dart';

class PsDropdownBaseWidget extends StatelessWidget {
  const PsDropdownBaseWidget({
    Key? key,
    required this.title,
    required this.onTap,
    this.selectedText,
  }) : super(key: key);

  /// العنوان اللي فوق الـ dropdown
  final String title;

  /// النص المختار حاليًا
  final String? selectedText;

  /// الكول باك لما المستخدم يضغط على الـ dropdown
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final bool hasValue = selectedText != null && selectedText!.isNotEmpty;

    final String displayText = hasValue
        ? selectedText!
        : Utils.getString(context, 'home_search__not_set');

    final TextStyle textStyle = hasValue
        ? theme.textTheme.bodyLarge!
        : theme.textTheme.bodyLarge!.copyWith(
      color: Utils.isLightMode(context)
          ? PsColors.textPrimaryLightColor
          : colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // العنوان
        Padding(
          padding: const EdgeInsets.only(
            left: PsDimens.space12,
            right: PsDimens.space12,
            top: PsDimens.space4,
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),

        const SizedBox(height: PsDimens.space8),

        // الـ dropdown نفسه
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PsDimens.space12,
          ),
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(PsDimens.space10),
            child: InkWell(
              borderRadius: BorderRadius.circular(PsDimens.space10),
              onTap: onTap,
              child: Container(
                height: PsDimens.space44,
                padding: const EdgeInsets.symmetric(
                  horizontal: PsDimens.space12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(PsDimens.space10),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        displayText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                      ),
                    ),
                    const SizedBox(width: PsDimens.space8),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: PsColors.activeColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
