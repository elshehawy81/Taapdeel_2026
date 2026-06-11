import 'package:flutter/material.dart';
import 'package:taapdeel/api/ps_api_service.dart';
import 'package:taapdeel/db/about_us_dao.dart';
import 'package:taapdeel/db/blocked_user_dao.dart';
import 'package:taapdeel/db/blog_dao.dart';
import 'package:taapdeel/db/category_map_dao.dart';
import 'package:taapdeel/db/cateogry_dao.dart';
import 'package:taapdeel/db/chat_history_dao.dart';
import 'package:taapdeel/db/common/ps_shared_preferences.dart';
import 'package:taapdeel/db/deal_option_dao.dart';
import 'package:taapdeel/db/favourite_product_dao.dart';
import 'package:taapdeel/db/follower_item_dao.dart';
import 'package:taapdeel/db/gallery_dao.dart';
import 'package:taapdeel/db/history_dao.dart';
import 'package:taapdeel/db/item_condition_dao.dart';
import 'package:taapdeel/db/item_currency_dao.dart';
import 'package:taapdeel/db/item_loacation_dao.dart';
import 'package:taapdeel/db/item_loacation_township_dao.dart';
import 'package:taapdeel/db/item_price_type_dao.dart';
import 'package:taapdeel/db/item_type_dao.dart';
import 'package:taapdeel/db/noti_dao.dart';
import 'package:taapdeel/db/offer_dao.dart';
import 'package:taapdeel/db/offline_payment_method_dao.dart';
import 'package:taapdeel/db/package_bought_transaction_dao.dart';
import 'package:taapdeel/db/package_dao.dart';
import 'package:taapdeel/db/paid_ad_item_dao.dart';
import 'package:taapdeel/db/product_dao.dart';
import 'package:taapdeel/db/product_map_dao.dart';
import 'package:taapdeel/db/rating_dao.dart';
import 'package:taapdeel/db/related_product_dao.dart';
import 'package:taapdeel/db/reported_item_dao.dart';
import 'package:taapdeel/db/sold_out_item_dao.dart';
import 'package:taapdeel/db/sub_category_dao.dart';
import 'package:taapdeel/db/user_dao.dart';
import 'package:taapdeel/db/user_login_dao.dart';
import 'package:taapdeel/db/user_map_dao.dart';
import 'package:taapdeel/db/user_unread_message_dao.dart';
import 'package:taapdeel/provider/SwapProductsProvider.dart';
import 'package:taapdeel/repository/Common/notification_repository.dart';
import 'package:taapdeel/repository/about_us_repository.dart';
import 'package:taapdeel/repository/app_info_repository.dart';
import 'package:taapdeel/repository/blocked_user_repository.dart';
import 'package:taapdeel/repository/blog_repository.dart';
import 'package:taapdeel/repository/category_repository.dart';
import 'package:taapdeel/repository/chat_history_repository.dart';
import 'package:taapdeel/repository/clear_all_data_repository.dart';
import 'package:taapdeel/repository/contact_us_repository.dart';
import 'package:taapdeel/repository/delete_task_repository.dart';
import 'package:taapdeel/repository/gallery_repository.dart';
import 'package:taapdeel/repository/history_repsitory.dart';
import 'package:taapdeel/repository/item_condition_repository.dart';
import 'package:taapdeel/repository/item_deal_option_repository.dart';
import 'package:taapdeel/repository/item_location_repository.dart';
import 'package:taapdeel/repository/item_location_township_repository.dart';
import 'package:taapdeel/repository/item_paid_history_repository.dart';
import 'package:taapdeel/repository/item_price_type_repository.dart';
import 'package:taapdeel/repository/item_type_repository.dart';
import 'package:taapdeel/repository/language_repository.dart';
import 'package:taapdeel/repository/noti_repository.dart';
import 'package:taapdeel/repository/offer_repository.dart';
import 'package:taapdeel/repository/package_bought_repository.dart';
import 'package:taapdeel/repository/package_bought_transaction_history_repository.dart';
import 'package:taapdeel/repository/paid_ad_item_repository.dart';
import 'package:taapdeel/repository/product_repository.dart';
import 'package:taapdeel/repository/ps_theme_repository.dart';
import 'package:taapdeel/repository/rating_repository.dart';
import 'package:taapdeel/repository/reported_item_repository.dart';
import 'package:taapdeel/repository/search_user_repository.dart';
import 'package:taapdeel/repository/sold_out_item_repository.dart';
import 'package:taapdeel/repository/sub_category_repository.dart';
import 'package:taapdeel/repository/user_repository.dart';
import 'package:taapdeel/repository/user_unread_message_repository.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// ✅ FIX: استبدلنا ProxyProvider بـ ProxyProvider مع حماية "don't recreate"
// الـ pattern الصح: لو الـ previous != null → رجّع القديم، متعملش instance جديدة
// ده بيمنع الـ dispose المتكرر ويوقف الـ skipped frames اللي سببها إعادة بناء ~30 repo

List<SingleChildWidget> providers = <SingleChildWidget>[
  ...independentProviders,
  ..._dependentProviders,
  ..._valueProviders,
];

List<SingleChildWidget> independentProviders = <SingleChildWidget>[
  Provider<PsSharedPreferences>.value(value: PsSharedPreferences.instance),
  Provider<PsApiService>.value(value: PsApiService()),
  Provider<CategoryDao>.value(value: CategoryDao()),
  Provider<CategoryMapDao>.value(value: CategoryMapDao.instance),
  Provider<UserMapDao>.value(value: UserMapDao.instance),
  Provider<SubCategoryDao>.value(value: SubCategoryDao()),
  Provider<ProductDao>.value(value: ProductDao.instance),
  Provider<ProductMapDao>.value(value: ProductMapDao.instance),
  Provider<NotiDao>.value(value: NotiDao.instance),
  Provider<OfflinePaymentMethodDao>.value(value: OfflinePaymentMethodDao.instance),
  Provider<AboutUsDao>.value(value: AboutUsDao.instance),
  Provider<PackageDao>.value(value: PackageDao.instance),
  Provider<PackageTransactionDao>.value(value: PackageTransactionDao.instance),
  Provider<BlogDao>.value(value: BlogDao.instance),
  Provider<UserDao>.value(value: UserDao.instance),
  Provider<UserLoginDao>.value(value: UserLoginDao.instance),
  Provider<RelatedProductDao>.value(value: RelatedProductDao.instance),
  Provider<RatingDao>.value(value: RatingDao.instance),
  Provider<ItemLocationDao>.value(value: ItemLocationDao.instance),
  Provider<ItemLocationTownshipDao>.value(value: ItemLocationTownshipDao.instance),
  Provider<PaidAdItemDao>.value(value: PaidAdItemDao.instance),
  Provider<HistoryDao>.value(value: HistoryDao.instance),
  Provider<GalleryDao>.value(value: GalleryDao.instance),
  Provider<FavouriteProductDao>.value(value: FavouriteProductDao.instance),
  Provider<ChatHistoryDao>.value(value: ChatHistoryDao.instance),
  Provider<OfferDao>.value(value: OfferDao.instance),
  Provider<FollowerItemDao>.value(value: FollowerItemDao.instance),
  Provider<ItemTypeDao>.value(value: ItemTypeDao()),
  Provider<ItemConditionDao>.value(value: ItemConditionDao()),
  Provider<ItemPriceTypeDao>.value(value: ItemPriceTypeDao()),
  Provider<ItemCurrencyDao>.value(value: ItemCurrencyDao()),
  Provider<ItemDealOptionDao>.value(value: ItemDealOptionDao()),
  Provider<UserUnreadMessageDao>.value(value: UserUnreadMessageDao.instance),
  Provider<BlockedUserDao>.value(value: BlockedUserDao.instance),
  Provider<ReportedItemDao>.value(value: ReportedItemDao.instance),
  Provider<SoldOutItemDao>.value(value: SoldOutItemDao.instance),
];

List<SingleChildWidget> _dependentProviders = <SingleChildWidget>[
  // ✅ كل ProxyProvider دلوقتي بيرجع الـ instance القديمة لو موجودة
  // بدل ما يعمل new instance في كل rebuild → بيوقف الـ dispose المتكرر

  ProxyProvider<PsSharedPreferences, PsThemeRepository>(
    update: (_, PsSharedPreferences sp, PsThemeRepository? prev) =>
    prev ?? PsThemeRepository(psSharedPreferences: sp),
  ),
  ProxyProvider<PsApiService, AppInfoRepository>(
    update: (_, PsApiService api, AppInfoRepository? prev) =>
    prev ?? AppInfoRepository(psApiService: api),
  ),
  ProxyProvider<PsSharedPreferences, SwapProductsProvider>(
    update: (_, PsSharedPreferences sp, SwapProductsProvider? prev) =>
    prev ?? SwapProductsProvider(sharedPref: sp),
  ),
  ProxyProvider<PsSharedPreferences, LanguageRepository>(
    update: (_, PsSharedPreferences sp, LanguageRepository? prev) =>
    prev ?? LanguageRepository(psSharedPreferences: sp),
  ),
  ProxyProvider<PsApiService, NotificationRepository>(
    update: (_, PsApiService api, NotificationRepository? prev) =>
    prev ?? NotificationRepository(psApiService: api),
  ),
  ProxyProvider<PsApiService, ItemPaidHistoryRepository>(
    update: (_, PsApiService api, ItemPaidHistoryRepository? prev) =>
    prev ?? ItemPaidHistoryRepository(psApiService: api),
  ),
  ProxyProvider2<PsApiService, CategoryDao, ClearAllDataRepository>(
    update: (_, PsApiService api, CategoryDao dao, ClearAllDataRepository? prev) =>
    prev ?? ClearAllDataRepository(),
  ),
  ProxyProvider<PsApiService, DeleteTaskRepository>(
    update: (_, PsApiService api, DeleteTaskRepository? prev) =>
    prev ?? DeleteTaskRepository(),
  ),
  ProxyProvider<PsApiService, ContactUsRepository>(
    update: (_, PsApiService api, ContactUsRepository? prev) =>
    prev ?? ContactUsRepository(psApiService: api),
  ),
  ProxyProvider2<PsApiService, ItemLocationTownshipDao, ItemLocationTownshipRepository>(
    update: (_, PsApiService api, ItemLocationTownshipDao dao, ItemLocationTownshipRepository? prev) =>
    prev ?? ItemLocationTownshipRepository(psApiService: api, itemLocationTownshipDao: dao),
  ),
  ProxyProvider2<PsApiService, CategoryDao, CategoryRepository>(
    update: (_, PsApiService api, CategoryDao dao, CategoryRepository? prev) =>
    prev ?? CategoryRepository(psApiService: api, categoryDao: dao),
  ),
  ProxyProvider2<PsApiService, UserDao, SearchUserRepository>(
    update: (_, PsApiService api, UserDao dao, SearchUserRepository? prev) =>
    prev ?? SearchUserRepository(psApiService: api, userDao: dao),
  ),
  ProxyProvider2<PsApiService, SubCategoryDao, SubCategoryRepository>(
    update: (_, PsApiService api, SubCategoryDao dao, SubCategoryRepository? prev) =>
    prev ?? SubCategoryRepository(psApiService: api, subCategoryDao: dao),
  ),
  ProxyProvider2<PsApiService, ProductDao, ProductRepository>(
    update: (_, PsApiService api, ProductDao dao, ProductRepository? prev) =>
    prev ?? ProductRepository(psApiService: api, productDao: dao),
  ),
  ProxyProvider2<PsApiService, NotiDao, NotiRepository>(
    update: (_, PsApiService api, NotiDao dao, NotiRepository? prev) =>
    prev ?? NotiRepository(psApiService: api, notiDao: dao),
  ),
  ProxyProvider2<PsApiService, AboutUsDao, AboutUsRepository>(
    update: (_, PsApiService api, AboutUsDao dao, AboutUsRepository? prev) =>
    prev ?? AboutUsRepository(psApiService: api, aboutUsDao: dao),
  ),
  ProxyProvider2<PsApiService, PackageDao, PackageBoughtRepository>(
    update: (_, PsApiService api, PackageDao dao, PackageBoughtRepository? prev) =>
    prev ?? PackageBoughtRepository(psApiService: api, packageDao: dao),
  ),
  ProxyProvider2<PsApiService, PackageTransactionDao, PackageTranscationHistoryRepository>(
    update: (_, PsApiService api, PackageTransactionDao dao, PackageTranscationHistoryRepository? prev) =>
    prev ?? PackageTranscationHistoryRepository(psApiService: api, transactionDao: dao),
  ),
  ProxyProvider2<PsApiService, BlogDao, BlogRepository>(
    update: (_, PsApiService api, BlogDao dao, BlogRepository? prev) =>
    prev ?? BlogRepository(psApiService: api, blogDao: dao),
  ),
  ProxyProvider2<PsApiService, BlockedUserDao, BlockedUserRepository>(
    update: (_, PsApiService api, BlockedUserDao dao, BlockedUserRepository? prev) =>
    prev ?? BlockedUserRepository(psApiService: api, blockedUserDao: dao),
  ),
  ProxyProvider2<PsApiService, ItemLocationDao, ItemLocationRepository>(
    update: (_, PsApiService api, ItemLocationDao dao, ItemLocationRepository? prev) =>
    prev ?? ItemLocationRepository(psApiService: api, itemLocationDao: dao),
  ),
  ProxyProvider2<PsApiService, ItemTypeDao, ItemTypeRepository>(
    update: (_, PsApiService api, ItemTypeDao dao, ItemTypeRepository? prev) =>
    prev ?? ItemTypeRepository(psApiService: api, itemTypeDao: dao),
  ),
  ProxyProvider2<PsApiService, ReportedItemDao, ReportedItemRepository>(
    update: (_, PsApiService api, ReportedItemDao dao, ReportedItemRepository? prev) =>
    prev ?? ReportedItemRepository(psApiService: api, reportedItemDao: dao),
  ),
  ProxyProvider2<PsApiService, ItemConditionDao, ItemConditionRepository>(
    update: (_, PsApiService api, ItemConditionDao dao, ItemConditionRepository? prev) =>
    prev ?? ItemConditionRepository(psApiService: api, itemConditionDao: dao),
  ),
  ProxyProvider2<PsApiService, ItemPriceTypeDao, ItemPriceTypeRepository>(
    update: (_, PsApiService api, ItemPriceTypeDao dao, ItemPriceTypeRepository? prev) =>
    prev ?? ItemPriceTypeRepository(psApiService: api, itemPriceTypeDao: dao),
  ),
  ProxyProvider2<PsApiService, ItemDealOptionDao, ItemDealOptionRepository>(
    update: (_, PsApiService api, ItemDealOptionDao dao, ItemDealOptionRepository? prev) =>
    prev ?? ItemDealOptionRepository(psApiService: api, itemDealOptionDao: dao),
  ),
  ProxyProvider2<PsApiService, ChatHistoryDao, ChatHistoryRepository>(
    update: (_, PsApiService api, ChatHistoryDao dao, ChatHistoryRepository? prev) =>
    prev ?? ChatHistoryRepository(psApiService: api, chatHistoryDao: dao),
  ),
  ProxyProvider2<PsApiService, OfferDao, OfferRepository>(
    update: (_, PsApiService api, OfferDao dao, OfferRepository? prev) =>
    prev ?? OfferRepository(psApiService: api, offerDao: dao),
  ),
  ProxyProvider2<PsApiService, UserUnreadMessageDao, UserUnreadMessageRepository>(
    update: (_, PsApiService api, UserUnreadMessageDao dao, UserUnreadMessageRepository? prev) =>
    prev ?? UserUnreadMessageRepository(psApiService: api, userUnreadMessageDao: dao),
  ),
  ProxyProvider2<PsApiService, RatingDao, RatingRepository>(
    update: (_, PsApiService api, RatingDao dao, RatingRepository? prev) =>
    prev ?? RatingRepository(psApiService: api, ratingDao: dao),
  ),
  ProxyProvider2<PsApiService, PaidAdItemDao, PaidAdItemRepository>(
    update: (_, PsApiService api, PaidAdItemDao dao, PaidAdItemRepository? prev) =>
    prev ?? PaidAdItemRepository(psApiService: api, paidAdItemDao: dao),
  ),
  ProxyProvider2<PsApiService, HistoryDao, HistoryRepository>(
    update: (_, PsApiService api, HistoryDao dao, HistoryRepository? prev) =>
    prev ?? HistoryRepository(historyDao: dao),
  ),
  ProxyProvider2<PsApiService, GalleryDao, GalleryRepository>(
    update: (_, PsApiService api, GalleryDao dao, GalleryRepository? prev) =>
    prev ?? GalleryRepository(galleryDao: dao, psApiService: api),
  ),
  ProxyProvider3<PsApiService, UserDao, UserLoginDao, UserRepository>(
    update: (_, PsApiService api, UserDao userDao, UserLoginDao loginDao, UserRepository? prev) =>
    prev ?? UserRepository(psApiService: api, userDao: userDao, userLoginDao: loginDao),
  ),
  ProxyProvider2<PsApiService, SoldOutItemDao, SoldOutItemRepository>(
    update: (_, PsApiService api, SoldOutItemDao dao, SoldOutItemRepository? prev) =>
    prev ?? SoldOutItemRepository(psApiService: api, soldOutItemDao: dao),
  ),
];

List<SingleChildWidget> _valueProviders = <SingleChildWidget>[
  StreamProvider<PsValueHolder?>(
    initialData: null,
    create: (BuildContext context) =>
    Provider.of<PsSharedPreferences>(context, listen: false).psValueHolder,
  ),
];