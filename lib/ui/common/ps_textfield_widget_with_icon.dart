import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

class PsTextFieldWidgetWithIcon extends StatelessWidget {
  const PsTextFieldWidgetWithIcon({
    Key? key,
    this.textEditingController,
    this.hintText,
    this.height = PsDimens.space44,
    this.keyboardType = TextInputType.text,
    this.psValueHolder,
    this.clickEnterFunction,
    this.clickSearchButton,
  }) : super(key: key);

  final TextEditingController? textEditingController;
  final String? hintText;

  /// Kept for backward compatibility. Height is driven by content.
  final double height;

  final TextInputType keyboardType;

  /// Kept only for backward compatibility with old code paths.
  final PsValueHolder? psValueHolder;

  final VoidCallback? clickEnterFunction;
  final VoidCallback? clickSearchButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: PsDimens.space16,
        vertical: PsDimens.space8,
      ),
      child: TaapdeelTextField(
        controller: textEditingController,
        hint: hintText,
        keyboardType: keyboardType,
        prefixIcon: Icons.search,
        isSearchField: true,
        onSubmitted: (String value) {
          clickEnterFunction?.call();
        },
        suffixIcon: (clickSearchButton != null)
            ? IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: clickSearchButton,
        )
            : null,
      ),
    );
  }
}

class PsTextFieldWidgetWithIcon2 extends StatelessWidget {
  const PsTextFieldWidgetWithIcon2({
    Key? key,
    this.textEditingController,
    this.hintText,
    this.height = PsDimens.space44,
    this.keyboardType = TextInputType.text,
    this.psValueHolder,
    this.clickEnterFunction,
    this.onTap,
    this.clickSearchButton,
  }) : super(key: key);

  final TextEditingController? textEditingController;
  final String? hintText;

  /// Kept for backward compatibility. Height is driven by content.
  final double height;

  final TextInputType keyboardType;

  /// Kept only for backward compatibility with old code paths.
  final PsValueHolder? psValueHolder;

  final VoidCallback? clickEnterFunction;
  final VoidCallback? clickSearchButton;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: PsDimens.space16,
        vertical: PsDimens.space8,
      ),
      child: Stack(
        children: <Widget>[
          // Read-only field; selection happens via the right-side button.
          TaapdeelTextField(
            controller: textEditingController,
            hint: hintText,
            keyboardType: keyboardType,
            readOnly: true,
            onSubmitted: (String value) {
              clickEnterFunction?.call();
            },
          ),
          Positioned(
            right: PsDimens.space4,
            top: PsDimens.space4,
            bottom: PsDimens.space4,
            child: Material(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onTap ??
                        () {
                      clickSearchButton?.call();
                    },
                child: SizedBox(
                  width: 48,
                  child: Icon(
                    Icons.book,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
