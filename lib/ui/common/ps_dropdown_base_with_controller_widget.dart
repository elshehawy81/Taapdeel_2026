import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/utils/utils.dart';

class PsDropdownBaseWithControllerWidget extends StatefulWidget {
  const PsDropdownBaseWithControllerWidget({
    Key? key,
    this.masseg,
    this.chose = false,
    this.width,
    required this.title,
    required this.onTap,
    this.textEditingController,
    this.isStar = false,
    this.isInfo = false,
  }) : super(key: key);

  /// هل الـ card متعلَّمة / مختارة (نستخدمها لتلوين البوردر)
  final bool chose;

  /// message key لرسالة الـ info dialog (ممكن تكون null)
  final String? masseg;

  /// عرض الحقل، لو null بنستخدم:
  ///  - كامل الشاشة
  ///  - أو 70% لو masseg == 'price_original'
  final double? width;

  final String title;
  final TextEditingController? textEditingController;

  /// يتم استدعاؤه عند الضغط على الـ dropdown
  final VoidCallback onTap;

  /// يعرض نجمة (required) بجوار العنوان
  final bool isStar;

  /// يعرض أيقونة معلومات تفتح dialog
  final bool isInfo;

  @override
  _PsDropdownBaseWithControllerWidgetState createState() =>
      _PsDropdownBaseWithControllerWidgetState();
}

class _PsDropdownBaseWithControllerWidgetState
    extends State<PsDropdownBaseWithControllerWidget> {
  void _showInfoDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final String body = widget.masseg == null
        ? ''
        : Utils.getString(context, widget.masseg!);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PsColors.primary500.withValues(alpha:0.08),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: PsColors.primary500,
                    size: 28,
                  ),
                ),
                const SizedBox(height: PsDimens.space16),

                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PsColors.textColor1,
                  ),
                ),

                const SizedBox(height: PsDimens.space8),

                // Body
                if (body.isNotEmpty)
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PsColors.textColor2,
                    ),
                  ),

                const SizedBox(height: PsDimens.space20),

                // OK button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PsColors.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(
                      Utils.getString(context, 'dialog__ok'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final String value = widget.textEditingController?.text ?? '';
    final bool hasValue = value.isNotEmpty;

    final String displayText = hasValue
        ? value
        : Utils.getString(context, 'home_search__not_set');

    final TextStyle textStyle = hasValue
        ? theme.textTheme.bodyLarge!
        : theme.textTheme.bodyLarge!.copyWith(
      color: PsColors.textPrimaryLightColor,
    );

    // نحترم الـ width لو جاية من بره، وإلا نطبق منطق السعر
    final double effectiveWidth = widget.width ??
        (widget.masseg != 'price_original'
            ? double.infinity
            : MediaQuery.of(context).size.width * 0.7);

    // عنوان الحقل + نجمة + Info
    Widget _buildTitleRow() {
      final List<Widget> children = <Widget>[
        Flexible(
          child: Text(
            widget.title,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ];

      if (widget.isStar) {
        children.add(
          Text(
            ' *',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: PsColors.activeColor,
            ),
          ),
        );
      }

      if (widget.isInfo) {
        children.add(
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.info_outline_rounded,
              color: Colors.amber[700],
            ),
            onPressed: () => _showInfoDialog(context),
          ),
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    final Color borderColor = widget.chose
        ? (PsColors.activeColor ?? PsColors.mainDividerColor)
        : (colorScheme.outlineVariant);

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
          child: _buildTitleRow(),
        ),

        const SizedBox(height: PsDimens.space8),

        // الـ dropdown نفسه
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PsDimens.space12,
          ),
          child: SizedBox(
            width: effectiveWidth,
            child: Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(PsDimens.space10),
              child: InkWell(
                borderRadius: BorderRadius.circular(PsDimens.space10),
                onTap: widget.onTap,
                child: Container(
                  height: PsDimens.space44,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PsDimens.space12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(PsDimens.space10),
                    border: Border.all(
                      color: borderColor,
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
        ),
      ],
    );
  }
}
