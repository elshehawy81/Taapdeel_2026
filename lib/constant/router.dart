import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_constants.dart';
import 'package:taapdeel/constant/route_paths.dart';
// Core / global screens
import 'package:taapdeel/ui/app_info/app_info_view.dart';
import 'package:taapdeel/ui/app_loading/app_loading_view.dart';
import 'package:taapdeel/ui/user/profile/profile_route_page.dart';
// Category & Subcategory
import 'package:taapdeel/ui/category/list/category_list_view.dart';
// Chat

import 'package:taapdeel/ui/chat/list/chat_list_screen.dart';
// Contact / Info / Settings
import 'package:taapdeel/ui/contact_us/contact_us_container_view.dart';
import 'package:taapdeel/ui/dashboard/core/dashboard_view.dart';
import 'package:taapdeel/ui/faq/setting_faq_view.dart';
import 'package:taapdeel/ui/force_update/force_update_view.dart';
// Gallery / Media

// History / Favourites / Paid Ads
import 'package:taapdeel/ui/history/list/history_list_container.dart';
// Intro / Language
import 'package:taapdeel/ui/introslider/intro_slider_view.dart';
import 'package:taapdeel/ui/introslider/taapdeel_profile_setup_view.dart';

// Item related screens
import 'package:taapdeel/ui/item/condition/item_condition_view.dart';
import 'package:taapdeel/ui/item/deal_option/item_deal_option_view.dart';
import 'package:taapdeel/ui/item/detail/product_detail_view.dart';
import 'package:taapdeel/ui/item/entry/item_entry_container.dart';
import 'package:taapdeel/ui/wish_Items/wish_item_entry_container_view.dart';
import 'package:taapdeel/ui/item/favourite/favourite_product_list_container.dart';
import 'package:taapdeel/ui/item/list_with_filter/filter/category/filter_list_view.dart';
import 'package:taapdeel/ui/item/list_with_filter/filter/filter/item_search_view.dart';
import 'package:taapdeel/ui/item/list_with_filter/nearest_product_list_view.dart';
import 'package:taapdeel/ui/item/list_with_filter/product_list_with_filter_container.dart';
import 'package:taapdeel/ui/item/paid_ad/paid_ad_item_list_container.dart';
import 'package:taapdeel/ui/item/price_type/item_price_type_view.dart';
import 'package:taapdeel/ui/item/promote/ItemPromoteView.dart';
import 'package:taapdeel/ui/item/promote/choose_payment_view.dart';
import 'package:taapdeel/ui/item/reported_item/reported_item_container_view.dart';
import 'package:taapdeel/ui/item/sold_out/item_sold_out_view.dart';
import 'package:taapdeel/ui/item/type/type_list_view.dart';
import 'package:taapdeel/ui/language/list/language_list_view.dart';
import 'package:taapdeel/ui/language/setting/language_setting_container_view.dart';
// Location
import 'package:taapdeel/ui/location/filter_location_view.dart';
import 'package:taapdeel/ui/location/item_location_container.dart';
import 'package:taapdeel/ui/location/item_location_first_view.dart';
import 'package:taapdeel/ui/location/item_location_township_first_view.dart';
import 'package:taapdeel/ui/location_township/item_location_township_container.dart';
// Maps

// Notifications
import 'package:taapdeel/ui/noti/detail/noti_view.dart';
import 'package:taapdeel/ui/noti/list/noti_list_view_container.dart';
import 'package:taapdeel/ui/noti/notification_setting/notification_setting_view.dart';
// Offers / Swap
import 'package:taapdeel/ui/offer/add_swap_offer/AddSwapOfferScreen.dart';
import 'package:taapdeel/ui/Contacts/follow_requests_screen.dart';
import 'package:taapdeel/ui/offer/list/offer_container_view.dart';
// Payment
import 'package:taapdeel/ui/privacy_policy/setting_privacy_policy_view.dart';
// Rating
import 'package:taapdeel/ui/rating/list/rating_list_view.dart';
import 'package:taapdeel/ui/safety_tips/safety_tips_view.dart';
// Search
import 'package:taapdeel/ui/search/search_location/search_location_view.dart';
import 'package:taapdeel/ui/search/search_location_township/search_location_township_view.dart';
import 'package:taapdeel/ui/setting/camera/camera_setting_view.dart';
import 'package:taapdeel/ui/setting/setting_container_view.dart';
import 'package:taapdeel/ui/subcategory/list/sub_category_grid_view.dart';
import 'package:taapdeel/ui/terms_and_conditions/setting_terms_and_conditions_view.dart';
// User
import 'package:taapdeel/ui/user/blocked_user/block_user_container_view.dart';
import 'package:taapdeel/ui/user/buy_adpost_transaction/buy_adpost_transaction_history_container_view.dart';
import 'package:taapdeel/ui/user/edit_profile/edit_profile_view.dart';
import 'package:taapdeel/ui/user/list/follower_user_list_view.dart';
import 'package:taapdeel/ui/user/list/following_user_list_view.dart';
import 'package:taapdeel/ui/user/login/login_container_view.dart';
import 'package:taapdeel/ui/user/more/more_container_view.dart';
import 'package:taapdeel/ui/user/user_detail/detail_follower_user_list_view.dart';
import 'package:taapdeel/ui/user/user_detail/detail_following_user_list_view.dart';
import 'package:taapdeel/ui/user/user_detail/user_detail_view.dart';
// Utils & ViewObjects
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/blog.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/default_photo.dart';
import 'package:taapdeel/viewobject/holder/follower_uer_item_list_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/chat_history_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/item_entry_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/item_list_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/map_pin_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/product_list_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/safety_tips_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/intent_holder/user_intent_holder.dart';
import 'package:taapdeel/viewobject/holder/location_parameter_holder.dart';
import 'package:taapdeel/viewobject/holder/paid_history_holder.dart';
import 'package:taapdeel/viewobject/holder/product_parameter_holder.dart';
import 'package:taapdeel/viewobject/message.dart';
import 'package:taapdeel/viewobject/noti.dart';
import 'package:taapdeel/viewobject/product.dart';
import 'package:taapdeel/viewobject/ps_app_info.dart';
import 'package:taapdeel/viewobject/ps_app_version.dart';

import '../viewobject/holder/intent_holder/request_details_intent_holder.dart';

/// Central route generator for the whole app.
/// Future Improvement: Replace this large switch with a typed route system
/// (e.g. go_router, auto_route, or a RouteMap) and move argument parsing
/// into dedicated helper functions for better testability.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => AppLoadingView(),
      );

    case RoutePaths.home:
      return MaterialPageRoute<dynamic>(
        settings: const RouteSettings(name: RoutePaths.home),
        builder: (BuildContext context) {
          final bool backToAddItem =
              settings.arguments as bool? ?? false; // default: false
          return DashboardView(backToAppItem: backToAddItem);
        },
      );

  // ----------------------------------------------------------------------
  // Location / Township
  // ----------------------------------------------------------------------

    case RoutePaths.itemLocationTownshipList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String cityId =
          (settings.arguments ?? '') as String; // empty if null
          return ItemLocationTownshipContainerView(cityId: cityId);
        },
      );



    case RoutePaths.itemLocationTownshipFirst:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String cityId =
          (settings.arguments ?? '') as String; // empty if null
          return ItemLocationTownshipFirstView(cityId: cityId);
        },
      );

    case RoutePaths.searchLocationList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SearchLocationView(),
      );

    case RoutePaths.searchLocationTownshipList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String cityId =
          (settings.arguments ?? '') as String; // empty if null
          return SearchLocationTownshipView(cityId: cityId);
        },
      );

  // ----------------------------------------------------------------------
  // Intro / Force update
  // ----------------------------------------------------------------------

    case RoutePaths.introSlider:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final int settingSlider =
              settings.arguments as int? ?? 0; // default: 0
          return IntroSliderView(settingSlider: settingSlider);
        },
      );

    case RoutePaths.force_update:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final PSAppVersion psAppVersion = settings.arguments as PSAppVersion;
          return ForceUpdateView(psAppVersion: psAppVersion);
        },
      );

  // ----------------------------------------------------------------------
  // Auth / User registration & verification
  // ----------------------------------------------------------------------

    case RoutePaths.taapdeelProfileSetup :
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => TaapdeelProfileSetupView(),
      );


    case RoutePaths.login_container:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => LoginContainerView(),
      );

    case RoutePaths.contactUs:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ContactUsContainerView(),
      );
    case RoutePaths.profile:
      return MaterialPageRoute<dynamic>(
        settings: const RouteSettings(name: RoutePaths.profile),
        builder: (BuildContext context) {
          final args = settings.arguments;
          final ProfileRouteArgs? holder =
          (args is ProfileRouteArgs) ? args : null;

          return ProfileRoutePage(args: holder);
        },
      );


  // ----------------------------------------------------------------------
  // Language
  // ----------------------------------------------------------------------

    case RoutePaths.languageList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => LanguageListView(),
      );

    case RoutePaths.languagesetting:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => LanguageSettingContainerView(),
      );

  // ----------------------------------------------------------------------
  // Category / SubCategory
  // ----------------------------------------------------------------------

    case RoutePaths.subCategoryGrid:
      return MaterialPageRoute<Category>(
        builder: (BuildContext context) {
          final Category category = settings.arguments as Category; // required
          return SubCategoryGridView(category: category);
        },
      );


  // ----------------------------------------------------------------------
  // Notifications
  // ----------------------------------------------------------------------

    case RoutePaths.notiList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NotiListContainerView(),
      );

    case RoutePaths.offerList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => OfferContainerView(),
      );

    case RoutePaths.blockUserList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => BlockUserContainerView(),
      );

    case RoutePaths.reportItemList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ReportItemContainerView(),
      );

    case RoutePaths.followingUserList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => FollowingUserListView(),
      );

    case RoutePaths.followerUserList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => FollowerUserListView(),
      );

    case RoutePaths.detailfollowingUserList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String userId =
          (settings.arguments ?? '') as String; // empty if null
          return DetailFollowingUserListView(userId: userId);
        },
      );

    case RoutePaths.detailfollowerUserList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String userId =
          (settings.arguments ?? '') as String; // empty if null
          return DetailFollowerUserListView(userId: userId);
        },
      );

    case RoutePaths.chatListScreen:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const ChatListScreen(),
      );



  // NOTE:
  // This route name suggests "itemEntryView" but currently opens ChatView.
  // Future Improvement: Review this route; may need to rename or redirect
  // to the correct item entry screen.
   /*case RoutePaths.itemEntryView:
      return MaterialPageRoute<dynamic>(
        settings: const RouteSettings(name: RoutePaths.itemEntryView),
        builder: (BuildContext context) {
          final ChatHistoryIntentHolder holder =
          settings.arguments as ChatHistoryIntentHolder;
          return ChatView(
            chatFlag: holder.chatFlag,
            itemId: holder.itemId,
            buyerUserId: holder.buyerUserId,
            sellerUserId: holder.sellerUserId,
          );
        },
      );*/

    case RoutePaths.notiSetting:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NotificationSettingView(),
      );

    case RoutePaths.setting:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => SettingContainerView(),
      );

    case RoutePaths.more:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String userName =
          (settings.arguments ?? '') as String; // empty if null
          return MoreContainerView(userName: userName);
        },
      );

    case RoutePaths.noti:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final Noti noti = settings.arguments as Noti;
          return NotiView(noti: noti);
        },
      );

    case RoutePaths.cameraSetting:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => CameraSettingView(),
      );


  // ----------------------------------------------------------------------
  // Item list & filters
  // ----------------------------------------------------------------------

    case RoutePaths.filterProductList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final ProductListIntentHolder holder =
          settings.arguments as ProductListIntentHolder;
          return ProductListWithFilterContainerView(
            appBarTitle: holder.appBarTitle,
            productParameterHolder: holder.productParameterHolder,
            tabTitleItem: Utils.getString(context, 'search_filter__item'),
            tabTitleAccount: Utils.getString(context, 'search_filter__account'),
          );
        },
      );

    case RoutePaths.nearestProductList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final ProductListIntentHolder holder =
          settings.arguments as ProductListIntentHolder;
          return NearestProductListView(
            appBarTitle: holder.appBarTitle,
            productParameterHolder: holder.productParameterHolder,
            tabTitleItem: Utils.getString(context, 'search_filter__item'),
            tabTitleAccount: Utils.getString(context, 'search_filter__account'),
          );
        },
      );

    case RoutePaths.filterLocationList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final LocationParameterHolder holder =
          settings.arguments as LocationParameterHolder;
          return FilterLocationView(locationParameterHolder: holder);
        },
      );

    case RoutePaths.privacyPolicy:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final int policyType = settings.arguments as int? ?? 0;
          return SettingPrivacyPolicyView(checkPolicyType: policyType);
        },
      );

    case RoutePaths.termsAndCondition:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const SettingTermsAndCondition(),
      );

    case RoutePaths.faq:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const SettingFAQView(),
      );

  // ----------------------------------------------------------------------
  // Blog
  // ----------------------------------------------------------------------

    case RoutePaths.appinfo:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => AppInfoView(),
      );

  // ----------------------------------------------------------------------
  // Paid Ads / History / User Items
  // ----------------------------------------------------------------------

    case RoutePaths.paidAdItemList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => PaidItemListContainerView(),
      );




    case RoutePaths.historyList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => HistoryListContainerView(),
      );

    case RoutePaths.productDetail:
      final ProductDetailIntentHolder holder =
      settings.arguments as ProductDetailIntentHolder;
      return MaterialPageRoute<dynamic>(
        settings: const RouteSettings(name: RoutePaths.productDetail),
        builder: (BuildContext context) => ProductDetailView(
          productId: holder.productId,
          heroTagImage: holder.heroTagImage,
          heroTagTitle: holder.heroTagTitle,
        ),
      );

    case RoutePaths.filterExpantion:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final dynamic args = settings.arguments;
          return FilterListView(selectedData: args);
        },
      );

    case RoutePaths.itemSearch:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final ProductParameterHolder holder =
          settings.arguments as ProductParameterHolder;
          return ItemSearchView(productParameterHolder: holder);
        },
      );




    case RoutePaths.addSwapOffer:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final Map<dynamic, dynamic> args =
          settings.arguments as Map<dynamic, dynamic>;
          return AddSwapOfferScreen(args: args);
        },
      );

    case RoutePaths.packageTransactionHistoryList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => BuyAdTransactionContainerView(),
      );

    case RoutePaths.favouriteProductList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => FavouriteProductListContainerView(),
      );



    case RoutePaths.ratingList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final String itemUserId =
          (settings.arguments ?? '') as String; // empty if null
          return RatingListView(itemUserId: itemUserId);
        },
      );

    case RoutePaths.editProfile:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => EditProfileView(),
      );

  // ----------------------------------------------------------------------
  // Gallery / Media
  // ----------------------------------------------------------------------


   /* case RoutePaths.chatImageDetailView:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final Message message = settings.arguments as Message;
          return ChatImageDetailView(messageObj: message);
        },
      );*/

  // ----------------------------------------------------------------------
  // User detail / profiles
  // ----------------------------------------------------------------------

    case RoutePaths.userDetail:
      return MaterialPageRoute<dynamic>(
        settings: const RouteSettings(name: RoutePaths.userDetail),
        builder: (BuildContext context) {
          final UserIntentHolder holder =
          settings.arguments as UserIntentHolder;
          return UserDetailView(
            userName: holder.userName,
            userId: holder.userId,
          );
        },
      );

    case RoutePaths.safetyTips:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final SafetyTipsIntentHolder holder =
          settings.arguments as SafetyTipsIntentHolder;
          return SafetyTipsView(
            animationController: holder.animationController,
            safetyTips: holder.safetyTips,
          );
        },
      );

    case RoutePaths.itemLocationList:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ItemLocationContainerView(),
      );

    case RoutePaths.itemEntry:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final args = settings.arguments;

          final ItemEntryIntentHolder holder = (args is ItemEntryIntentHolder)
              ? args
              : ItemEntryIntentHolder(
            flag: PsConst.ADD_NEW_ITEM, // default safe
            item: null,
          );

          return ItemEntryContainerView(
            flag: holder.flag,
            item: holder.item,
          );
        },
      );

    case RoutePaths.wishItemEntry:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return WishItemEntryContainerView(
            flag: PsConst.ADD_NEW_ITEM,
            item: Product(),
          );
        },
      );




    case RoutePaths.itemType:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const TypeListView(
          showAllText: true,
        ),
      );

    case RoutePaths.itemCondition:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ItemConditionView(),
      );

    case RoutePaths.itemPriceType:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ItemPriceTypeView(),
      );


    case RoutePaths.itemDealOption:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ItemDealOptionView(),
      );

    case RoutePaths.itemSoldOut:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ItemSoldOutView(),
      );

    case RoutePaths.itemLocationFirst:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ItemLocationFirstView(),
      );

    case RoutePaths.itemPromote:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final Product product = settings.arguments as Product;
          return ItemPromoteView(product: product);
        },
      );

    case RoutePaths.choosePayment:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          final Map<String, dynamic> args =
          settings.arguments as Map<String, dynamic>;
          final Product? product = args['product'];
          final PSAppInfo appInfo = args['appInfo'];
          // Future Improvement: Strongly type this arguments map
          // to avoid runtime key/typing issues.
          return ChoosePaymentVIew(product: product, appInfo: appInfo);
        },
      );

    case RoutePaths.CategoryView:
      return MaterialPageRoute<Category>(
        builder: (BuildContext context) {
          final Map<String, dynamic> args =
          settings.arguments as Map<String, dynamic>;
          final GestureTapCallback? onTap = args['onTap'];
          final bool onBoarding = args['onBoarding'];
          final bool home = args['Discover'];
          return CategoryListView(
            onTap: onTap,
            onBoarding: onBoarding,
            home: home,
          );
        },
      );




  // ── NEW: Received swap requests (from notification deep link) ─────────────
  // Routes to OfferContainerView which shows all swap/offer requests.
    case RoutePaths.receivedSwapRequests:
    case RoutePaths.sentSwapRequests:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => OfferContainerView(),
      );

  // ── NEW: Follow requests (from notification deep link) ────────────────────
    case RoutePaths.followRequests:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => FollowRequestsScreen(baseUrl: '',),
      );

  // ── NEW: notificationSetting alias ────────────────────────────────────────
    case RoutePaths.notificationSetting:
      return MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => NotificationSettingView(),
      );

    default:
    // Future Improvement: Add a dedicated "UnknownRoute" screen
    // to help debugging and analytics.
      return PageRouteBuilder<dynamic>(
        pageBuilder: (_, Animation<double> a1, Animation<double> a2) =>
            AppLoadingView(),
      );
  }
}
