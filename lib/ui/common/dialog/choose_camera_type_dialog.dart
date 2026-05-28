import 'package:flutter/material.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';

class ChooseCameraTypeDialog extends StatelessWidget {
  const ChooseCameraTypeDialog({
    Key? key,
    this.onCameraTap,
    this.onGalleryTap,
  }) : super(key: key);

  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return TaapdeelBaseDialog(
      icon: Icons.camera_alt_outlined,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500,
      title: Utils.getString(context, 'camera_dialog__title'),
      message:
      Utils.getString(context, 'camera_dialog__gallery_and_camera'),

      // Camera
      primaryButtonLabel:
      Utils.getString(context, 'camera_dialog__from_gallery'),
      onPrimaryTap: () {
        Navigator.of(context).pop();
        onGalleryTap?.call();

      },

      // Gallery
      secondaryButtonLabel:
      Utils.getString(context, 'camera_dialog__take_photo'),
      onSecondaryTap: () {
        Navigator.of(context).pop();
        onCameraTap?.call();
      },
    );
  }
}
