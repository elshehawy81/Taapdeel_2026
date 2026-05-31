import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/ui/common/ps_hero.dart';
import 'package:taapdeel/ui/common/ps_square_progress_widget.dart';
import 'package:taapdeel/ui/rating/item/rating_list_item.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/default_icon.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

/// ===============================================================
/// ✅ Helpers (Age/Gender Avatar Pick)
/// ===============================================================
int? psParseAgeFromRange(String? ageRange) {
  if (ageRange == null) return null;
  final String s = ageRange.trim();
  if (s.isEmpty) return null;

  // Supports: "16-22", "16 - 22", "16–22", "16—22"
  final String normalized = s.replaceAll('–', '-').replaceAll('—', '-');
  final RegExp reg = RegExp(r'^\s*(\d{1,3})\s*(?:-\s*(\d{1,3}))?\s*$');
  final Match? m = reg.firstMatch(normalized);
  if (m == null) return null;

  final int? start = int.tryParse(m.group(1) ?? '');
  final int? end = int.tryParse(m.group(2) ?? '');

  if (start == null && end == null) return null;

  // choose end if exists (upper bound is safer for adult/young threshold)
  return end ?? start;
}

bool psIsMale(String? gender) {
  if (gender == null) return false;
  final String g = gender.trim().toLowerCase();
  return g == 'male';
}

bool psIsFemale(String? gender) {
  if (gender == null) return false;
  final String g = gender.trim().toLowerCase();
  return g == 'female';
}

String psPickUserAvatarAsset({
  String? gender,
  String? ageRange,
}) {
  const String fallback = 'assets/images/user_default_photo.png';

  final int? age = psParseAgeFromRange(ageRange);
  if (age == null) return fallback;

  final bool isMale = psIsMale(gender);
  final bool isFemale = psIsFemale(gender);
  if (!isMale && !isFemale) return fallback;

  final bool isYoung = age < 25;


  if (isMale) {
    return isYoung ? 'assets/images/male_young.png' : 'assets/images/male_adult.png';
  } else {
    return isYoung ? 'assets/images/female_young.png' : 'assets/images/female_adult.png';
  }
}

/// ===============================================================
/// ✅ NEW: Safe thumbnail placeholder builder
/// - prevents big X when thumbnail 2x/3x returns 404
/// - fallback order: requested thumbnail -> 1x thumbnail -> spinner/asset
/// ===============================================================
Widget _psThumbPlaceholder({
  required bool isUseThumbnail,
  required double? width,
  required double? height,
  required BoxFit fit,
  required String thumbnailUrl,
  required String fallbackThumb1xUrl,
  Widget? finalFallback,
}) {
  if (!isUseThumbnail) {
    return const PsSquareProgressWidget();
  }

  final Widget fallbackWidget = finalFallback ?? const PsSquareProgressWidget();

  return CachedNetworkImage(
    width: width,
    height: height,
    fit: fit,
    imageUrl: thumbnailUrl,
    placeholder: (BuildContext context, String url) => const PsSquareProgressWidget(),
    errorWidget: (BuildContext context, String url, Object error) {
      // fallback to 1x thumbnail if 2x/3x missing (404)
      if (fallbackThumb1xUrl.isNotEmpty && fallbackThumb1xUrl != thumbnailUrl) {
        return CachedNetworkImage(
          width: width,
          height: height,
          fit: fit,
          imageUrl: fallbackThumb1xUrl,
          placeholder: (BuildContext context, String url) => const PsSquareProgressWidget(),
          errorWidget: (BuildContext context, String url, Object error) => fallbackWidget,
        );
      }
      return fallbackWidget;
    },
  );
}

/// ===============================================================
/// ✅ NEW: Thumbnail URL chooser
/// ===============================================================
String _psPickThumbUrl({
  required String imgPath,
  required String tier, // PsConst.Aspect_Ratio_1x/2x/3x or other
}) {
  if (tier == PsConst.Aspect_Ratio_1x) {
    return '${PsConfig.ps_app_image_thumbs_url}$imgPath';
  } else if (tier == PsConst.Aspect_Ratio_2x) {
    return '${PsConfig.ps_app_image_thumbs_2x_url}$imgPath';
  } else if (tier == PsConst.Aspect_Ratio_3x) {
    return '${PsConfig.ps_app_image_thumbs_3x_url}$imgPath';
  }
  // fallback
  return '${PsConfig.ps_app_image_thumbs_url}$imgPath';
}

/// ===============================================================
/// ✅ PsNetworkImage
/// ===============================================================
class PsNetworkImage extends StatefulWidget {
  const PsNetworkImage({
    Key? key,
    required this.photoKey,
    required this.defaultPhoto,
    required this.imageAspectRation,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.fill,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String? photoKey;
  final BoxFit boxfit;
  final DefaultPhoto? defaultPhoto;
  final String imageAspectRation;

  @override
  State<PsNetworkImage> createState() => _PsNetworkImageState();
}

class _PsNetworkImageState extends State<PsNetworkImage> {
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    final bool isUseThumbnail = context.select<PsValueHolder, bool>(
        (vh) => vh.isUseThumbnailAsPlaceHolder ?? false);

    width = (widget.width == double.infinity) ? MediaQuery.of(context).size.width : widget.width;
    height = (widget.height == double.infinity) ? MediaQuery.of(context).size.height : widget.height;

    if ((widget.defaultPhoto?.imgPath ?? '') == '') {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: Image.asset(
          'assets/images/placeholder_image.png',
          width: width,
          height: height,
          fit: widget.boxfit,
        ),
      );
    }

    final String imgPath = widget.defaultPhoto!.imgPath!;
    final String fullImagePath = '${PsConfig.ps_app_image_url}$imgPath';

    final String thumbnailImagePath = _psPickThumbUrl(
      imgPath: imgPath,
      tier: widget.imageAspectRation,
    );
    final String fallbackThumb1xPath = '${PsConfig.ps_app_image_thumbs_url}$imgPath';

    return PsHero(
      transitionOnUserGestures: true,
      tag: widget.photoKey ?? fullImagePath,
      child: GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: CachedNetworkImage(
          placeholder: (BuildContext context, String url) {
            return _psThumbPlaceholder(
              isUseThumbnail: isUseThumbnail,
              width: width,
              height: height,
              fit: widget.boxfit,
              thumbnailUrl: thumbnailImagePath,
              fallbackThumb1xUrl: fallbackThumb1xPath,
              finalFallback: const PsSquareProgressWidget(),
            );
          },
          width: width,
          height: height,
          fit: widget.boxfit,
          imageUrl: fullImagePath,
          errorWidget: (BuildContext context, String url, Object? error) => Image.asset(
            'assets/images/placeholder_image.png',
            width: width,
            height: height,
            fit: widget.boxfit,
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// ✅ PsNetworkImageWithUrl
/// ===============================================================
class PsNetworkImageWithUrl extends StatefulWidget {
  const PsNetworkImageWithUrl({
    Key? key,
    required this.photoKey,
    required this.imagePath,
    required this.imageAspectRation,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String? imagePath;
  final String imageAspectRation;

  @override
  State<PsNetworkImageWithUrl> createState() => _PsNetworkImageWithUrlState();
}

class _PsNetworkImageWithUrlState extends State<PsNetworkImageWithUrl> {
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    final bool isUseThumbnail = context.select<PsValueHolder, bool>(
        (vh) => vh.isUseThumbnailAsPlaceHolder ?? false);

    width = (widget.width == double.infinity) ? MediaQuery.of(context).size.width : widget.width;
    height = (widget.height == double.infinity) ? MediaQuery.of(context).size.height : widget.height;

    final String path = (widget.imagePath ?? '').trim();
    if (path.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: Image.asset(
          'assets/images/placeholder_image.png',
          width: width,
          height: height,
          fit: widget.boxfit,
        ),
      );
    }

    final String fullImagePath = '${PsConfig.ps_app_image_url}$path';
    final String thumbnailImagePath = _psPickThumbUrl(imgPath: path, tier: widget.imageAspectRation);
    final String fallbackThumb1xPath = '${PsConfig.ps_app_image_thumbs_url}$path';

    return GestureDetector(
      onTap: widget.onTap as void Function()?,
      child: CachedNetworkImage(
        placeholder: (BuildContext context, String url) {
          return _psThumbPlaceholder(
            isUseThumbnail: isUseThumbnail,
            width: width,
            height: height,
            fit: widget.boxfit,
            thumbnailUrl: thumbnailImagePath,
            fallbackThumb1xUrl: fallbackThumb1xPath,
            finalFallback: const PsSquareProgressWidget(),
          );
        },
        width: width,
        height: height,
        fit: widget.boxfit,
        imageUrl: fullImagePath,
        errorWidget: (BuildContext context, String url, Object? error) => Image.asset(
          'assets/images/placeholder_image.png',
          width: width,
          height: height,
          fit: widget.boxfit,
        ),
      ),
    );
  }
}

/// ===============================================================
/// ✅ UPDATED: PsNetworkImageWithUrlForUser
/// - Adds gender + ageRange
/// - Uses smart avatar if imagePath empty OR image fails
/// - Thumbnail placeholder now safe (no X)
/// ===============================================================
class PsNetworkImageWithUrlForUser extends StatefulWidget {
  const PsNetworkImageWithUrlForUser({
    Key? key,
    required this.photoKey,
    required this.imagePath,
    required this.imageAspectRation,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,

    // ✅ NEW
    this.gender,
    this.ageRange,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String? imagePath;
  final String imageAspectRation;

  final String? gender;
  final String? ageRange;

  @override
  State<PsNetworkImageWithUrlForUser> createState() => _PsNetworkImageWithUrlForUserState();
}

class _PsNetworkImageWithUrlForUserState extends State<PsNetworkImageWithUrlForUser> {
  late double? width;
  late double? height;

  @override
  Widget build(BuildContext context) {
    final bool isUseThumbnail = context.select<PsValueHolder, bool>(
        (vh) => vh.isUseThumbnailAsPlaceHolder ?? false);

    width = (widget.width == double.infinity) ? MediaQuery.of(context).size.width : widget.width;
    height = (widget.height == double.infinity) ? MediaQuery.of(context).size.height : widget.height;

    final String defaultAvatar = psPickUserAvatarAsset(gender: widget.gender, ageRange: widget.ageRange);
    final String path = (widget.imagePath ?? '').trim();

    if (path.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: Image.asset(
          defaultAvatar,
          width: width,
          height: height,
          fit: widget.boxfit,
        ),
      );
    }

    final String fullImagePath = '${PsConfig.ps_app_image_url}$path';
    final String thumbnailImagePath = _psPickThumbUrl(imgPath: path, tier: widget.imageAspectRation);
    final String fallbackThumb1xPath = '${PsConfig.ps_app_image_thumbs_url}$path';

    return GestureDetector(
      onTap: widget.onTap as void Function()?,
      child: CachedNetworkImage(
        placeholder: (BuildContext context, String url) {
          return _psThumbPlaceholder(
            isUseThumbnail: isUseThumbnail,
            width: width,
            height: height,
            fit: widget.boxfit,
            thumbnailUrl: thumbnailImagePath,
            fallbackThumb1xUrl: fallbackThumb1xPath,
            finalFallback: Image.asset(
              defaultAvatar,
              width: width,
              height: height,
              fit: widget.boxfit,
            ),
          );
        },
        width: width,
        height: height,
        fit: widget.boxfit,
        imageUrl: fullImagePath,
        errorWidget: (BuildContext context, String url, Object? error) => Image.asset(
          defaultAvatar,
          width: width,
          height: height,
          fit: widget.boxfit,
        ),
      ),
    );
  }
}

/// ===============================================================
/// ✅ PsFileImage
/// ===============================================================
class PsFileImage extends StatelessWidget {
  const PsFileImage({
    Key? key,
    required this.photoKey,
    required this.file,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final File file;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: (file.path.isEmpty)
          ? Image.asset(
        'assets/images/placeholder_image.png',
        width: width,
        height: height,
        fit: boxfit,
      )
          : Image(image: FileImage(file)),
    );
  }
}

/// ===============================================================
/// ✅ PsNetworkCircleImage
/// (Fixed: uses psValueHolder properly + safe thumbnail placeholder)
/// ===============================================================
class PsNetworkCircleImage extends StatefulWidget {
  const PsNetworkCircleImage({
    Key? key,
    required this.photoKey,
    this.imagePath,
    this.asset,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String? imagePath;
  final String? asset;

  @override
  State<PsNetworkCircleImage> createState() => _PsNetworkCircleImageState();
}

class _PsNetworkCircleImageState extends State<PsNetworkCircleImage> {
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    final bool isUseThumbnail = context.select<PsValueHolder, bool>(
        (vh) => vh.isUseThumbnailAsPlaceHolder ?? false);

    width = (widget.width == double.infinity) ? MediaQuery.of(context).size.width : widget.width;
    height = (widget.height == double.infinity) ? MediaQuery.of(context).size.height : widget.height;

    final String path = (widget.imagePath ?? '').trim();

    if (path.isEmpty) {
      if ((widget.asset ?? '').trim().isEmpty) {
        return GestureDetector(
          onTap: widget.onTap as void Function()?,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: Image.asset(
              'assets/images/placeholder_image.png',
              width: width,
              height: height,
              fit: widget.boxfit,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: Hero(
          tag: '${widget.photoKey}${widget.asset}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: Image.asset(
              widget.asset!,
              width: width,
              height: height,
              fit: widget.boxfit,
            ),
          ),
        ),
      );
    }

    final String fullImagePath = '${PsConfig.ps_app_image_url}$path';
    final String thumb1x = '${PsConfig.ps_app_image_thumbs_url}$path';

    Widget image = CachedNetworkImage(
      placeholder: (BuildContext context, String url) {
        // For circle widgets, we only have 1x thumbs in original code.
        // Still safe: if thumb missing -> spinner instead of X.
        return _psThumbPlaceholder(
          isUseThumbnail: isUseThumbnail,
          width: width,
          height: height,
          fit: widget.boxfit,
          thumbnailUrl: thumb1x,
          fallbackThumb1xUrl: thumb1x,
          finalFallback: const PsSquareProgressWidget(),
        );
      },
      width: width,
      height: height,
      fit: widget.boxfit,
      imageUrl: fullImagePath,
      errorWidget: (BuildContext context, String url, Object? error) => Image.asset(
        'assets/images/placeholder_image.png',
        width: width,
        height: height,
        fit: widget.boxfit,
      ),
    );

    image = ClipRRect(
      borderRadius: BorderRadius.circular(10000.0),
      child: image,
    );

    if (widget.photoKey.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: image,
      );
    }

    return GestureDetector(
      onTap: widget.onTap as void Function()?,
      child: Hero(
        tag: '${widget.photoKey}${widget.imagePath}',
        child: image,
      ),
    );
  }
}

/// ===============================================================
/// ✅ UPDATED: PsNetworkCircleImageForUser
/// - Uses smart avatar if imagePath empty OR image fails
/// - Safe thumbnail placeholder (no X)
/// ===============================================================
class PsNetworkCircleImageForUser extends StatefulWidget {
  const PsNetworkCircleImageForUser({
    Key? key,
    required this.photoKey,
    this.imagePath,
    this.asset,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,

    // ✅ NEW
    this.gender,
    this.ageRange,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final String? imagePath;
  final String? asset;

  final String? gender;
  final String? ageRange;

  @override
  State<PsNetworkCircleImageForUser> createState() => _PsNetworkCircleImageForUserState();
}

class _PsNetworkCircleImageForUserState extends State<PsNetworkCircleImageForUser> {
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    final bool isUseThumbnail = context.select<PsValueHolder, bool>(
        (vh) => vh.isUseThumbnailAsPlaceHolder ?? false);

    width = (widget.width == double.infinity) ? MediaQuery.of(context).size.width : widget.width;
    height = (widget.height == double.infinity) ? MediaQuery.of(context).size.height : widget.height;

    final String defaultAvatar = psPickUserAvatarAsset(gender: widget.gender, ageRange: widget.ageRange);
    final String path = (widget.imagePath ?? '').trim();

    if (path.isEmpty) {
      if ((widget.asset ?? '').trim().isEmpty) {
        return GestureDetector(
          onTap: widget.onTap as void Function()?,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: Image.asset(
              defaultAvatar,
              width: width,
              height: height,
              fit: widget.boxfit,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: Hero(
          tag: '${widget.photoKey}${widget.asset}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: Image.asset(
              widget.asset!,
              width: width,
              height: height,
              fit: widget.boxfit,
            ),
          ),
        ),
      );
    }

    final String fullImagePath = '${PsConfig.ps_app_image_url}$path';
    final String thumb1x = '${PsConfig.ps_app_image_thumbs_url}$path';

    Widget image = CachedNetworkImage(
      placeholder: (BuildContext context, String url) {
        return _psThumbPlaceholder(
          isUseThumbnail: isUseThumbnail,
          width: width,
          height: height,
          fit: widget.boxfit,
          thumbnailUrl: thumb1x,
          fallbackThumb1xUrl: thumb1x,
          finalFallback: Image.asset(
            defaultAvatar,
            width: width,
            height: height,
            fit: widget.boxfit,
          ),
        );
      },
      width: width,
      height: height,
      fit: widget.boxfit,
      imageUrl: fullImagePath,
      errorWidget: (BuildContext context, String url, Object? error) => Image.asset(
        defaultAvatar,
        width: width,
        height: height,
        fit: widget.boxfit,
      ),
    );

    image = ClipRRect(
      borderRadius: BorderRadius.circular(10000.0),
      child: image,
    );

    if (widget.photoKey.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: image,
      );
    }

    return GestureDetector(
      onTap: widget.onTap as void Function()?,
      child: Hero(
        tag: '${widget.photoKey}${widget.imagePath}',
        child: image,
      ),
    );
  }
}

/// ===============================================================
/// ✅ PsFileCircleImage
/// ===============================================================
class PsFileCircleImage extends StatelessWidget {
  const PsFileCircleImage({
    Key? key,
    required this.photoKey,
    this.file,
    this.asset,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final File? file;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    if (file == null) {
      if ((asset ?? '').trim().isEmpty) {
        return GestureDetector(
          onTap: onTap as void Function()?,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: SizedBox(
              width: width,
              height: height,
              child: const Icon(Icons.image),
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: onTap as void Function()?,
        child: Hero(
          tag: '$photoKey$asset',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10000.0),
            child: Image.asset(
              asset!,
              width: width,
              height: height,
              fit: boxfit,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Hero(
        tag: file!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10000.0),
          child: Image(image: FileImage(file!)),
        ),
      ),
    );
  }
}

/// ===============================================================
/// ✅ PSProgressIndicator
/// ===============================================================
class PSProgressIndicator extends StatefulWidget {
  const PSProgressIndicator(this._status, {this.message});
  final PsStatus _status;
  final String? message;

  @override
  _PSProgressIndicator createState() => _PSProgressIndicator();
}

class _PSProgressIndicator extends State<PSProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    if (widget._status == PsStatus.ERROR && (widget.message ?? '').isNotEmpty) {
      Fluttertoast.showToast(
        msg: widget.message!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Visibility(
          visible: widget._status == PsStatus.PROGRESS_LOADING,
          child: const LinearProgressIndicator(),
        ),
      ),
    );
  }
}

/// ===============================================================
/// ✅ PsNetworkCircleIconImage
/// (Safe thumbnail placeholder - no X)
/// ===============================================================
class PsNetworkCircleIconImage extends StatefulWidget {
  const PsNetworkCircleIconImage({
    Key? key,
    required this.photoKey,
    required this.defaultIcon,
    this.width,
    this.height,
    this.onTap,
    this.boxfit = BoxFit.cover,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Function? onTap;
  final String photoKey;
  final BoxFit boxfit;
  final DefaultIcon? defaultIcon;

  @override
  State<PsNetworkCircleIconImage> createState() => _PsNetworkCircleIconImageState();
}

class _PsNetworkCircleIconImageState extends State<PsNetworkCircleIconImage> {
  double? width;
  double? height;

  @override
  Widget build(BuildContext context) {
    final bool isUseThumbnail = context.select<PsValueHolder, bool>(
        (vh) => vh.isUseThumbnailAsPlaceHolder ?? false);

    width = (widget.width == double.infinity) ? MediaQuery.of(context).size.width : widget.width;
    height = (widget.height == double.infinity) ? MediaQuery.of(context).size.height : widget.height;

    if ((widget.defaultIcon?.imgPath ?? '').trim().isEmpty) {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/placeholder_image.png',
            width: width,
            height: height,
            fit: widget.boxfit,
          ),
        ),
      );
    }

    final String path = widget.defaultIcon!.imgPath!;
    final String fullImagePath = '${PsConfig.ps_app_image_url}$path';
    final String thumb1x = '${PsConfig.ps_app_image_thumbs_url}$path';

    final Widget img = CachedNetworkImage(
      placeholder: (BuildContext context, String url) {
        return _psThumbPlaceholder(
          isUseThumbnail: isUseThumbnail,
          width: width,
          height: height,
          fit: widget.boxfit,
          thumbnailUrl: thumb1x,
          fallbackThumb1xUrl: thumb1x,
          finalFallback: const PsSquareProgressWidget(),
        );
      },
      width: width,
      height: height,
      fit: widget.boxfit,
      imageUrl: fullImagePath,
      errorWidget: (BuildContext context, String url, Object? error) => Image.asset(
        'assets/images/placeholder_image.png',
        width: width,
        height: height,
        fit: widget.boxfit,
      ),
    );

    if (widget.photoKey.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap as void Function()?,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: img,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap as void Function()?,
      child: Hero(
        tag: '${widget.photoKey}${PsConfig.ps_app_image_url}$path',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10000.0),
          child: img,
        ),
      ),
    );
  }
}