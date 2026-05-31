import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' show ImageFilter;
import 'package:taapdeel/ui/common/taapdeel/taapdeel_glass_bottom_sheet.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/config/ps_colors.dart';
import 'package:taapdeel/config/ps_config.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
import 'package:taapdeel/constant/route_paths.dart';
import 'package:taapdeel/provider/app_info/app_info_provider.dart';
import 'package:taapdeel/provider/chat/buyer_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/seller_chat_history_list_provider.dart';
import 'package:taapdeel/provider/chat/user_unread_message_provider.dart';
import 'package:taapdeel/provider/common/notification_provider.dart';
import 'package:taapdeel/provider/delete_task/delete_task_provider.dart';
import 'package:taapdeel/provider/user/user_provider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/chat_history_repository.dart';
import 'package:taapdeel/repository/delete_task_repository.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/repository/user_unread_message_repository.dart';
import 'package:taapdeel/ui/category/list/category_list_view.dart';
import 'package:taapdeel/ui/chat/list/chat_list_screen.dart';
import 'package:taapdeel/ui/common/dialog/chat_noti_dialog.dart';
import 'package:taapdeel/ui/common/dialog/confirm_dialog_view.dart';
import 'package:taapdeel/ui/common/dialog/share_app_dialog.dart';
import 'package:taapdeel/ui/faq/menu_faq_view.dart';
import 'package:taapdeel/ui/history/list/history_list_view.dart';
import 'package:taapdeel/ui/item/entry/item_entry_view.dart';
import 'package:taapdeel/ui/item/favourite/favourite_product_list_view.dart';
import 'package:taapdeel/ui/item/list_with_filter/product_list_with_filter_view.dart';
import 'package:taapdeel/ui/item/paid_ad/paid_ad_item_list_view.dart';
import 'package:taapdeel/ui/item/reported_item/reported_item_list_view.dart';
import 'package:taapdeel/ui/language/setting/language_setting_view.dart';
import 'package:taapdeel/ui/offer/list/offer_list_view.dart';
import 'package:taapdeel/ui/privacy_policy/menu_privacy_policy_view.dart';
import 'package:taapdeel/ui/setting/setting_view.dart';
import 'package:taapdeel/ui/terms_and_conditions/menu_terms_and_conditions_view.dart';
import 'package:taapdeel/ui/user/blocked_user/blocked_user_list_view.dart';
import 'package:taapdeel/ui/user/buy_adpost_transaction/buy_adpost_transaction_history.dart';
import 'package:taapdeel/ui/user/login/login_view.dart';
import 'package:taapdeel/ui/user/profile/profile_view.dart';
import 'package:taapdeel/utils/ps_progress_dialog.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/api_status.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:taapdeel/viewobject/holder/chat_history_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/user_logout_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/user_unread_message_parameter_holder.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/ps_api_service.dart';
import '../../../db/common/ps_shared_preferences.dart';
import '../../../paymob_payment/ui/pakages_screen/packages_screen.dart';
import '../../../viewobject/holder/intent_holder/product_list_intent_holder.dart';

import '../../Contacts/contact_network_provider.dart';
import '../../Contacts/follow_request_badge_provider.dart';
import '../../Discover/home_dashboard_view.dart';
import '../../Foryou/home_view.dart';
import '../../contact_us/contact_us_view.dart';
import '../../item/bulk_entry/bulk_item_entry_view.dart';
import '../../noti/notification_routing_helper.dart';
import '../../sweet_phrase/sweet_message_badge_provider.dart';
import '../../sweet_phrase/sweet_message_profile_repository.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_sheets.dart';
import '../widgets/dashboard_bottom_nav.dart';

// ✅ NEW: follow request badge provider

class DashboardView extends StatefulWidget {
  final bool backToAppItem;

  const DashboardView({Key? key, this.backToAppItem = false}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<DashboardView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  late AnimationController animationController;
  late AnimationController animationControllerForFab;

  late Animation<double> animation;

  String? appBarTitle = 'For You';
  int? _currentIndex = PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT;
  String? _itemId = '';
  String? _userId = '';
  bool isLogout = false;
  bool isFirstTime = true;
  bool isShowMessageDialog = true;
  bool _dashboardBackgroundBootstrapped = false;
  String _lastContactNetworkBootUid = '';
  String phoneUserName = '';
  String phoneNumber = '';
  String phoneId = '';
  UserProvider? provider;
  AppInfoProvider? appInfoProvider;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool isResumed = false;

  CategoryRepository? categoryRepository;
  UserRepository? userRepository;
  AppInfoRepository? appInfoRepository;
  ProductRepository? productRepository;
  PsValueHolder? valueHolder;
  DeleteTaskRepository? deleteTaskRepository;
  DeleteTaskProvider? deleteTaskProvider;
  UserUnreadMessageProvider? userUnreadMessageProvider;
  UserUnreadMessageRepository? userUnreadMessageRepository;
  NotificationRepository? notificationRepository;
  late UserUnreadMessageParameterHolder userUnreadMessageHolder;

  ChatHistoryRepository? chatHistoryRepository;
  BuyerChatHistoryListProvider? buyerListProvider;
  SellerChatHistoryListProvider? sellerListProvider;
  PsValueHolder? psValueHolder;
  ChatHistoryParameterHolder? buyerHolder;
  ChatHistoryParameterHolder? sellerHolder;
  int? sellerCount;
  int? buyerCount;

  String appBarTitleName = '';

  final TextEditingController _homeSearchCtrl = TextEditingController();
  final FocusNode _homeSearchFocusNode = FocusNode();

  static _HomeViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_HomeViewState>();
  }

  void goToBottomTab(int bottomIndex) {
    final dynamic ret = getIndexFromBottonNavigationIndex(bottomIndex);
    updateSelectedIndexWithAnimation(ret[0] as String?, ret[1] as int?);
  }

  void goToProfileTab() => goToBottomTab(4);

  void _initFcmOnceAfterFirstBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!isFirstTime) return;

      valueHolder ??= Provider.of<PsValueHolder>(context, listen: false);
      psValueHolder ??= Provider.of<PsValueHolder>(context, listen: false);

      userUnreadMessageProvider ??=
          Provider.of<UserUnreadMessageProvider?>(context, listen: false);
      buyerListProvider ??=
          Provider.of<BuyerChatHistoryListProvider?>(context, listen: false);
      sellerListProvider ??=
          Provider.of<SellerChatHistoryListProvider?>(context, listen: false);

      appBarTitle = Utils.getString(context, 'inventory');

      Utils.subscribeToTopic(valueHolder!.notiSetting ?? true);

      Utils.fcmConfigure(context, _fcm, valueHolder!.loginUserId, () {
        final String? uid = valueHolder?.loginUserId;
        if (uid == null || uid.isEmpty) return;

        userUnreadMessageHolder = UserUnreadMessageParameterHolder(
          userId: uid,
          deviceToken: valueHolder?.deviceToken,
        );
        userUnreadMessageProvider?.userUnreadMessageCount(userUnreadMessageHolder);

        if (_currentIndex == PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT) {
          if (sellerListProvider != null) {
            sellerHolder = ChatHistoryParameterHolder().getSellerHistoryList();
            sellerHolder!.getSellerHistoryList().userId = uid;
            sellerListProvider!.resetShowProgress(false);
            sellerListProvider!.resetChatHistoryList(sellerHolder!);
          }

          if (buyerListProvider != null) {
            buyerHolder = ChatHistoryParameterHolder().getBuyerHistoryList();
            buyerHolder!.getBuyerHistoryList().userId = uid;
            buyerListProvider!.resetShowProgress(false);
            buyerListProvider!.resetChatHistoryList(buyerHolder!);
          }
        }
      });

      isFirstTime = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    final PsValueHolder? vh = valueHolder ?? psValueHolder;

    if (state == AppLifecycleState.resumed) {
      isResumed = true;
      _clearHomeSearchFocus();
      return;
    }

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final String? loginUserId = vh?.loginUserId;
      if (loginUserId == null || loginUserId.isEmpty) return;

      try {
        final String? deviceToken = vh?.deviceToken;

        if (userUnreadMessageProvider != null) {
          userUnreadMessageHolder = UserUnreadMessageParameterHolder(
            userId: loginUserId,
            deviceToken: deviceToken,
          );
          userUnreadMessageProvider!.userUnreadMessageCount(userUnreadMessageHolder);
        }

        if (_currentIndex == PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT) {
          final String? uid = psValueHolder?.loginUserId ?? loginUserId;

          if (uid != null && uid.isNotEmpty) {
            if (sellerListProvider != null) {
              sellerHolder = ChatHistoryParameterHolder().getSellerHistoryList();
              sellerHolder!.getSellerHistoryList().userId = uid;
              sellerListProvider!.resetShowProgress(false);
              sellerListProvider!.resetChatHistoryList(sellerHolder!);
            }

            if (buyerListProvider != null) {
              buyerHolder = ChatHistoryParameterHolder().getBuyerHistoryList();
              buyerHolder!.getBuyerHistoryList().userId = uid;
              buyerListProvider!.resetShowProgress(false);
              buyerListProvider!.resetChatHistoryList(buyerHolder!);
            }
          }
        }
      } catch (e, st) {
        debugPrint('didChangeAppLifecycleState error: $e');
        debugPrint('$st');
      }
    }
  }

  void _clearHomeSearchFocus() {
    _homeSearchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _goHomeSearch() {
    _clearHomeSearchFocus();

    final ProductParameterHolder holder =
    ProductParameterHolder().getLatestParameterHolder();

    holder.itemLocationId = psValueHolder?.locationId ?? valueHolder?.locationId;
    holder.itemLocationName =
        psValueHolder?.locactionName ?? valueHolder?.locactionName;

    if ((psValueHolder?.isSubLocation ?? valueHolder?.isSubLocation) ==
        PsConst.ONE) {
      holder.itemLocationTownshipId =
          psValueHolder?.locationTownshipId ?? valueHolder?.locationTownshipId;
      holder.itemLocationTownshipName = psValueHolder?.locationTownshipName ??
          valueHolder?.locationTownshipName;
    }

    holder.searchTerm = _homeSearchCtrl.text;

    Navigator.pushNamed(
      context,
      RoutePaths.filterProductList,
      arguments: ProductListIntentHolder(
        appBarTitle: Utils.getString(context, 'home_search__app_bar_title'),
        productParameterHolder: holder,
      ),
    );
  }

  void _openLocationBottomSheet() {
    _clearHomeSearchFocus();

    DashboardSheets.openLocationBottomSheet(
      context: context,
      onChangeTap: () {
        _clearHomeSearchFocus();

        Navigator.pushNamed(
          context,
          RoutePaths.searchLocationTownshipList,
          arguments: valueHolder?.locationId ?? psValueHolder?.locationId,
        );
      },
    );
  }

  Future<dynamic> showMessageDialog(BuildContext context) async {
    if (!Utils.isShowNotiFromToolbar() && !isShowMessageDialog) {
      showDialog<dynamic>(
          context: context,
          builder: (_) {
            return ChatNotiDialog(
                description: Utils.getString(context, 'noti_message__new_message'),
                leftButtonText: Utils.getString(context, 'chat_noti__cancel'),
                rightButtonText: Utils.getString(context, 'chat_noti__open'),
                onAgreeTap: () {
                  print("showMessageDialog Accepted");
                  int index = PsConst.REQUEST_CODE__DASHBOARD_NOTI_FRAGMENT;
                  String title = Utils.getString(context, '/offerList');

                  updateSelectedIndexWithAnimation(title, index);
                  Navigator.pop(context);
                });
          });
      isShowMessageDialog = true;
    }
  }

  Future<void> updateSelectedIndexWithAnimation(String? title, int? index) async {
    _clearHomeSearchFocus();

    await animationController.reverse().then<dynamic>((void data) {
      if (!mounted) {
        return;
      }

      setState(() {
        appBarTitleName = '';
        appBarTitle = title;
        _currentIndex = index;
      });
    });
  }

  Future<void> updateSelectedIndexWithAnimationUserId(
      String title, int index, String? userId) async {
    await animationController.reverse().then<dynamic>((void data) {
      if (!mounted) {
        return;
      }
      if (userId != null) {
        _userId = userId;
      }
      setState(() {
        appBarTitle = title;
        _currentIndex = index;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationRoutingHelper.registerDashboardNavigator((tabIndex) {
      goToBottomTab(tabIndex);
    });
    WidgetsBinding.instance.addObserver(this);

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    animationControllerForFab = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1,
    );

    valueHolder = Provider.of<PsValueHolder>(context, listen: false);
    psValueHolder = valueHolder;

    final String uid = (valueHolder?.loginUserId ?? '').trim();
    final bool isLoggedIn = uid.isNotEmpty;

    if (widget.backToAppItem) {
      _currentIndex = PsConst.REQUEST_CODE__DASHBOARD_ITEM_UPLOAD_FRAGMENT;
    } else {
      _currentIndex = isLoggedIn
          ? PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT
          : PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT;
    }

    _initFcmOnceAfterFirstBuild();
  }

  void _showAddBottomSheet(BuildContext context) {
    DashboardSheets.showAddBottomSheet(
      context: context,
      onAddProduct: () {
        final dynamic returnValue = getIndexFromBottonNavigationIndex(2);
        updateSelectedIndexWithAnimation(returnValue[0], returnValue[1]);
      },
      onAddBulkProducts: () {
        if (valueHolder != null &&
            valueHolder!.loginUserId != null &&
            valueHolder!.loginUserId != '') {
          Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (_) => const BulkItemEntryView(maxItems: 30),
            ),
          );
        } else {
          updateSelectedIndexWithAnimation(
            Utils.getString(context, 'home_login'),
            PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _homeSearchCtrl.dispose();
    _homeSearchFocusNode.dispose();
    animationController.dispose();
    animationControllerForFab.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int getBottonNavigationIndex(int? param) {
    int index = 0;
    switch (param) {
      case PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT:
        index = 0;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT:
        index = 1;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_ITEM_UPLOAD_FRAGMENT:
        index = 2;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_REGISTER_FRAGMENT:
        if (valueHolder!.loginUserId != null && valueHolder!.loginUserId != '') {
          index = 2;
        } else {
          index = 4;
        }
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_FORGOT_PASSWORD_FRAGMENT:
        if (valueHolder!.loginUserId != null && valueHolder!.loginUserId != '') {
          index = 2;
        } else {
          index = 4;
        }
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT:
        if (valueHolder!.loginUserId != null && valueHolder!.loginUserId != '') {
          index = 2;
        } else {
          index = 4;
        }
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_VERIFY_EMAIL_FRAGMENT:
        index = 2;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT:
        index = 4;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_PHONE_SIGNIN_FRAGMENT:
        index = 2;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_PHONE_VERIFY_FRAGMENT:
        index = 2;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_NOTI_FRAGMENT:
        index = 3;
        break;
      case PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT:
        index = 4;
        break;
      default:
        index = 0;
        break;
    }
    return index;
  }

  dynamic getIndexFromBottonNavigationIndex(int param) {
    int index;
    String title;

    switch (param) {
      case 0:
        index = PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT;
        title = Utils.getString(context, 'inventory');
        break;

      case 1:
        index = PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT;
        title = Utils.getString(context, 'home');
        break;

      case 2:
        index = PsConst.REQUEST_CODE__DASHBOARD_ITEM_UPLOAD_FRAGMENT;
        title = Utils.getString(context, 'Taapdeel');
        break;

      case 3:
        index = PsConst.REQUEST_CODE__DASHBOARD_NOTI_FRAGMENT;
        title = Utils.getString(context, 'my_requests');
        break;

      case 4:
        index = PsConst.REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT;
        title = Utils.getString(context, 'profile');
        break;

      default:
        index = PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT;
        title = Utils.getString(context, 'inventory');
        break;
    }

    return <dynamic>[title, index];
  }

  void changeAppBarTitle(String categoryName) {
    appBarTitleName = categoryName;
  }

  @override
  Widget build(BuildContext context) {
    categoryRepository = Provider.of<CategoryRepository>(context, listen: false);
    userRepository = Provider.of<UserRepository>(context, listen: false);
    appInfoRepository = Provider.of<AppInfoRepository>(context, listen: false);
    valueHolder = Provider.of<PsValueHolder>(context);
    productRepository = Provider.of<ProductRepository>(context, listen: false);
    deleteTaskRepository = Provider.of<DeleteTaskRepository>(context, listen: false);
    userUnreadMessageRepository =
        Provider.of<UserUnreadMessageRepository>(context, listen: false);
    notificationRepository = Provider.of<NotificationRepository>(context, listen: false);
    userUnreadMessageProvider ??=
        Provider.of<UserUnreadMessageProvider?>(context, listen: false);
    buyerListProvider ??=
        Provider.of<BuyerChatHistoryListProvider?>(context, listen: false);
    sellerListProvider ??=
        Provider.of<SellerChatHistoryListProvider?>(context, listen: false);

    psValueHolder = Provider.of<PsValueHolder>(context);
    chatHistoryRepository = Provider.of<ChatHistoryRepository>(context, listen: false);

    timeDilation = 1.0;

    Future<void> updateSelectedIndex(int index) async {
      setState(() {
        _currentIndex = index;
      });
    }

    dynamic callLogout(
        UserProvider provider, DeleteTaskProvider deleteTaskProvider, int index) async {
      appBarTitle = Utils.getString(context, 'app_name');
      updateSelectedIndex(index);
      await provider.replaceLoginUserId('');
      await provider.replaceLoginUserName('');
      await deleteTaskProvider.deleteTask();
      await GoogleSignIn().signOut();
      await fb_auth.FirebaseAuth.instance.signOut();
      if (provider.psValueHolder!.isForceLogin!) {
        Navigator.pushNamedAndRemoveUntil(
            context, RoutePaths.login_container, (_) => false);
      } else {
        Navigator.of(context).pop();
      }
    }

    Future<bool> _onWillPop() {
      if (_currentIndex == PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT) {
        return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogView(
                  description:
                  Utils.getString(context, 'home__quit_dialog_description'),
                  leftButtonText: Utils.getString(context, 'dialog__cancel'),
                  rightButtonText: Utils.getString(context, 'dialog__ok'),
                  onAgreeTap: () {
                    Navigator.pop(context);
                  });
            }).then((dynamic value) {
          SystemNavigator.pop();
          return value;
        });
      } else {
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.home,
        );
        return Future<bool>.value(false);
      }
    }

    final Animation<double> animation =
    Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController,
        curve:
        const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));

    final ProductParameterHolder latestParameterHolder =
    ProductParameterHolder().getLatestParameterHolder();
    latestParameterHolder.mile = psValueHolder!.mile;
    final ProductParameterHolder recentParameterHolder =
    ProductParameterHolder().getRecentParameterHolder();
    recentParameterHolder.mile = psValueHolder!.mile;
    final ProductParameterHolder popularParameterHolder =
    ProductParameterHolder().getPopularParameterHolder();
    popularParameterHolder.mile = psValueHolder!.mile;

    // ✅ uid للمستخدم الحالي — يُستخدم لتحميل عدد طلبات الـ follow
    final String currentUid = (psValueHolder?.loginUserId ?? '').trim();
    final bool isLoggedIn =
        currentUid.isNotEmpty && currentUid != 'nologinuser';

    return MultiProvider(
        providers: [
          Provider<SweetMessageProfileRepository>(
            create: (ctx) => SweetMessageProfileRepository(
              psApiService: ctx.read<PsApiService>(),
            ),
          ),
          ChangeNotifierProvider<SweetMessageBadgeProvider>(
            create: (ctx) => SweetMessageBadgeProvider(
              repository: ctx.read<SweetMessageProfileRepository>(),
            ),
          ),
          // ✅ NEW: provider لعدد طلبات الـ follow المعلقة
          ChangeNotifierProvider<FollowRequestBadgeProvider>(
            create: (_) => FollowRequestBadgeProvider(),
          ),
          // ✅ Central contact-network manager.
          // AppBar consumes its count only; sync is triggered here.
          ChangeNotifierProvider<ContactNetworkProvider>(
            create: (_) => ContactNetworkProvider(),
          ),
        ],
        builder: (innerContext, child) {
          if (!_dashboardBackgroundBootstrapped) {
            _dashboardBackgroundBootstrapped = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              // 1) Start contact cache/guest discovery after the first frame.
              //    If the user granted permission in Intro, this can show matched people
              //    even before login using local cache/guest matching only.
              Future<void>.delayed(const Duration(milliseconds: 900), () {
                if (!mounted) return;
                innerContext.read<ContactNetworkProvider>().initForApp();
              });

              // 2) Run login-only badges after the page is stable.
              Future<void>.delayed(const Duration(seconds: 4), () {
                if (!mounted) return;

                final String uid =
                    (Provider.of<PsValueHolder>(innerContext, listen: false)
                                .loginUserId ??
                            '')
                        .trim();

                if (uid.isEmpty || uid == 'nologinuser') return;

                _lastContactNetworkBootUid = uid;

                unawaited(
                  innerContext
                      .read<SweetMessageBadgeProvider>()
                      .loadUnreadCount(loginUserId: uid),
                );

                unawaited(
                  innerContext
                      .read<FollowRequestBadgeProvider>()
                      .loadPendingCount(uid),
                );

                // Force once after login so guest matches are promoted to backend suggestions.
                unawaited(
                  innerContext
                      .read<ContactNetworkProvider>()
                      .initForApp(userId: uid, forceAfterLogin: true),
                );
              });
            });
          }

          final String liveUid =
              (Provider.of<PsValueHolder>(innerContext, listen: false).loginUserId ??
                      '')
                  .trim();

          if (liveUid.isNotEmpty &&
              liveUid != 'nologinuser' &&
              liveUid != _lastContactNetworkBootUid) {
            _lastContactNetworkBootUid = liveUid;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              unawaited(
                innerContext
                    .read<ContactNetworkProvider>()
                    .initForApp(userId: liveUid, forceAfterLogin: true),
              );
            });
          }

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              key: scaffoldKey,
              drawer: DashboardDrawer(
                userRepository: Provider.of<UserRepository>(context),
                deleteTaskRepository:
                Provider.of<DeleteTaskRepository>(context),
                valueHolder: valueHolder,
                onSelectIndex: (title, index) {
                  setState(() => _currentIndex = index);
                },
                onLogoutSuccess: () {
                  setState(() => _currentIndex =
                      PsConst.REQUEST_CODE__DASHBOARD_SEARCH_FRAGMENT);
                },
              ),
              appBar: DashboardAppBar(
                searchController: _homeSearchCtrl,
                searchFocusNode: _homeSearchFocusNode,
                onSearch: _goHomeSearch,
                onOpenLocation: _openLocationBottomSheet,
                valueHolder: valueHolder,
                psValueHolder: psValueHolder,
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                left: false,
                right: false,
                // ✅ نستمع للـ provider الاتنين: sweet + follow requests
                child: Consumer2<SweetMessageBadgeProvider,
                    FollowRequestBadgeProvider>(
                  builder: (context, badgeProvider, followBadge, _) {
                    // ✅ مجموع الـ badge = sweet messages + follow requests
                    final int totalProfileBadge =
                        badgeProvider.unreadCount + followBadge.pendingCount;

                    return DashboardBottomNav(
                      currentIndex: _currentIndex,
                      getBottomNavIndex: getBottonNavigationIndex,
                      profileUnreadCount: totalProfileBadge,
                      onTabSelected: (int index) {
                        final dynamic ret =
                        getIndexFromBottonNavigationIndex(index);
                        updateSelectedIndexWithAnimation(ret[0], ret[1]);
                      },
                      onAddPressed: () => _showAddBottomSheet(context),
                    );
                  },
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: ChangeNotifierProvider<NotificationProvider>(
                lazy: false,
                create: (BuildContext context) {
                  final NotificationProvider provider = NotificationProvider(
                    repo: notificationRepository,
                    psValueHolder: valueHolder,
                  );
                  if (provider.psValueHolder!.deviceToken == null ||
                      provider.psValueHolder!.deviceToken == '') {
                    final FirebaseMessaging fcm = FirebaseMessaging.instance;
                    Utils.saveDeviceToken(fcm, provider);
                  }
                  return provider;
                },
                child: Builder(
                  builder: (BuildContext context) {
                    if (_currentIndex ==
                        PsConst.REQUEST_CODE__DASHBOARD_MESSAGE_FRAGMENT)
                      if (valueHolder!.loginUserId != null &&
                          valueHolder!.loginUserId != '') {
                        return MultiProvider(
                            providers: <SingleChildWidget>[
                              ChangeNotifierProvider<UserProvider>(
                                  lazy: false,
                                  create: (BuildContext context) {
                                    return UserProvider(
                                        repo: userRepository,
                                        psValueHolder: valueHolder);
                                  }),
                              ChangeNotifierProvider<DeleteTaskProvider?>(
                                  lazy: false,
                                  create: (BuildContext context) {
                                    deleteTaskProvider = DeleteTaskProvider(
                                        repo: deleteTaskRepository,
                                        psValueHolder: valueHolder);
                                    return deleteTaskProvider;
                                  }),
                            ],
                            child: Consumer<UserProvider>(builder:
                                (BuildContext context, UserProvider provider,
                                Widget? child) {
                              return HomeViewWidget(context,
                                  provider.psValueHolder!.loginUserId);
                            }));
                      } else {
                        return CallLoginWidget(
                            currentIndex: _currentIndex,
                            animationController: animationController,
                            animation: animation,
                            updateCurrentIndex: (String title, int index) {
                              updateSelectedIndexWithAnimation(title, index);
                            },
                            updateUserCurrentIndex:
                                (String title, int index, String userId) {
                              setState(() {
                                appBarTitle = title;
                                _currentIndex = index;
                              });
                              _userId = userId;
                            });
                      }
                    else if (_currentIndex ==
                        PsConst
                            .REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT) {
                      return MultiProvider(
                          providers: <SingleChildWidget>[
                            ChangeNotifierProvider<UserProvider>(
                                lazy: false,
                                create: (BuildContext context) {
                                  return UserProvider(
                                      repo: userRepository,
                                      psValueHolder: valueHolder);
                                }),
                            ChangeNotifierProvider<DeleteTaskProvider?>(
                                lazy: false,
                                create: (BuildContext context) {
                                  deleteTaskProvider = DeleteTaskProvider(
                                      repo: deleteTaskRepository,
                                      psValueHolder: valueHolder);
                                  return deleteTaskProvider;
                                }),
                          ],
                          child: Consumer<UserProvider>(
                              builder: (BuildContext context,
                                  UserProvider provider, Widget? child) {
                                final bool isLoggedIn =
                                    provider.psValueHolder?.loginUserId != null &&
                                        provider
                                            .psValueHolder!.loginUserId!.isNotEmpty;
                                if (!isLoggedIn) {
                                  return CallLoginWidget(
                                      currentIndex: _currentIndex,
                                      animationController: animationController,
                                      animation: animation,
                                      updateCurrentIndex:
                                          (String title, int index) {
                                        updateSelectedIndexWithAnimation(
                                            title, index);
                                      },
                                      updateUserCurrentIndex: (String title,
                                          int index, String userId) {
                                        updateSelectedIndexWithAnimation(
                                            title, index);
                                        _userId = userId;
                                        provider.psValueHolder!.loginUserId =
                                            userId;
                                      });
                                } else {
                                  return ProfileView(
                                    scaffoldKey: scaffoldKey,
                                    animationController: animationController,
                                    flag: _currentIndex,
                                    callLogoutCallBack: (String userId) {
                                      callLogout(
                                          provider,
                                          deleteTaskProvider!,
                                          PsConst
                                              .REQUEST_CODE__MENU_HOME_FRAGMENT);
                                    },
                                  );
                                }
                              }));
                    } else if (_currentIndex ==
                        PsConst
                            .REQUEST_CODE__DASHBOARD_USER_PROFILE_FRAGMENT ||
                        _currentIndex ==
                            PsConst
                                .REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT) {
                      return ProfileView(
                        scaffoldKey: scaffoldKey,
                        animationController: animationController,
                        flag: _currentIndex,
                        userId: _userId,
                        callLogoutCallBack: (String userId) {
                          callLogout(
                              provider!,
                              deleteTaskProvider!,
                              PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
                        },
                      );
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_CATEGORY_FRAGMENT) {
                      return CategoryListView(
                        onBoarding: false,
                        home: false,
                        onTap: () {},
                        onLoginTap: () {
                          updateSelectedIndexWithAnimation(
                            Utils.getString(context, 'home_login'),
                            PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT,
                          );
                        },
                      );
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_LATEST_PRODUCT_FRAGMENT) {
                      return ProductListWithFilterView(
                        key: const Key('1'),
                        changeAppBarTitle: appBarTitleName,
                        animationController: animationController,
                        productParameterHolder: latestParameterHolder,
                      );
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_DISCOUNT_PRODUCT_FRAGMENT) {
                      return ProductListWithFilterView(
                        key: const Key('2'),
                        changeAppBarTitle: appBarTitleName,
                        animationController: animationController,
                        productParameterHolder: recentParameterHolder,
                      );
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_TRENDING_PRODUCT_FRAGMENT) {
                      return ProductListWithFilterView(
                        key: const Key('3'),
                        changeAppBarTitle: appBarTitleName,
                        animationController: animationController,
                        productParameterHolder: popularParameterHolder,
                      );
                    }  else if (_currentIndex ==
                        PsConst
                            .REQUEST_CODE__DASHBOARD_ITEM_UPLOAD_FRAGMENT) {
                      if (valueHolder!.loginUserId != null &&
                          valueHolder!.loginUserId != '') {
                        return ItemEntryView(
                            animationController: animationController,
                            flag: PsConst.ADD_NEW_ITEM,
                            item: Product(),
                            maxImageCount: valueHolder!.maxImageCount,
                            onItemUploaded: (String itemId) {
                              _itemId = itemId;
                              final int profileIndex = PsConst
                                  .REQUEST_CODE__DASHBOARD_SELECT_WHICH_USER_FRAGMENT;
                              final String profileTitle =
                              Utils.getString(context, 'profile');
                              updateSelectedIndexWithAnimation(
                                  profileTitle, profileIndex);
                            });
                      } else {
                        return CallLoginWidget(
                            currentIndex: _currentIndex,
                            animationController: animationController,
                            animation: animation,
                            updateCurrentIndex: (String title, int index) {
                              updateSelectedIndexWithAnimation(title, index);
                            },
                            updateUserCurrentIndex:
                                (String title, int index, String userId) {
                              setState(() {
                                appBarTitle = title;
                                _currentIndex = index;
                              });
                              _userId = userId;
                            });
                      }
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__DASHBOARD_LOGIN_FRAGMENT ||
                        _currentIndex ==
                            PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT) {
                      return CallLoginWidget(
                          currentIndex: _currentIndex,
                          animationController: animationController,
                          animation: animation,
                          updateCurrentIndex: (String title, int index) {
                            updateSelectedIndexWithAnimation(title, index);
                          },
                          updateUserCurrentIndex:
                              (String title, int index, String userId) {
                            setState(() {
                              appBarTitle = title;
                              _currentIndex = index;
                            });
                            _userId = userId;
                          });
                    } else if (_currentIndex ==
                        PsConst
                            .REQUEST_CODE__MENU_SELECT_WHICH_USER_FRAGMENT) {
                      return ChangeNotifierProvider<UserProvider>(
                          lazy: false,
                          create: (BuildContext context) {
                            final UserProvider provider = UserProvider(
                                repo: userRepository,
                                psValueHolder: valueHolder);
                            return provider;
                          },
                          child: Consumer<UserProvider>(
                              builder: (BuildContext context,
                                  UserProvider provider, Widget? child) {
                                final bool isLoggedIn =
                                    provider.psValueHolder?.loginUserId != null &&
                                        provider
                                            .psValueHolder!.loginUserId!.isNotEmpty;
                                if (!isLoggedIn) {
                                  return CallLoginWidget(
                                      currentIndex: _currentIndex,
                                      animationController: animationController,
                                      animation: animation,
                                      updateCurrentIndex:
                                          (String title, int index) {
                                        updateSelectedIndexWithAnimation(
                                            title, index);
                                      },
                                      updateUserCurrentIndex: (String title,
                                          int index, String userId) {
                                        updateSelectedIndexWithAnimation(
                                            title, index);
                                        _userId = userId;
                                        provider.psValueHolder!.loginUserId =
                                            userId;
                                      });
                                } else {
                                  return ProfileView(
                                    scaffoldKey: scaffoldKey,
                                    animationController: animationController,
                                    flag: _currentIndex,
                                    callLogoutCallBack: (String userId) {
                                      callLogout(
                                          provider,
                                          deleteTaskProvider!,
                                          PsConst
                                              .REQUEST_CODE__MENU_HOME_FRAGMENT);
                                    },
                                  );
                                }
                              }));
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_FAVOURITE_FRAGMENT) {
                      return FavouriteProductListView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_TRANSACTION_FRAGMENT) {
                      return PaidAdItemListView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst
                            .REQUEST_CODE__MENU_BUY_AD_TRANSACTION_FRAGMENT) {
                      return BuyAdTransactionListView();
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_USER_HISTORY_FRAGMENT) {
                      return HistoryListView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_OFFER_FRAGMENT) {
                      return OfferListView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_BLOCKED_USER_FRAGMENT) {
                      return BlockedUserListView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_REPORTED_ITEM_FRAGMENT) {
                      return ReportedItemListView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_LANGUAGE_FRAGMENT) {
                      return LanguageSettingView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT) {
                      return ContactUsView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT) {
                      return Container(
                        color: PsColors.baseColor,
                        height: double.infinity,
                        child:
                        SettingView(animationController: animationController),
                      );
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_PRIVACY_POLICY_FRAGMENT) {
                      return MenuPrivacyPolicyView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst
                            .REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT) {
                      return MenuTermsAndConditionView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__MENU_FAQ_PAGES_FRAGMENT) {
                      return MenuFAQView(
                          animationController: animationController);
                    } else if (_currentIndex ==
                        PsConst.REQUEST_CODE__DASHBOARD_NOTI_FRAGMENT) {
                      if (valueHolder!.loginUserId != null &&
                          valueHolder!.loginUserId != '') {
                        return const ChatListScreen();
                      } else {
                        return CallLoginWidget(
                            currentIndex: _currentIndex,
                            animationController: animationController,
                            animation: animation,
                            updateCurrentIndex: (String title, int index) {
                              updateSelectedIndexWithAnimation(title, index);
                            },
                            updateUserCurrentIndex:
                                (String title, int index, String userId) {
                              setState(() {
                                appBarTitle = title;
                                _currentIndex = index;
                              });
                              _userId = userId;
                            });
                      }
                    } else {
                      animationController.forward();
                      return HomeDashboardViewWidget(
                        _scrollController,
                        animationController,
                        animationControllerForFab,
                      );
                    }
                  },
                ),
              ),
            ),
          );
        });
  }
}

class CallLoginWidget extends StatelessWidget {
  const CallLoginWidget({
    required this.animationController,
    required this.animation,
    required this.updateCurrentIndex,
    required this.updateUserCurrentIndex,
    required this.currentIndex,
  });

  final Function updateCurrentIndex;
  final Function updateUserCurrentIndex;
  final AnimationController? animationController;
  final Animation<double> animation;
  final int? currentIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: PsColors.baseColor,
          width: double.infinity,
          height: double.maxFinite,
        ),
        CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: LoginView(
                animationController: animationController,
                animation: animation,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DrawerMenuWidget extends StatefulWidget {
  const _DrawerMenuWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final Function onTap;
  final int index;

  @override
  __DrawerMenuWidgetState createState() => __DrawerMenuWidgetState();
}

class __DrawerMenuWidgetState extends State<_DrawerMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(widget.icon, color: PsColors.buttonColor),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () {
          widget.onTap(widget.title, widget.index);
        });
  }
}

class _DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/images/Taapdeel_logo.png',
            width: PsDimens.space100,
            height: PsDimens.space72,
          ),
          const SizedBox(
            height: PsDimens.space8,
          ),
          Text(
            Utils.getString(context, 'app_name'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: PsColors.white),
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: Utils.isLightMode(context)
              ? PsColors.primary500
              : Colors.black12),
    );
  }
}

Future<void> notificationPermissionHandler(BuildContext context) async {
  PermissionStatus permissionStatus = await Permission.notification.status;
  print("Permission Function");
  print("---------- ${permissionStatus.toString()}");
  if (permissionStatus != PermissionStatus.granted) {
    permissionStatus = await Permission.notification.request();
    print("Request Permission");

    if (permissionStatus != PermissionStatus.granted) {
      showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('notification_permission_required').tr(),
            content: Text('notification_dialog_description').tr(),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('dialog__cancel').tr(),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: Text('go_to_settings').tr(),
              ),
            ],
          );
        },
      );
    } else if (permissionStatus == PermissionStatus.granted) {
      print("Permission Request Granted");
    }
  }
}
