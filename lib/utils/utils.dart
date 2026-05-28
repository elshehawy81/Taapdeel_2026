import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/seller_chat_history_list_provider.dart';
import 'package:taapdeel/provider/common/notification_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/ui/chat/list/chat_list_view.dart';
import 'package:taapdeel/ui/common/dialog/chat_noti_dialog.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/chat_history_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/noti_register_holder.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/chat/user_unread_message_provider.dart';
import '../ui/common/dialog/noti_dialog.dart';

mixin Utils {
  // --------------------------------------------------------------------------
  // Global flags
  // --------------------------------------------------------------------------
  static bool isReachChatView = false;
  static bool isNotiFromToolbar = false;

  static List<CameraDescription> cameras = <CameraDescription>[];

  // ✅ Guard against re-registering FCM listeners (prevents duplicated listeners + jank)
  static bool _fcmConfigured = false;

  // --------------------------------------------------------------------------
  // Localization / simple helpers
  // --------------------------------------------------------------------------
  static String getString(BuildContext context, String? key) {
    if (key == null || key.isEmpty) {
      return '';
    }
    return tr(key);
  }

  static bool checkIsChatView() => isReachChatView;

  static bool isShowNotiFromToolbar() => isNotiFromToolbar;

  static bool? checkEmailFormat(String email) {
    if (email.isEmpty) {
      return null;
    }
    final bool emailFormat = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$",
    ).hasMatch(email);
    return emailFormat;
  }

  // --------------------------------------------------------------------------
  // Debug print with timing
  // --------------------------------------------------------------------------
  static DateTime? previous;
  static void psPrint(String? msg) {
    final DateTime now = DateTime.now();
    int diffMs = 0;

    if (previous == null) {
      previous = now;
    } else {
      diffMs = now.difference(previous!).inMilliseconds;
      previous = now;
    }

    // ignore: avoid_print
    print('$now ($diffMs ms) - $msg');
  }

  // --------------------------------------------------------------------------
  // Price formatting helpers
  // --------------------------------------------------------------------------
  static String getPriceFormat(String price, String priceFormat) {
    return price;
  }

  static String getChatPriceFormat(String message, String priceFormat) {
    try {
      final String currencySymbol = message.split(' ')[0];
      final String price = getPriceFormat(message.split(' ')[1], priceFormat);
      return '$currencySymbol  $price';
    } catch (_) {
      return message;
    }
  }

  static String splitMessage(String message) {
    try {
      return message.split(' ')[1];
    } catch (_) {
      return message;
    }
  }

  static String getPriceTwoDecimal(String price) {
    return PsConst.priceTwoDecimalFormat.format(double.parse(price));
  }

  // --------------------------------------------------------------------------
  // Theme helpers
  // --------------------------------------------------------------------------
  static bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static Brightness getBrightnessForAppBar(BuildContext context) {
    return Brightness.dark;
  }

  // --------------------------------------------------------------------------
  // Firebase timestamp / time utilities
  // --------------------------------------------------------------------------
  static Map<String, String> getTimeStamp() {
    return ServerValue.timestamp;
  }

  static int getTimeStampDividedByOneThousand(DateTime dateTime) {
    final double dividedByOneThousand = dateTime.millisecondsSinceEpoch / 1000;
    return dividedByOneThousand.round();
  }

  static DateTime getDateOnlyFromTimeStamp(int timeStamp) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd', 'en_US');
    final DateTime datetimeMessage =
    DateTime.fromMillisecondsSinceEpoch(timeStamp, isUtc: true);
    final String s = formatter.format(datetimeMessage);
    return DateTime.parse(s);
  }

  static String convertTimeStampToDate(int? timeStamp) {
    if (timeStamp == null) {
      return '';
    }
    final DateTime dateTimeUtc =
    DateTime.fromMillisecondsSinceEpoch(timeStamp, isUtc: true);
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();
    final DateFormat format = DateFormat.yMMMMd();
    return format.format(dateTimeLocal);
  }

  static String convertTimeStampToTime(int? timeStamp) {
    if (timeStamp == null) {
      return '';
    }
    final DateTime dateTimeUtc =
    DateTime.fromMillisecondsSinceEpoch(timeStamp, isUtc: true);
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();
    final DateFormat format = DateFormat.jm();
    return format.format(dateTimeLocal);
  }

  static String getTimeString() {
    final DateTime dateTime = DateTime.now();
    final DateFormat format = DateFormat.Hms();
    return format.format(dateTime);
  }

  static String getDateFormat(String? dateTime, String dateFormat) {
    final DateTime date = DateTime.parse(dateTime!);
    return DateFormat(dateFormat).format(date);
  }

  static String changeTimeStampToStandardDateTimeFormat(String? timeStamp) {
    if (timeStamp == null || timeStamp.isEmpty) {
      return '';
    }
    final String standardDateTime =
    DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp) * 1000)
        .toString();
    return changeDateTimeStandardFormat(standardDateTime);
  }

  static String changeDateTimeStandardFormat(String selectedDateTime) {
    final List<String> parts = selectedDateTime.split(' ');
    final String ymd = parts[0];
    final String hmsWithMs = parts[1];

    final List<String> ymdParts = ymd.split('-');
    final String yyyy = ymdParts[0];
    final String mm = ymdParts[1];
    final String dd = ymdParts[2];

    final String hms = hmsWithMs.split('.')[0];

    return '$dd-$mm-$yyyy $hms';
  }

  // --------------------------------------------------------------------------
  // Ads helpers
  // --------------------------------------------------------------------------


  // --------------------------------------------------------------------------
  // Image helpers (compression, from camera / assets)
  // --------------------------------------------------------------------------

  static const int _minProfessionalUploadSize = 1600;
  static const int _defaultProfessionalQuality = 95;

  static int _normalizeTargetSize(int imageSize) {
    if (imageSize <= 0) {
      return _minProfessionalUploadSize;
    }
    return imageSize < _minProfessionalUploadSize
        ? _minProfessionalUploadSize
        : imageSize;
  }

  static String _buildCompressedTargetPath(String originalPath) {
    final int dotIndex = originalPath.lastIndexOf('.');
    if (dotIndex == -1) {
      return '${originalPath}_compressed.jpg';
    }
    return '${originalPath.substring(0, dotIndex)}_compressed.jpg';
  }

  static Future<File?> getImageFileFromAssets(
      XFile xFile,
      int imageSize,
      ) async {
    try {
      final Uint8List bytes = await xFile.readAsBytes();

      final Directory tempDir = await getTemporaryDirectory();
      final Directory tempFolder =
      Directory('${tempDir.path}/${PsConfig.tmpImageFolderName}');

      if (!tempFolder.existsSync()) {
        await tempFolder.create(recursive: true);
      }

      final String safeName = xFile.name.isNotEmpty
          ? xFile.name
          : 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File originalFile = File('${tempFolder.path}/$safeName');
      await originalFile.writeAsBytes(bytes, flush: true);

      psPrint('Temp original image path: ${originalFile.path}');

      final int targetSize = _normalizeTargetSize(imageSize);

      final File compressed = await _compressImageFile(
        originalFile,
        minWidth: targetSize,
        minHeight: targetSize,
        quality: _defaultProfessionalQuality,
      );

      psPrint('Temp final image path: ${compressed.path}');
      return compressed;
    } catch (e) {
      psPrint('getImageFileFromAssets error: $e');
      return null;
    }
  }

  static Future<File?> getImageFileFromCameraImagePath(
      String? imagePath,
      int imageSize,
      ) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final bool status = await Utils.requestWritePermission();
    if (!status) {
      Fluttertoast.showToast(
        msg: 'We don\'t have permission to read/write images.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
      );
      return null;
    }

    try {
      final File file = File(imagePath);
      final int targetSize = _normalizeTargetSize(imageSize);

      final File compressed = await _compressImageFile(
        file,
        minWidth: targetSize,
        minHeight: targetSize,
        quality: _defaultProfessionalQuality,
      );

      psPrint('Camera final image path: ${compressed.path}');
      return compressed;
    } catch (e) {
      psPrint('getImageFileFromCameraImagePath error: $e');
      return null;
    }
  }

  static Future<File> _compressImageFile(
      File file, {
        int minWidth = 1600,
        int minHeight = 1600,
        int quality = _defaultProfessionalQuality,
      }) async {
    try {
      final String targetPath = _buildCompressedTargetPath(file.path);

      final List<int>? result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: true,
        autoCorrectionAngle: true,
      );

      if (result == null || result.isEmpty) {
        return file;
      }

      final File compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(result, flush: true);
      return compressedFile;
    } catch (e) {
      psPrint('_compressImageFile error: $e');
      return file;
    }
  }

  static Future<File?> compressImagePath(
      String? imagePath, {
        int minWidth = 1600,
        int minHeight = 1600,
        int quality = _defaultProfessionalQuality,
      }) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      final String targetPath = _buildCompressedTargetPath(imagePath);

      final List<int>? result = await FlutterImageCompress.compressWithFile(
        imagePath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: true,
        autoCorrectionAngle: true,
      );

      if (result == null || result.isEmpty) {
        return File(imagePath);
      }

      final File compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(result, flush: true);
      return compressedFile;
    } catch (e) {
      psPrint('compressImagePath error: $e');
      return File(imagePath);
    }
  }

  // --------------------------------------------------------------------------
  // Color helpers
  // --------------------------------------------------------------------------
  static String convertColorToString(Color? color) {
    if (color == null) {
      return '#000000';
    }

    final int value = color.value;
    final int r = (value >> 16) & 0xFF;
    final int g = (value >> 8) & 0xFF;
    final int b = value & 0xFF;

    final String rs = r.toRadixString(16).padLeft(2, '0').toUpperCase();
    final String gs = g.toRadixString(16).padLeft(2, '0').toUpperCase();
    final String bs = b.toRadixString(16).padLeft(2, '0').toUpperCase();

    return '#$rs$gs$bs';
  }

  // --------------------------------------------------------------------------
  // Permissions / connectivity
  // --------------------------------------------------------------------------
  static Future<bool> requestWritePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> checkInternetConnectivity() async {
    final List<ConnectivityResult> results =
    await Connectivity().checkConnectivity();

    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      psPrint('No Connection');
      return false;
    }

    return true;
  }

  // --------------------------------------------------------------------------
  // Store / external links
  // --------------------------------------------------------------------------
  static Future<void> launchURL() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Uri url = Uri.parse(
      'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> launchAppStoreURL({
    String? iOSAppId,
    bool writeReview = false,
  }) async {
    // Intentionally left blank – ready for iOS App Store review logic if needed.
  }

  // --------------------------------------------------------------------------
  // Auth / navigation helpers
  // --------------------------------------------------------------------------
  static Future<void> navigateOnUserVerificationView(
      dynamic provider,
      BuildContext context,
      VoidCallback onLoginSuccess,
      ) async {
    provider.psValueHolder = Provider.of<PsValueHolder>(context, listen: false);

    if (provider == null ||
        provider.psValueHolder.userIdToVerify == null ||
        provider.psValueHolder.userIdToVerify!.isEmpty) {
      if (provider == null ||
          provider.psValueHolder == null ||
          provider.psValueHolder.loginUserId == null ||
          provider.psValueHolder.loginUserId!.isEmpty) {
        final dynamic returnData = await Navigator.pushNamed(
          context,
          RoutePaths.login_container,
        );

        if (returnData != null && returnData is User) {
          final User user = returnData;
          provider.psValueHolder =
              Provider.of<PsValueHolder>(context, listen: false);
          provider.psValueHolder.loginUserId = user.userId;
        }
      } else {
        onLoginSuccess();
      }
    } else {
      Navigator.pushNamed(
        context,
        RoutePaths.user_verify_email_container,
        arguments: provider.psValueHolder.userIdToVerify,
      );
    }
  }

  static String sortingUserId(String loginUserId, String itemAddedUserId) {
    if (loginUserId.compareTo(itemAddedUserId) == 1) {
      return '${itemAddedUserId}_$loginUserId';
    } else if (loginUserId.compareTo(itemAddedUserId) == -1) {
      return '${loginUserId}_$itemAddedUserId';
    } else {
      return '${loginUserId}_$itemAddedUserId';
    }
  }

  static String? checkUserLoginId(PsValueHolder psValueHolder) {
    if (psValueHolder.loginUserId == null ||
        psValueHolder.loginUserId!.isEmpty) {
      return 'nologinuser';
    } else {
      return psValueHolder.loginUserId;
    }
  }

  static Widget flightShuttleBuilder(
      BuildContext flightContext,
      Animation<double> animation,
      HeroFlightDirection flightDirection,
      BuildContext fromHeroContext,
      BuildContext toHeroContext,
      ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  // --------------------------------------------------------------------------
  // Apple sign in
  // --------------------------------------------------------------------------
  static int isAppleSignInAvailable = 0;

  static Future<void> checkAppleSignInAvailable() async {
    final bool isAvailable = await TheAppleSignIn.isAvailable();
    isAppleSignInAvailable = isAvailable ? 1 : 2;
  }

  // --------------------------------------------------------------------------
  // FCM topic subscriptions
  // --------------------------------------------------------------------------
  static void subscribeToTopic(bool isEnable) {
    if (isEnable) {
      if (Platform.isIOS) {
        FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      FirebaseMessaging.instance.subscribeToTopic('broadcast');
    }
  }

  static Future<void> saveDeviceToken(
      FirebaseMessaging fcm,
      NotificationProvider notificationProvider,
      ) async {
    final String? fcmToken = await fcm.getToken();
    if (fcmToken != null) {
      await notificationProvider.replaceNotiToken(fcmToken);

      final NotiRegisterParameterHolder holder = NotiRegisterParameterHolder(
        platformName: PsConst.PLATFORM,
        deviceId: fcmToken,
        loginUserId: checkUserLoginId(notificationProvider.psValueHolder!),
      );

      psPrint('Token Key $fcmToken');

      await notificationProvider.rawRegisterNotiToken(holder.toMap());
    }
  }

  static void subscribeToModelTopics(List<String?> subcatList) {
    if (Platform.isIOS) {
      FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    for (final String? subCat in subcatList) {
      if (subCat != null && subCat.isNotEmpty) {
        FirebaseMessaging.instance.subscribeToTopic(subCat);
      }
    }
  }

  static void unSubsribeFromModelTopics(List<String?> subcatList) {
    for (final String? subCat in subcatList) {
      if (subCat != null && subCat.isNotEmpty) {
        FirebaseMessaging.instance.unsubscribeFromTopic(subCat);
      }
    }
  }

  // --------------------------------------------------------------------------
  // Notification dialogs
  // --------------------------------------------------------------------------
  static Future<void> _onSelectBroadCastNotification(
      BuildContext context,
      String? payload,
      ) async {
    showDialog<dynamic>(
      context: context,
      builder: (_) {
        return ChatNotiDialog(
          description: '$payload',
          leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
          rightButtonText: Utils.getString(context, 'chat_noti__open'),
          onAgreeTap: () {
            Navigator.pushNamed(
              context,
              RoutePaths.notiList,
            );
          },
        );
      },
    );
  }

  static Future<void> _onSelectReviewNotification(
      BuildContext context,
      String payload,
      String? userId,
      ) async {
    showDialog<dynamic>(
      context: context,
      builder: (_) {
        return ChatNotiDialog(
          description: payload,
          leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
          rightButtonText: Utils.getString(context, 'chat_noti__open'),
          onAgreeTap: () {
            Navigator.pushNamed(
              context,
              RoutePaths.ratingList,
              arguments: userId,
            );
          },
        );
      },
    );
  }

  static Future<void> _onSelectApprovalNotification(
      BuildContext context,
      String? payload,
      ) async {
    showDialog<dynamic>(
      context: context,
      builder: (_) {
        return NotiDialog(message: '$payload');
      },
    );
  }

  // --------------------------------------------------------------------------
  // ✅ FCM configuration (SAFE + ONCE)
  // --------------------------------------------------------------------------
  static void fcmConfigure(
      BuildContext context,
      FirebaseMessaging fcm,
      String? loginUserId,
      VoidCallback onMessageReceived,
      ) {
    if (_fcmConfigured) {
      onMessageReceived();
      return;
    }
    _fcmConfigured = true;

    if (Platform.isIOS) {
      fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    //FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? event) async {
      if (event != null) {
        final Map<String, dynamic> message = event.data;
        psPrint('onInitialMessage: $message');

        final String? notiMessage = _parseNotiMessage(message);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Utils.takeDataFromNoti(context, message, loginUserId);
          }
        });

        if (notiMessage != null) {
          await PsSharedPreferences.instance.replaceNotiMessage(notiMessage);
        }
      }
      onMessageReceived();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      final Map<String, dynamic> message = event.data;
      psPrint('onMessage: $message');

      final String? notiMessage = _parseNotiMessage(message);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Utils.takeDataFromNoti(context, message, loginUserId);
        }
      });

      if (notiMessage != null) {
        await PsSharedPreferences.instance.replaceNotiMessage(notiMessage);
      }
      onMessageReceived();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
      final Map<String, dynamic> message = event.data;
      psPrint('onMessageOpenedApp: $message');

      final String? notiMessage = _parseNotiMessage(message);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Utils.takeDataFromNoti(context, message, loginUserId);
        }
      });

      if (notiMessage != null) {
        await PsSharedPreferences.instance.replaceNotiMessage(notiMessage);
      }
      onMessageReceived();
    });
  }

  // --------------------------------------------------------------------------
  // ✅ Background handler
  // --------------------------------------------------------------------------
  @pragma('vm:entry-point')
  static Future<void> myBackgroundMessageHandler(RemoteMessage event) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: Platform.isIOS
            ? const FirebaseOptions(
          appId: PsConfig.iosGoogleAppId,
          messagingSenderId: PsConfig.iosGcmSenderId,
          databaseURL: PsConfig.iosDatabaseUrl,
          projectId: PsConfig.iosProjectId,
          apiKey: PsConfig.iosApiKey,
        )
            : const FirebaseOptions(
          appId: PsConfig.androidGoogleAppId,
          apiKey: PsConfig.androidApiKey,
          projectId: PsConfig.androidProjectId,
          messagingSenderId: PsConfig.androidGcmSenderId,
          databaseURL: PsConfig.androidDatabaseUrl,
        ),
      );
    }

    final Map<String, dynamic> message = event.data;

    psPrint('onBackgroundMessage: $message');
    final String? notiMessage = _parseNotiMessage(message);

    if (notiMessage != null) {
      await PsSharedPreferences.instance.replaceNotiMessage(notiMessage);
    }
  }

  static String? _parseNotiMessage(Map<String, dynamic> message) {
    if (message['message'] is String && (message['message'] as String).isNotEmpty) {
      return message['message'] as String;
    }

    final dynamic data = message['data'];
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    if (message['body'] is String && (message['body'] as String).isNotEmpty) {
      return message['body'] as String;
    }

    if (data is Map && data['body'] is String) {
      return data['body'] as String;
    }

    return null;
  }

  // --------------------------------------------------------------------------
  // Take data from notification (routing logic)
  // --------------------------------------------------------------------------
  static dynamic takeDataFromNoti(
      BuildContext context,
      Map<String, dynamic> message,
      String? loginUserId,
      ) {
    final UserRepository userRepository =
    Provider.of<UserRepository>(context, listen: false);
    final PsValueHolder psValueHolder =
    Provider.of<PsValueHolder>(context, listen: false);
    final UserProvider userProvider = UserProvider(
      repo: userRepository,
      psValueHolder: psValueHolder,
    );

    final dynamic dataPayload = message['notification'] ?? message;

    if (Platform.isAndroid) {
      final String? flag = message['flag'] ?? message['data']?['flag'];
      final String? notiMessage =
          message['message'] ?? message['data']?['message'];

      if (flag == 'broadcast' || flag == 'subcat_id') {
        _onSelectBroadCastNotification(context, notiMessage);
      } else if (flag == 'approval') {
        _onSelectApprovalNotification(context, notiMessage);
      } else if (flag == 'chat') {
        isNotiFromToolbar = true;

        final String? sellerId =
            message['seller_id'] ?? message['data']?['seller_id'];
        final String? buyerId =
            message['buyer_id'] ?? message['data']?['buyer_id'];
        final String? senderName =
            message['sender_name'] ?? message['data']?['sender_name'];
        final String? senderProflePhoto = message['sender_profle_photo'] ??
            message['data']?['sender_profle_photo'];
        final String? itemId = message['item_id'] ?? message['data']?['item_id'];

        if (userProvider.psValueHolder!.loginUserId != null &&
            userProvider.psValueHolder!.loginUserId!.isNotEmpty &&
            !isReachChatView) {
          _showChatNotification(
            context,
            notiMessage,
            sellerId,
            buyerId,
            senderName,
            senderProflePhoto,
            itemId,
            loginUserId,
          );
        }
      } else if (flag == 'review') {
        final String rating =
            message['rating'] ?? message['data']?['rating'] ?? '0';
        final String ratingMessage =
            Utils.getString(context, 'noti_message__text1') +
                rating.split('.')[0] +
                Utils.getString(context, 'noti_message__text2') +
                '\n"' +
                (notiMessage ?? '') +
                '"';
        _onSelectReviewNotification(
          context,
          ratingMessage,
          userProvider.psValueHolder!.loginUserId,
        );
      } else {
        _onSelectApprovalNotification(context, notiMessage);
      }
    } else if (Platform.isIOS) {
      final String? flag = dataPayload['flag'];
      String? notiMessage = dataPayload['message'] ?? dataPayload['body'];
      notiMessage ??= '';

      if (flag == 'broadcast') {
        _onSelectBroadCastNotification(context, notiMessage);
      } else if (flag == 'approval') {
        _onSelectApprovalNotification(context, notiMessage);
      } else if (flag == 'chat') {
        isNotiFromToolbar = true;

        final String? sellerId = dataPayload['seller_id'];
        final String? buyerId = dataPayload['buyer_id'];
        final String? senderName = dataPayload['sender_name'];
        final String? senderProflePhoto = dataPayload['sender_profle_photo'];
        final String? itemId = dataPayload['item_id'];

        if (userProvider.psValueHolder!.loginUserId != null &&
            userProvider.psValueHolder!.loginUserId!.isNotEmpty &&
            !isReachChatView) {
          _showChatNotification(
            context,
            notiMessage,
            sellerId,
            buyerId,
            senderName,
            senderProflePhoto,
            itemId,
            loginUserId,
          );
        }
      } else if (flag == 'review') {
        final String rating = dataPayload['rating'] ?? '0';
        final String ratingMessage =
            Utils.getString(context, 'noti_message__text1') +
                rating.split('.')[0] +
                Utils.getString(context, 'noti_message__text2') +
                '\n"' +
                notiMessage +
                '"';
        _onSelectReviewNotification(
          context,
          ratingMessage,
          userProvider.psValueHolder!.loginUserId,
        );
      } else {
        _onSelectApprovalNotification(context, notiMessage);
      }
    }
  }

  static dynamic takeDataFromNoti2(
      BuildContext context,
      Map<String, dynamic> message,
      String? loginUserId,
      ) {
    return takeDataFromNoti(context, message, loginUserId);
  }

  // --------------------------------------------------------------------------
  // Chat notification & navigation
  // --------------------------------------------------------------------------
  static Future<void> _showChatNotification(
      BuildContext context,
      String? payload,
      String? sellerId,
      String? buyerId,
      String? senderName,
      String? senderProflePhoto,
      String? itemId,
      String? loginUserId, {
        AnimationController? animationController,
      }) async {
    return showDialog<dynamic>(
      context: context,
      builder: (_) {
        return ChatNotiDialog(
          description: '$payload',
          leftButtonText: Utils.getString(context, 'dialog__cancel'),
          rightButtonText:
          Utils.getString(context, 'chat_view__accept_ok_button'),
          onAgreeTap: () {
            Navigator.pop(context);

            _navigateToChat(
              context,
              sellerId,
              buyerId,
              senderName,
              senderProflePhoto,
              itemId,
              loginUserId,
            );

            Provider.of<BuyerChatHistoryListProvider>(context, listen: false);
            Provider.of<SellerChatHistoryListProvider>(context, listen: false);
            Provider.of<UserUnreadMessageProvider>(context, listen: false);

            Navigator.push(
              context,
              MaterialPageRoute<Widget>(
                builder: (BuildContext context) => ChatListScreenWithNewAppBar(
                  animationController: animationController,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void _navigateToChat(
      BuildContext context,
      String? sellerId,
      String? buyerId,
      String? senderName,
      String? senderProflePhoto,
      String? itemId,
      String? loginUserId,
      ) {
    if (loginUserId == buyerId) {
      Navigator.pushNamed(
        context,
        RoutePaths.chatListScreen,
        arguments: ChatHistoryIntentHolder(
          chatFlag: PsConst.CHAT_FROM_SELLER,
          itemId: itemId,
          buyerUserId: buyerId,
          sellerUserId: sellerId,
        ),
      );
    } else {
      Navigator.pushNamed(
        context,
        RoutePaths.chatListScreen,
        arguments: ChatHistoryIntentHolder(
          chatFlag: PsConst.CHAT_FROM_BUYER,
          itemId: itemId,
          buyerUserId: buyerId,
          sellerUserId: sellerId,
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // Link & visibility helpers
  // --------------------------------------------------------------------------
  static Future<void> linkifyLinkOpen(LinkableElement link) async {
    final Uri uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $link';
    }
  }

  static bool showUI(String? valueHolderData) {
    return valueHolderData == PsConst.ONE;
  }
}