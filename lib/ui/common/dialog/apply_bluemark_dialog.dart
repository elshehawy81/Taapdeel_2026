import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/provider/gallery/gallery_provider.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/apply_agent_parameter_holder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ApplyBlueMarkDialog extends StatefulWidget {
  const ApplyBlueMarkDialog(this.galleryProvider, {Key? key})
      : super(key: key);

  final GalleryProvider galleryProvider;

  @override
  State<ApplyBlueMarkDialog> createState() => _ApplyBlueMarkDialogState();
}

class _ApplyBlueMarkDialogState extends State<ApplyBlueMarkDialog> {
  final TextEditingController agentNoteController = TextEditingController();

  @override
  void dispose() {
    agentNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (agentNoteController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: Utils.getString(context, 'enter_contact_info'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: PsColors.activeColor,
        textColor: PsColors.textColor4,
      );
      return;
    }

    await PsProgressDialog.showDialog(context);

    final PsValueHolder valueHolder =
    Provider.of<PsValueHolder>(context, listen: false);

    final ApplyAgentParameterHolder holder = ApplyAgentParameterHolder(
      userId: valueHolder.loginUserId!,
      note: agentNoteController.text.trim(),
    );

    final PsResource<ApiStatus> apiStatus = await widget.galleryProvider
        .postApplyBlueMark(holder.toMap());

    PsProgressDialog.dismissDialog();

    if (apiStatus.data != null) {
      // success
      Navigator.pop(context, true);
      Fluttertoast.showToast(
        msg: Utils.getString(context, 'success_dialog__success'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: PsColors.primary500,
        textColor: PsColors.white,
      );
    } else {
      Navigator.pop(context, true);
      Fluttertoast.showToast(
        msg: apiStatus.message ?? 'Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: PsColors.activeColor,
        textColor: PsColors.textColor4,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PsDimens.space16,
              vertical: PsDimens.space12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: PsDimens.space8),

                // Title
                Text(
                  Utils.getString(context, 'apply_blue_mark_title'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: PsColors.textColor1,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: PsDimens.space16),

                // Description
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Utils.getString(
                      context,
                      'apply_blue_mark_verification_agent',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: PsDimens.space12),

                // Text field
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PsColors.backgroundColor,
                    borderRadius: BorderRadius.circular(PsDimens.space8),
                    border: Border.all(color: PsColors.mainDividerColor),
                  ),
                  padding: const EdgeInsets.all(PsDimens.space4),
                  child: TextFormField(
                    controller: agentNoteController,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 6,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.all(PsDimens.space8),
                      hintText: Utils.getString(
                        context,
                        'enter_contact_info',
                      ),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: PsColors.textPrimaryLightColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: PsDimens.space20),

                // Apply button
                TaapdeelButton(
                  label: Utils.getString(context, 'blue_mark_apply'),
                  isPrimary: true,
                  isExpanded: true,
                  onPressed: () => _submit(context),
                ),

                const SizedBox(height: PsDimens.space12),

                // Cancel button
                TaapdeelButton(
                  label: Utils.getString(context, 'dialog__cancel'),
                  isPrimary: false,
                  outlined: true,
                  isExpanded: true,
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: PsDimens.space8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
