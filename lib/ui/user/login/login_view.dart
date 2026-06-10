import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/subcategory/sub_category_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/common/dialog/error_dialog.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_section_header.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';
import 'package:taapdeel/ui/category/default_interests_bootstrapper.dart';
import 'package:taapdeel/utils/auth_service.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/phone_login_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/subscribe_parameter_holder.dart';
import 'package:taapdeel/viewobject/sub_category.dart';
import 'package:taapdeel/viewobject/user.dart' as ps_user;

import '../../../db/common/ps_shared_preferences.dart';
import '../../Contacts/pending_follows_cache.dart';
import '../../Contacts/search_provider.dart';
import '../../Foryou/home_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    Key? key,
    this.animationController,
    this.animation,
    this.onProfileSelected,
    this.onForgotPasswordSelected,
    this.onSignInSelected,
    this.onGoogleSignInSelected,
    this.onFbSignInSelected,
    this.onAppleIdSignInSelected,
    this.onPhoneSignInSelected,
  }) : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;

  final Function? onProfileSelected;
  final Function? onForgotPasswordSelected;
  final Function? onSignInSelected;
  final Function? onGoogleSignInSelected;
  final Function? onFbSignInSelected;
  final Function? onAppleIdSignInSelected;
  final Function? onPhoneSignInSelected;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final ImagePicker _profileImagePicker = ImagePicker();
  final AuthService _authService = AuthService();

  File? _selectedProfileImageFile;

  bool _isSendingOtp = false;
  bool _isVerifying = false;
  bool _codeSent = false;
  String? _verificationId;

  /// يظهر الاسم للمستخدم الجديد فقط بعد رد السيرفر.
  bool _shouldAskName = true;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _otpSendingSnack;

  /// حماية من تكرار إرسال SMS حقيقي بسرعة؛ مهم للتكلفة و Firebase rate limits.
  Timer? _resendTimer;
  int _resendSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startAnimationIfNeeded();
  }

  void _startAnimationIfNeeded() {
    final AnimationController? controller = widget.animationController;
    if (controller != null &&
        (controller.status == AnimationStatus.dismissed ||
            controller.status == AnimationStatus.reverse)) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _cleanReferralValue(dynamic value) {
    final String text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  String _readPendingReferralCode(PsValueHolder psValueHolder) {
    final String fromValueHolder = _cleanReferralValue(
      psValueHolder.pendingReferralCode,
    );
    if (fromValueHolder.isNotEmpty) return fromValueHolder;

    try {
      return _cleanReferralValue(
        PsSharedPreferences.instance.getPendingReferralCode(),
      );
    } catch (_) {
      return '';
    }
  }

  Future<void> _persistReferralDataFromUser(ps_user.User user) async {
    final String referralCode = _cleanReferralValue(user.referralCode);
    final String referredByUserId = _cleanReferralValue(user.referredByUserId);
    final String referredByCode = _cleanReferralValue(user.referredByCode);
    final String referralRegisteredAt =
    _cleanReferralValue(user.referralRegisteredAt);

    if (referralCode.isEmpty &&
        referredByUserId.isEmpty &&
        referredByCode.isEmpty &&
        referralRegisteredAt.isEmpty) {
      return;
    }

    try {
      await PsSharedPreferences.instance.replaceReferralData(
        referralCode: referralCode.isEmpty ? null : referralCode,
        referredByUserId: referredByUserId.isEmpty ? null : referredByUserId,
        referredByCode: referredByCode.isEmpty ? null : referredByCode,
        referralRegisteredAt:
        referralRegisteredAt.isEmpty ? null : referralRegisteredAt,
      );
    } catch (e) {
    }
  }

  Future<void> _pickProfileImage() async {
    FocusScope.of(context).unfocus();

    try {
      final XFile? picked = await _profileImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 900,
        maxHeight: 900,
      );

      if (picked == null || !mounted) return;

      setState(() {
        _selectedProfileImageFile = File(picked.path);
      });
    } catch (e) {
      _showSnack('لم نتمكن من اختيار الصورة، حاول مرة أخرى');
    }
  }

  void _removeProfileImage() {
    if (!mounted) return;
    setState(() => _selectedProfileImageFile = null);
  }

  void _showOtpSendingSnack(BuildContext context) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _otpSendingSnack = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: <Widget>[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Utils.getString(context, 'login__snack_otp_sending'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hideOtpSendingSnack(BuildContext context) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _otpSendingSnack = null;
  }

  String _normalizeEgyptPhone(String input) {
    String phone = input.trim();

    const Map<String, String> digitMap = <String, String>{
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };

    digitMap.forEach((String source, String target) {
      phone = phone.replaceAll(source, target);
    });

    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (phone.contains('+') && !phone.startsWith('+')) {
      phone = phone.replaceAll('+', '');
    }

    if (phone.startsWith('00')) {
      phone = '+${phone.substring(2)}';
    }

    if (phone.startsWith('0')) {
      phone = '+20${phone.substring(1)}';
    }

    if (phone.length == 10 && phone.startsWith('1')) {
      phone = '+20$phone';
    }

    if (phone.startsWith('20')) {
      phone = '+$phone';
    }

    return phone;
  }


  /// Firebase needs E.164 format (+2010xxxxxxxx), but the backend database
  /// already stores Egyptian mobile numbers in local format (010xxxxxxxx).
  /// Keep DB/API user_phone normalized to local format to avoid duplicate users.
  String _toEgyptLocalPhone(String input) {
    String phone = input.trim();

    const Map<String, String> digitMap = <String, String>{
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };

    digitMap.forEach((String source, String target) {
      phone = phone.replaceAll(source, target);
    });

    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (phone.contains('+') && !phone.startsWith('+')) {
      phone = phone.replaceAll('+', '');
    }

    if (phone.startsWith('+20')) {
      return '0${phone.substring(3)}';
    }

    if (phone.startsWith('0020')) {
      return '0${phone.substring(4)}';
    }

    if (phone.startsWith('20')) {
      return '0${phone.substring(2)}';
    }

    if (phone.length == 10 && phone.startsWith('1')) {
      return '0$phone';
    }

    return phone;
  }

  bool _isValidEgyptMobile(String phoneNumber) {
    return RegExp(r'^\+201[0125]\d{8}$').hasMatch(phoneNumber);
  }

  void _startOtpCooldown([int seconds = 60]) {
    _resendTimer?.cancel();

    if (!mounted) return;
    setState(() => _resendSecondsLeft = seconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
        return;
      }

      setState(() => _resendSecondsLeft -= 1);
    });
  }

  String _phoneAuthFailureMessage(
      BuildContext context,
      fb_auth.FirebaseAuthException e,
      ) {
    if (e.code == 'invalid-phone-number') {
      return Utils.getString(context, 'login__error_otp_send_invalid_phone');
    }

    if (e.code == 'too-many-requests') {
      return Utils.getString(context, 'login__error_otp_send_too_many_requests');
    }


    return 'فشل إرسال الكود برجاء المحاوله فى وقت اخر ';
  }

  // -------------------- Firebase OTP --------------------

  Future<void> _sendOtp(BuildContext context, UserProvider provider) async {
    FocusScope.of(context).unfocus();
    if (_isSendingOtp) return;

    final String rawPhoneNumber = _phoneController.text.trim();
    final String phoneNumber = _normalizeEgyptPhone(rawPhoneNumber);

    if (rawPhoneNumber.isEmpty) {
      _showSnack(Utils.getString(context, 'login__error_empty_phone'));
      return;
    }

    if (!_isValidEgyptMobile(phoneNumber)) {
      _showSnack('اكتب رقم موبايل مصري صحيح مثل 010xxxxxxxx، وسيتم تحويله تلقائيًا إلى +20.');
      return;
    }

    if (_resendSecondsLeft > 0) {
      _showSnack('انتظر $_resendSecondsLeft ثانية قبل طلب كود جديد.');
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _shouldAskName = true;
    });

    _showOtpSendingSnack(context);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId) {
          _hideOtpSendingSnack(context);

          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
          });

          _startOtpCooldown();
          _showSnack(Utils.getString(context, 'login__snack_otp_sent'));
        },
        onVerificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          if (credential.smsCode != null) {
            _otpController.text = credential.smsCode!;
          }

          if (mounted) setState(() => _isVerifying = true);

          try {
            await _authService.signInWithCredential(credential);
            await _onLoginSuccess(context, provider);
          } catch (e) {
            _showSnack(Utils.getString(context, 'login__error_auto_signin'));
          } finally {
            if (mounted) setState(() => _isVerifying = false);
          }
        },
        onVerificationFailed: (fb_auth.FirebaseAuthException e) {
          _hideOtpSendingSnack(context);


          _showSnack(_phoneAuthFailureMessage(context, e));
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {

      _hideOtpSendingSnack(context);
      _showSnack(Utils.getString(context, 'login__error_otp_send_generic'));
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _verifyOtp(BuildContext context, UserProvider provider) async {
    if (_isVerifying) return;

    if (_verificationId == null) {
      _showSnack(Utils.getString(context, 'login__error_need_send_otp_first'));
      return;
    }

    final String code = _otpController.text.trim();
    if (code.length < 6) {
      _showSnack(Utils.getString(context, 'login__error_short_otp'));
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final fb_auth.PhoneAuthCredential credential =
      fb_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await _authService.signInWithCredential(credential);
      await _onLoginSuccess(context, provider);
    } on fb_auth.FirebaseAuthException catch (e) {
      String msg = Utils.getString(context, 'login__error_verify_failed');
      if (e.code == 'invalid-verification-code') {
        msg = Utils.getString(context, 'login__error_invalid_code');
      }
      _showSnack(msg);
    } catch (e) {
      _showSnack(Utils.getString(context, 'login__error_verify_generic'));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // -------------------- Backend login + navigation --------------------

  Future<void> _onLoginSuccess(BuildContext context, UserProvider provider) async {
    try {
      final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        _showSnack(Utils.getString(context, 'login__error_session_not_found'));
        return;
      }

      final SearchProvider sp = context.read<SearchProvider>();
      final PsValueHolder psValueHolder =
      Provider.of<PsValueHolder>(context, listen: false);

      final String firebasePhoneNumber = _phoneController.text.trim().isNotEmpty
          ? _normalizeEgyptPhone(_phoneController.text)
          : (firebaseUser.phoneNumber ?? '');

      final String phoneNumber = _toEgyptLocalPhone(firebasePhoneNumber);

      final bool isConnected = await Utils.checkInternetConnectivity();
      if (!isConnected) {
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

      final String enteredName = _nameController.text.trim();

      final PhoneLoginParameterHolder phoneLoginParameterHolder =
      PhoneLoginParameterHolder(
        phoneId: firebaseUser.uid,
        userName: enteredName.isEmpty ? null : enteredName,
        userPhone: phoneNumber,
        deviceToken: provider.psValueHolder!.deviceToken,
      );

      final Map<dynamic, dynamic> phoneLoginMap =
      phoneLoginParameterHolder.toMap();

      final String pendingReferralCode = _readPendingReferralCode(psValueHolder);

      if (pendingReferralCode.isNotEmpty) {
        phoneLoginMap['pending_referral_code'] = pendingReferralCode;
        phoneLoginMap['referral_code'] = pendingReferralCode;
        phoneLoginMap['referred_by_code'] = pendingReferralCode;
        phoneLoginMap['ref'] = pendingReferralCode;
      }

      final PsResource<ps_user.User> apiStatus = await provider.postPhoneLogin(
        phoneLoginMap,
        context,
      );

      if (apiStatus.data != null) {
        final ps_user.User user = apiStatus.data!;
        final String userId = user.userId ?? '';

        if (userId.isEmpty) {
          _showSnack(Utils.getString(context, 'login__error_complete_login'));
          return;
        }

        await _persistReferralDataFromUser(user);

        if (_cleanReferralValue(user.referredByCode).isNotEmpty ||
            _cleanReferralValue(user.referredByUserId).isNotEmpty) {
          try {
            await PsSharedPreferences.instance.clearPendingReferralCode();
          } catch (e) {
          }
        }

        final String serverName = (user.userName ?? '').trim();
        final bool isExistingUser = serverName.isNotEmpty;

        if (mounted) {
          setState(() {
            _shouldAskName = !isExistingUser;
            _codeSent = true;
          });
        }

        if (!isExistingUser) {
          String finalName = enteredName;

          if (finalName.isEmpty || finalName.length < 2) {
            finalName = await _askUserNameDialog(context) ?? '';
          }

          if (finalName.isEmpty || finalName.length < 2) {
            _showSnack(Utils.getString(context, 'login__error_name_required'));
            return;
          }

          _nameController.text = finalName;

          await _updateUserNameOnServer(
            context,
            provider,
            userId,
            finalName,
            phoneNumber,
          );
        }

        await _updateUserProfilePhotoOnServer(
          context,
          provider,
          userId,
          phoneNumber,
          userName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : serverName,
        );

        await provider.replaceVerifyUserData('', '', '', '');
        await provider.replaceLoginUserId(userId);
        await provider.replaceLoginUserName(
          (apiStatus.data!.userName ?? _nameController.text.trim()),
        );

        await _updateUserGenderAgeOnServer(context, provider, userId);

        if (widget.onProfileSelected != null) {
          await widget.onProfileSelected!(userId);
          return;
        }

        // ✅ Ensure local default interests exist before syncing to server.
        // This also fixes stale hasFavCategories=true with an empty local list.
        await DefaultInterestsBootstrapper.ensureDefaultInterests(
          context: context,
          valueHolder: psValueHolder,
          force: false,
          syncToServerIfLoggedIn: false,
          source: 'login_after_success_ensure',
        );
        await _restoreLocalInterestsBeforeLoginSync(context);
        await _syncGuestPreferencesToServer(context, userId);
        await DefaultInterestsBootstrapper.syncLocalInterestsToServerIfLoggedIn(
          context: context,
          valueHolder: psValueHolder,
          source: 'login_after_success_sync',
        );
        await syncPendingFollowsAfterLogin(context, sp);

        await HomeProvider.of(context, listen: false)
            .subscribeAfterLogin(userId, context);

        await HomeProvider.of(context, listen: false)
            .pullSelectedSubFromServer(userId: userId, cacheToLocal: true);

        void goToLanguageOrHome() {
          if (psValueHolder.isLanguageConfig == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutePaths.languagesetting,
                  (Route<dynamic> route) => false,
            );
          } else {
            if (psValueHolder.locationId != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutePaths.home,
                    (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutePaths.itemLocationList,
                    (Route<dynamic> route) => false,
              );
            }
          }
        }

        goToLanguageOrHome();
      } else {
        showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(message: apiStatus.message);
          },
        );
      }
    } catch (e) {
      _showSnack(Utils.getString(context, 'login__error_complete_login'));
    }
  }

  Future<String?> _askUserNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    bool saving = false;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) {
        return StatefulBuilder(
          builder: (BuildContext dialogCtx, void Function(void Function()) setS) {
            Future<void> onSave() async {
              final String name = nameController.text.trim();

              if (name.isEmpty) {
                _showSnack(Utils.getString(context, 'login__error_name_required'));
                return;
              }
              if (name.length < 2) {
                _showSnack(Utils.getString(context, 'login__error_invalid_name'));
                return;
              }

              setS(() => saving = true);
              Navigator.of(dialogCtx).pop(name);
            }

            return AlertDialog(
              title: Text(Utils.getString(context, 'login__new_user_title')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TaapdeelTextField(
                    controller: nameController,
                    label: Utils.getString(context, 'login__name_label'),
                    hint: Utils.getString(context, 'login__name_hint'),
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(dialogCtx).pop(null),
                  child: Text(Utils.getString(context, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: saving ? null : onSave,
                  child: saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(Utils.getString(context, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateUserNameOnServer(
      BuildContext context,
      UserProvider provider,
      String userId,
      String name,
      String phoneNumber,
      ) async {
    try {
      String phone = phoneNumber.trim();
      if (phone.isEmpty) {
        final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
        phone = _toEgyptLocalPhone(firebaseUser?.phoneNumber ?? '');
      }

      if (phone.isEmpty) {
        return;
      }

      final Map<String, dynamic> body = <String, dynamic>{
        'user_id': userId,
        'user_name': name,
        'user_phone': phone,
      };

      final PsResource<ps_user.User> res = await provider.postProfileUpdate(body);

      if (res.status != PsStatus.SUCCESS) {
      }
    } catch (e) {
    }
  }

  Future<void> _updateUserProfilePhotoOnServer(
      BuildContext context,
      UserProvider provider,
      String userId,
      String phoneNumber, {
        String? userName,
      }) async {
    final File? imageFile = _selectedProfileImageFile;
    if (imageFile == null) return;

    try {
      String phone = phoneNumber.trim();
      if (phone.isEmpty) {
        final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
        phone = _toEgyptLocalPhone(firebaseUser?.phoneNumber ?? '');
      }

      if (phone.isEmpty) {
        return;
      }

      final Map<String, dynamic> body = <String, dynamic>{
        'user_id': userId,
        'user_phone': phone,
        if ((userName ?? '').trim().isNotEmpty) 'user_name': userName!.trim(),
        'user_profile_photo': imageFile,
      };

      final PsResource<ps_user.User> res = await provider.postProfileUpdate(body);

      if (res.status != PsStatus.SUCCESS) {
      }
    } catch (e) {
    }
  }

  Future<void> _restoreLocalInterestsBeforeLoginSync(
      BuildContext context,
      ) async {
    try {
      final HomeProvider homeProvider = HomeProvider.of(context, listen: false);

      try {
        await (homeProvider as dynamic).loadList();
      } catch (_) {}
      try {
        await (homeProvider as dynamic).loadSelectedList();
      } catch (_) {}
      try {
        await (homeProvider as dynamic).loadSavedList();
      } catch (_) {}
      try {
        await (homeProvider as dynamic).getSavedList();
      } catch (_) {}
      try {
        await (homeProvider as dynamic).getList();
      } catch (_) {}

      if (homeProvider.retrieveList().isNotEmpty) {
        homeProvider.saveList();
        await PsSharedPreferences.instance.replaceHasFavCategories(true);
      }
    } catch (e) {
    }
  }

  Future<void> _syncGuestPreferencesToServer(
      BuildContext context,
      String userId,
      ) async {
    try {
      final HomeProvider homeProvider = HomeProvider.of(context, listen: false);
      final List<dynamic> selectedList = homeProvider.retrieveList();

      if (selectedList.isEmpty) return;

      final SubCategoryRepository subRepo =
      Provider.of<SubCategoryRepository>(context, listen: false);
      final PsValueHolder psValueHolder =
      Provider.of<PsValueHolder>(context, listen: false);

      final Map<String, List<String>> byCategory = <String, List<String>>{};

      for (final dynamic item in selectedList) {
        if (item is SubCategory) {
          final String? catId = item.catId;
          final String? subId = item.id;

          if (catId == null ||
              catId.isEmpty ||
              subId == null ||
              subId.isEmpty) {
            continue;
          }

          byCategory.putIfAbsent(catId, () => <String>[]);
          byCategory[catId]!.add('${subId}_MB');
        }
      }

      if (byCategory.isEmpty) return;

      final SubCategoryProvider tempProvider = SubCategoryProvider(
        repo: subRepo,
        psValueHolder: psValueHolder,
      );

      for (final MapEntry<String, List<String>> entry in byCategory.entries) {
        final SubscribeParameterHolder holder = SubscribeParameterHolder(
          userId: userId,
          catId: entry.key,
          selectedsubCatId: entry.value,
        );

        final PsResource<ApiStatus> res =
        await tempProvider.postSubCategorySubscribe(holder.toMap());

        if (res.status != PsStatus.SUCCESS) {
        }
      }
    } catch (e) {
    }
  }

  Future<void> syncPendingFollowsAfterLogin(
      BuildContext context,
      SearchProvider sp,
      ) async {
    final String uid = PendingFollowsCache.currentLoginUserId().trim();

    if (uid.isEmpty || uid == 'nologinuser') return;

    final Map<String, int> pending = PendingFollowsCache.read();
    if (pending.isEmpty) return;

    int successCount = 0;

    for (final MapEntry<String, int> entry in pending.entries) {
      final String id = entry.key.trim();
      final int relationId = entry.value;

      if (id.isEmpty || relationId <= 0) continue;

      try {
        await sp.followUser(
          userId: id,
          relationType: relationId,
        );
        successCount++;
      } catch (_) {}
    }

    await PendingFollowsCache.clear();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          successCount > 0
              ? 'تم تفعيل المتابعة تلقائيًا ($successCount)'
              : 'تم تسجيل الدخول',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateUserGenderAgeOnServer(
      BuildContext context,
      UserProvider provider,
      String userId,
      ) async {
    try {
      final PsValueHolder psValueHolder =
      Provider.of<PsValueHolder>(context, listen: false);

      final String? gender = (psValueHolder as dynamic).userGender as String?;
      final String? age = (psValueHolder as dynamic).userAgeRange as String?;
      final String name = _nameController.text.trim();


      if ((gender == null || gender.isEmpty) && (age == null || age.isEmpty)) {
        return;
      }

      String phone = _toEgyptLocalPhone(_phoneController.text);
      if (phone.isEmpty) {
        final fb_auth.User? firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
        phone = _toEgyptLocalPhone(firebaseUser?.phoneNumber ?? '');
      }

      if (phone.isEmpty) {
        return;
      }

      final Map<String, dynamic> body = <String, dynamic>{
        'user_id': userId,
        'user_age': age ?? '',
        'user_gender': gender ?? '',
        'user_name': name,
        'user_phone': phone,
      };

      final PsResource<ps_user.User> res = await provider.postProfileUpdate(body);

      if (res.status != PsStatus.SUCCESS) {
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepo = Provider.of<UserRepository>(context);
    final PsValueHolder psValueHolder = Provider.of<PsValueHolder>(context);

    return ChangeNotifierProvider<UserProvider>(
      lazy: false,
      create: (BuildContext context) {
        return UserProvider(repo: userRepo, psValueHolder: psValueHolder);
      },
      child: Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider provider, Widget? child) {
          final Widget content = _buildMainUI(context, provider);

          if (widget.animationController != null && widget.animation != null) {
            return AnimatedBuilder(
              animation: widget.animationController!,
              child: content,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: widget.animation!,
                  child: Transform(
                    transform: Matrix4.translationValues(
                      0.0,
                      100 * (1.0 - widget.animation!.value),
                      0.0,
                    ),
                    child: child,
                  ),
                );
              },
            );
          }

          return content;
        },
      ),
    );
  }

  Widget _buildMainUI(BuildContext context, UserProvider provider) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PsDimens.space16,
            vertical: PsDimens.space24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TaapdeelSectionHeader(
                    title: Utils.getString(context, 'login__title'),
                    subtitle: Utils.getString(context, 'login__subtitle'),
                    leadingIcon: Icons.mobile_friendly_rounded,
                  ),
                  TaapdeelCard(
                    title: null,
                    subtitle: null,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _ProfilePhotoPicker(
                          imageFile: _selectedProfileImageFile,
                          onPick: _pickProfileImage,
                          onRemove: _removeProfileImage,
                        ),
                        const SizedBox(height: PsDimens.space20),
                        Text(
                          Utils.getString(context, 'login__phone_label'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: PsDimens.space8),
                        TaapdeelTextField(
                          controller: _phoneController,
                          label: Utils.getString(context, 'login__phone_label'),
                          hint: Utils.getString(context, 'login__phone_hint'),
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9٠-٩۰-۹+\s\-\(\)]'),
                            ),
                            LengthLimitingTextInputFormatter(18),
                          ],
                          onSubmitted: (_) {
                            if (!_codeSent && !_isSendingOtp) {
                              _sendOtp(context, provider);
                            }
                          },
                        ),
                        const SizedBox(height: PsDimens.space24),
                        if (_codeSent) ...<Widget>[
                          if (_shouldAskName) ...<Widget>[
                            Text(
                              Utils.getString(context, 'login__otp_label'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: PsDimens.space8),
                            TaapdeelTextField(
                              controller: _otpController,
                              label: Utils.getString(context, 'login__otp_label'),
                              hint: Utils.getString(context, 'login__otp_hint'),
                              prefixIcon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                            ),
                            const SizedBox(height: PsDimens.space24),
                            Text(
                              Utils.getString(context, 'login__name_label'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: PsDimens.space8),
                            TaapdeelTextField(
                              controller: _nameController,
                              label: Utils.getString(context, 'login__name_label'),
                              hint: Utils.getString(context, 'login__name_hint'),
                              prefixIcon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: PsDimens.space16),
                          ],
                          TaapdeelButton(
                            label: _isVerifying
                                ? Utils.getString(context, 'login__btn_verifying')
                                : Utils.getString(context, 'login__btn_verify_code'),
                            onPressed: _isVerifying
                                ? null
                                : () => _verifyOtp(context, provider),
                          ),
                          const SizedBox(height: PsDimens.space12),
                          Align(
                            alignment: Alignment.center,
                            child: TaapdeelButton(
                              label: _resendSecondsLeft > 0
                                  ? 'إعادة الإرسال بعد $_resendSecondsLeft ث'
                                  : Utils.getString(
                                context,
                                'login__btn_resend_code',
                              ),
                              onPressed:
                              (_isSendingOtp || _resendSecondsLeft > 0)
                                  ? null
                                  : () => _sendOtp(context, provider),
                              isPrimary: false,
                              outlined: true,
                              isExpanded: false,
                            ),
                          ),
                        ] else ...<Widget>[
                          TaapdeelButton(
                            label: _isSendingOtp
                                ? Utils.getString(context, 'login__btn_sending_code')
                                : Utils.getString(context, 'login__btn_send_code'),
                            onPressed: _isSendingOtp
                                ? null
                                : () => _sendOtp(context, provider),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoPicker extends StatelessWidget {
  const _ProfilePhotoPicker({
    required this.imageFile,
    required this.onPick,
    required this.onRemove,
  });

  final File? imageFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasImage = imageFile != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF24A9C4).withOpacity(0.18),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasImage
                      ? null
                      : const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: <Color>[
                      Color(0xFF0C587A),
                      Color(0xFF24A9C4),
                    ],
                  ),
                  image: hasImage
                      ? DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  )
                      : null,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF0C587A).withOpacity(0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: hasImage
                    ? null
                    : const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onPick,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF24A9C4).withOpacity(0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF0C587A),
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'صورة البروفايل',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF043757),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasImage
                      ? 'تم اختيار الصورة، وسيتم حفظها بعد تسجيل الدخول'
                      : 'اختيار الصورة اختياري ويمكن تغييره لاحقًا',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.35,
                    color: Colors.black.withOpacity(0.58),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _ProfilePhotoMiniButton(
                      label: hasImage ? 'تغيير الصورة' : 'اختار صورة',
                      icon: Icons.add_a_photo_rounded,
                      onTap: onPick,
                      primary: true,
                    ),
                    if (hasImage)
                      _ProfilePhotoMiniButton(
                        label: 'حذف',
                        icon: Icons.close_rounded,
                        onTap: onRemove,
                        primary: false,
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

class _ProfilePhotoMiniButton extends StatelessWidget {
  const _ProfilePhotoMiniButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color bg = primary ? const Color(0xFF0C587A) : Colors.white;
    final Color fg = primary ? Colors.white : const Color(0xFF0C587A);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: primary
                  ? Colors.transparent
                  : const Color(0xFF0C587A).withOpacity(0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
