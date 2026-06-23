import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/base/ps_widget_with_appbar.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/dialog/success_dialog.dart';
import 'package:taapdeel/ui/common/ps_ui_widget.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/profile_update_view_holder.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../common/taapdeel/taapdeel_button.dart';
import '../../common/taapdeel/taapdeel_scaffold.dart';
import '../../common/taapdeel/taapdeel_text_field.dart';


class EditProfileView extends StatefulWidget {
  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView>
    with SingleTickerProviderStateMixin {
  UserRepository? userRepository;
  UserProvider? userProvider;
  PsValueHolder? psValueHolder;

  late AnimationController animationController;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  bool bindDataFirstTime = true;

  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    aboutMeController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);

    Future<bool> _requestPop() {
      animationController.reverse().then<dynamic>((void data) {
        if (!mounted) {
          return Future<bool>.value(false);
        }
        Navigator.pop(context, true);
        return Future<bool>.value(true);
      });
      return Future<bool>.value(false);
    }

    return WillPopScope(
      onWillPop: _requestPop,
      child: PsWidgetWithAppBar<UserProvider>(
        appBarTitle: Utils.getString(context, 'edit_profile__title'),
        initProvider: () {
          return UserProvider(repo: userRepository, psValueHolder: psValueHolder);
        },
        onProviderReady: (UserProvider provider) async {
          await provider.getUser(provider.psValueHolder!.loginUserId);
        },
        builder: (BuildContext context, UserProvider userProvider, Widget? child) {
          if (userProvider.user.data == null) {
            return Stack(
              children: <Widget>[
                Container(),
                PSProgressIndicator(userProvider.user.status),
              ],
            );
          }

          // ✅ Bind once
          if (bindDataFirstTime) {
            userNameController.text = userProvider.user.data!.userName ?? '';
            emailController.text = userProvider.user.data!.userEmail ?? '';
            cityController.text = userProvider.user.data!.city ?? '';
            addressController.text = userProvider.user.data!.userAddress ?? '';
            phoneController.text = userProvider.user.data!.userPhone ?? '';
            aboutMeController.text = userProvider.user.data!.userAboutMe ?? '';
            bindDataFirstTime = false;
          }

          return TaapdeelScaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: PsDimens.space16,
                right: PsDimens.space16,
                bottom: PsDimens.space24,
                top: PsDimens.space12,
              ),
              child: Column(
                children: <Widget>[
                  _ProfileHeaderPremium(userProvider: userProvider),
                  const SizedBox(height: PsDimens.space16),

                  _GlassSection(
                    title: 'البيانات الأساسية',
                    icon: Icons.person_outline,
                    child: Column(
                      children: <Widget>[
                        TaapdeelTextField(
                          controller: userNameController,
                          label: Utils.getString(context, 'edit_profile__user_name'),
                          hint: Utils.getString(context, 'edit_profile__user_name'),
                          prefixIcon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: PsDimens.space12),
                        TaapdeelTextField(
                          controller: emailController,
                          label: Utils.getString(context, 'edit_profile__email'),
                          hint: Utils.getString(context, 'edit_profile__email'),
                          prefixIcon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: PsDimens.space12),

                        // Phone row (read-only + edit)
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TaapdeelTextField(
                                controller: phoneController,
                                label: Utils.getString(context, 'edit_profile__phone'),
                                hint: Utils.getString(context, 'edit_profile__phone'),
                                prefixIcon: Icons.phone_iphone,
                                keyboardType: TextInputType.phone,
                                readOnly: true,
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: PsDimens.space14),

                  _GlassSection(
                    title: 'نبذة عني',
                    icon: Icons.notes_outlined,
                    child: TaapdeelTextField(
                      controller: aboutMeController,
                      label: Utils.getString(context, 'edit_profile__about_me'),
                      hint: Utils.getString(context, 'edit_profile__about_me'),
                      prefixIcon: Icons.edit_note_outlined,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      minLines: 4,
                    ),
                  ),

                  const SizedBox(height: PsDimens.space14),

                  _TwoButtonWidgetPremium(
                    userProvider: userProvider,
                    userNameController: userNameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    aboutMeController: aboutMeController,
                    addressController: addressController,
                    cityController: cityController,
                  ),

                  const SizedBox(height: PsDimens.space10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TwoButtonWidgetPremium extends StatelessWidget {
  const _TwoButtonWidgetPremium({
    required this.userProvider,
    required this.userNameController,
    required this.emailController,
    required this.phoneController,
    required this.aboutMeController,
    required this.addressController,
    required this.cityController,
  });

  final UserProvider userProvider;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aboutMeController;
  final TextEditingController addressController;
  final TextEditingController cityController;

  Future<void> _save(BuildContext context) async {
    if (userNameController.text.trim().isEmpty) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'edit_profile__name_error'),
          );
        },
      );
      return;
    }


    if (!await Utils.checkInternetConnectivity()) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'error_dialog__no_internet'),
          );
        },
      );
      return;
    }

    final ProfileUpdateParameterHolder holder = ProfileUpdateParameterHolder(
      userId: userProvider.user.data!.userId,
      userName: userNameController.text.trim(),
      userEmail: emailController.text.trim(),
      userPhone: phoneController.text.trim(),
      userAboutMe: aboutMeController.text.trim(),
      isShowEmail: userProvider.user.data!.isShowEmail,
      isShowPhone: userProvider.user.data!.isShowPhone,
      userAddress: addressController.text.trim(),
      city: cityController.text.trim(),
      deviceToken: userProvider.psValueHolder!.deviceToken,
    );

    await PsProgressDialog.showDialog(context);

    final PsResource<User> apiStatus =
    await userProvider.postProfileUpdate(holder.toMap());

    PsProgressDialog.dismissDialog();

    if (apiStatus.data != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Utils.getString(context, 'edit_profile__success'))),
      );
      Navigator.pop(context, true); // ✅ back to ProfileView
    }

    else {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(message: apiStatus.message);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TaapdeelButton(
          label: Utils.getString(context, 'edit_profile__save'),
          onPressed: () => _save(context),
          isPrimary: true,
          isExpanded: true,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        ),
      ],
    );
  }
}

class _ProfileHeaderPremium extends StatefulWidget {
  const _ProfileHeaderPremium({required this.userProvider});
  final UserProvider userProvider;

  @override
  State<_ProfileHeaderPremium> createState() => _ProfileHeaderPremiumState();
}

class _ProfileHeaderPremiumState extends State<_ProfileHeaderPremium> {
  XFile? _pickedImage;

  Future<bool> _requestGalleryPermission() async {
    // iOS: photos | Android: photos/storage حسب الإصدارات
    final PermissionStatus photos = await Permission.photos.request();
    if (photos == PermissionStatus.granted) return true;

    // fallback لبعض أجهزة Android
    final PermissionStatus storage = await Permission.storage.request();
    if (storage == PermissionStatus.granted) return true;

    return openAppSettings();
  }

  Future<void> _pickAndUpload() async {
    if (!await Utils.checkInternetConnectivity()) {
      showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            message: Utils.getString(context, 'error_dialog__no_internet'),
          );
        },
      );
      return;
    }

    final bool allowed = await _requestGalleryPermission();
    if (!allowed) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? img = await picker.pickImage(source: ImageSource.gallery);
      if (img == null) return;

      if (img.name.toLowerCase().endsWith('.webp')) {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: Utils.getString(context, 'error_dialog__webp_image'),
            );
          },
        );
        return;
      }

      setState(() => _pickedImage = img);

      await PsProgressDialog.showDialog(context);

      final PsResource<User> apiStatus = await widget.userProvider.postImageUpload(
        widget.userProvider.psValueHolder!.loginUserId!,
        PsConst.PLATFORM,
        await Utils.getImageFileFromAssets(
          img,
          widget.userProvider.psValueHolder!.chatImageSize!,
        ),
      );

      PsProgressDialog.dismissDialog();

      if (apiStatus.data != null) {
        setState(() {
          widget.userProvider.user.data = apiStatus.data;
        });
      }
    } catch (_) {
      PsProgressDialog.dismissDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? u = widget.userProvider.user.data;

    final String? remoteUrl = u?.userProfilePhoto;
    final bool hasRemote = remoteUrl != null && remoteUrl.isNotEmpty;

    final Widget avatar = ClipOval(
      child: SizedBox(
        width: 92,
        height: 92,
        child: hasRemote
            ? PsNetworkCircleImageForUser(
          photoKey: '',
          imagePath: remoteUrl,
          width: 92,
          height: 92,
          boxfit: BoxFit.cover,
        )
            : (_pickedImage != null
            ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
            : Image.asset(
          'assets/images/user_default_photo.png',
          fit: BoxFit.cover,
        )),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(PsDimens.space16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              avatar,
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _pickAndUpload,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: PsColors.primary500,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: PsDimens.space14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  u?.userName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  u?.userEmail ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.black.withValues(alpha: 0.55)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        (u?.city ?? '').isEmpty ? '—' : (u?.city ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.title,
    required this.child,
    required this.icon,
  });

  final String title;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: PsColors.primary500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

