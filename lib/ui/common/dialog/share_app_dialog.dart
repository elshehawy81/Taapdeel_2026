import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';
import 'package:taapdeel/utils/taapdeel_share_links.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

class ShareAppDialog extends StatelessWidget {
  const ShareAppDialog({
    Key? key,
    this.message,
    this.onPressed,
  }) : super(key: key);

  final String? message;
  final VoidCallback? onPressed;

  String _safeShareUrl(String? value) {
    final String url = (value ?? '').trim();
    if (url.isEmpty || url.toLowerCase() == 'null') {
      return TaapdeelShareLinks.downloadUrl;
    }
    return url;
  }

  Future<void> _shareUrl({
    required BuildContext context,
    required String url,
  }) async {
    final Size size = MediaQuery.of(context).size;

    await Share.share(
      url,
      sharePositionOrigin: Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height / 2,
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);

    final String titleText = Utils.getString(context, 'share_app');
    final String bodyText = message ?? '';

    return TaapdeelBaseDialog(
      icon: Icons.ios_share_rounded,
      iconColor: Colors.white,
      iconBackground: PsColors.primary500,
      title: titleText,
      message: bodyText,
      primaryButtonLabel: Utils.getString(context, 'share_android_app'),
      onPrimaryTap: () async {
        await _shareUrl(
          context: context,
          url: _safeShareUrl(psValueHolder.googlePlayStoreUrl),
        );
      },
      secondaryButtonLabel: Utils.getString(context, 'share_ios_app'),
      onSecondaryTap: () async {
        await _shareUrl(
          context: context,
          url: _safeShareUrl(psValueHolder.appleAppStoreUrl),
        );
      },
    );
  }
}