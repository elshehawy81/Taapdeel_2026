import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/utils/utils.dart';

class PsHeaderWidget extends StatelessWidget {
  const PsHeaderWidget({
    Key? key,
    required this.headerName,
    required this.viewAllClicked,
    this.showViewAll = true,
  }) : super(key: key);

  final String headerName;

  /// callback لما المستخدم يضغط "View all"
  final VoidCallback viewAllClicked;

  final bool showViewAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: PsDimens.space20,
        left: PsDimens.space16,
        right: PsDimens.space16,
        bottom: PsDimens.space12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            headerName,
            textAlign: TextAlign.start,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (showViewAll)
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: viewAllClicked,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PsDimens.space8,
                  vertical: PsDimens.space4,
                ),
                child: Text(
                  Utils.getString(context, 'profile__view_all'),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PsColors.activeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
