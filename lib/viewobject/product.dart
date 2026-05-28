import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/common/ps_object.dart';
import 'package:taapdeel/viewobject/condition_of_item.dart';
import 'package:taapdeel/viewobject/deal_option.dart';
import 'package:taapdeel/viewobject/item_currency.dart';
import 'package:taapdeel/viewobject/item_location.dart';
import 'package:taapdeel/viewobject/item_price_type.dart';
import 'package:taapdeel/viewobject/item_type.dart';
import 'package:taapdeel/viewobject/rating_detail.dart';
import 'package:taapdeel/viewobject/sub_category.dart';
import 'package:taapdeel/viewobject/user.dart';
import 'package:quiver/core.dart';

import 'default_photo.dart';
import 'item_location_township.dart';

class Product extends PsObject<Product> {
  Product({
    this.id,
    this.catId,
    this.subCatId,
    this.itemTypeId,
    this.itemPriceTypeId,
    this.itemCurrencyId,
    this.itemLocationId,
    this.itemLocationTownshipId,
    this.conditionOfItemId,
    this.dealOptionRemark,
    this.description,
    this.highlightInformation,
    this.price,
    this.dealOptionId,
    this.brand,
    this.businessMode,
    this.isSoldOut,
    this.title,
    this.address,
    this.lat,
    this.lng,
    this.status,
    this.addedDate,
    this.addedUserId,
    this.updatedDate,
    this.updatedUserId,
    this.updatedFlag,
    this.touchCount,
    this.favouriteCount,
    this.isPaid,
    this.dynamicLink,
    this.addedDateStr,
    this.paidStatus,
    this.photoCount,
    this.defaultPhoto,
    this.image,
    this.imgPath,
    this.fullPath,
    this.video,
    this.videoThumbnail,
    this.category,
    this.subCategory,
    this.itemType,
    this.itemPriceType,
    this.itemCurrency,
    this.itemLocation,
    this.itemLocationTownship,
    this.conditionOfItem,
    this.dealOption,
    this.user,
    this.ratingDetail,
    this.isFavourited,
    this.isOwner,
    this.discountRate,
    this.discountedPrice,
    this.lowPrice,
    this.highPrice,
    this.interestMatchType,
    this.interestOwnerUserId,
    this.interestOwnerName,
    this.interestOwnerRelationType,
    this.interestOwnerRelationLabel,
    // ✅ NEW swap/relation
    this.relationCode,
    this.relationType,
    this.swapScore,
    this.swapScorePercent,
    this.swapLabel,
    this.swapScoreBreakdown,

    // ✅ Hawadeet Taapdeel / Wish story fields
    this.hawadeetId,
    this.storyTitle,
    this.hookPhrase,
    this.storyText,
    this.narratorComment,
    this.storyType,
    this.personaType,
    this.needReason,
    this.occasion,
    this.genderTarget,
    this.ageMin,
    this.ageMax,
    this.familyRoleTarget,
    this.meTooCount,
    this.shareCount,
    this.offerCount,
    this.hawadeetStatus,
    this.userReactedMeToo,
    this.storyThemeId,
    this.roleOneLabel,
    this.roleTwoLabel,
    this.dialogueOne,
    this.dialogueTwo,
    this.storyCardTitle,
    this.happenedLikeMeCount,
    this.userReactedHappenedLikeMe,
    this.adType,
  });

  String? id;
  String? catId;
  String? subCatId;
  String? itemTypeId;
  String? itemPriceTypeId;
  String? itemCurrencyId;
  String? itemLocationId;
  String? itemLocationTownshipId;
  String? conditionOfItemId;
  String? dealOptionRemark;
  String? description;
  String? highlightInformation;
  String? price;
  String? lowPrice;
  String? highPrice;
  String? dealOptionId;
  String? brand;
  String? businessMode;
  String? isSoldOut;
  String? title;
  String? address;
  String? lat;
  String? lng;
  String? status;
  String? addedDate;
  String? addedUserId;
  String? updatedDate;
  String? updatedUserId;
  String? updatedFlag;
  String? touchCount;
  String? favouriteCount;
  String? isPaid;
  String? dynamicLink;
  String? addedDateStr;
  String? paidStatus;
  String? photoCount;
  String? isFavourited;
  String? isOwner;
  String? discountRate;
  String? discountedPrice;
  String? interestMatchType;
  String? interestOwnerUserId;
  String? interestOwnerName;
  String? interestOwnerRelationType;
  String? interestOwnerRelationLabel;
  DefaultPhoto? defaultPhoto;

  // ✅ Direct image fields returned by wishlist APIs.
  // Wish items often return img_path/image while default_photo is empty.
  String? image;
  String? imgPath;
  String? fullPath;

  DefaultPhoto? video;
  DefaultPhoto? videoThumbnail;

  Category? category;
  SubCategory? subCategory;
  ItemType? itemType;
  ItemPriceType? itemPriceType;
  ItemCurrency? itemCurrency;
  ItemLocation? itemLocation;
  ItemLocationTownship? itemLocationTownship;
  ConditionOfItem? conditionOfItem;
  DealOption? dealOption;
  User? user;
  RatingDetail? ratingDetail;

  String? adType;

  // ✅ relation + swap score (backend fields)
  String? relationCode;
  String? relationType; // backend int but returned as string غالبًا

  String? swapScore;
  String? swapScorePercent;
  String? swapLabel;
  List<dynamic>? swapScoreBreakdown;

  // ✅ Hawadeet Taapdeel / Wish story fields
  // These fields are returned by items_wishlist/get_wishlist_items when a
  // wishlist item has a related row in bs_hawadeet. Keeping them here is
  // intentional because the Discover/Home sections parse wishlist API items
  // through Product, not Wishlist_model.dart.
  String? hawadeetId;
  String? storyTitle;
  String? hookPhrase;
  String? storyText;
  String? narratorComment;
  String? storyType;
  String? personaType;
  String? needReason;
  String? occasion;
  String? genderTarget;
  String? ageMin;
  String? ageMax;
  String? familyRoleTarget;
  String? meTooCount;
  String? shareCount;
  String? offerCount;
  String? hawadeetStatus;
  String? userReactedMeToo;
  String? storyThemeId;
  String? roleOneLabel;
  String? roleTwoLabel;
  String? dialogueOne;
  String? dialogueTwo;
  String? storyCardTitle;
  String? happenedLikeMeCount;
  String? userReactedHappenedLikeMe;
  bool get hasHawadeetStory {
    final String hId = (hawadeetId ?? '').trim();
    final String sTitle = (storyTitle ?? '').trim();
    final String hPhrase = (hookPhrase ?? '').trim();
    final String sText = (storyText ?? '').trim();
    final String dOne = (dialogueOne ?? '').trim();
    final String dTwo = (dialogueTwo ?? '').trim();
    final String sType = (storyType ?? '').trim();

    return hId.isNotEmpty ||
        sTitle.isNotEmpty ||
        hPhrase.isNotEmpty ||
        sText.isNotEmpty ||
        dOne.isNotEmpty ||
        dTwo.isNotEmpty ||
        sType == 'official' ||
        sType == 'user_generated' ||
        sType == 'template';
  }

  int get meTooCountInt => int.tryParse((meTooCount ?? '').trim()) ?? 0;
  int get happenedLikeMeCountInt =>
      int.tryParse((happenedLikeMeCount ?? '').trim()) ?? 0;
  int get shareCountInt => int.tryParse((shareCount ?? '').trim()) ?? 0;
  int get offerCountInt => int.tryParse((offerCount ?? '').trim()) ?? 0;

  // ======================================================
  // ✅ Helpers for UI
  // ======================================================
  int get swapPercentInt => int.tryParse((swapScorePercent ?? '').trim()) ?? 0;
  int get swapScoreInt => int.tryParse((swapScore ?? '').trim()) ?? 0;

  List<Map<String, dynamic>> get swapBreakdownList {
    final raw = swapScoreBreakdown ?? <dynamic>[];
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(Map<String, dynamic>.from(e as Map));
      }
    }
    return out;
  }

  @override
  bool operator ==(dynamic other) => other is Product && id == other.id;

  @override
  int get hashCode => hash2(id.hashCode, runtimeType.hashCode);

  @override
  String? getPrimaryKey() => id;

  @override
  Product fromMap(dynamic dynamicData) {
    // guard
    if (dynamicData == null) return Product();

    // ✅ breakdown safe parse
    List<dynamic> breakdown = <dynamic>[];
    final bd = dynamicData['swap_score_breakdown'];
    if (bd is List) {
      breakdown = bd;
    }

    return Product(
      id: dynamicData['id'],
      catId: dynamicData['cat_id'],
      subCatId: dynamicData['sub_cat_id'],
      itemTypeId: dynamicData['item_type_id'] ?? '',
      itemPriceTypeId: dynamicData['item_price_type_id'] ?? '',
      itemLocationId: dynamicData['item_location_id'] ?? '',
      itemLocationTownshipId: dynamicData['item_location_township_id'] ?? '',
      conditionOfItemId: dynamicData['condition_of_item_id'] ?? '',
      dealOptionRemark: dynamicData['deal_option_remark'] ?? '',
      description: dynamicData['description'] ?? '',
      highlightInformation: dynamicData['highlight_info'] ?? '',
      price: dynamicData['price'] ?? '',
      lowPrice: dynamicData['low_price']?.toString() ?? '',
      highPrice: dynamicData['high_price']?.toString() ?? '',
      dealOptionId: dynamicData['deal_option_id'] ?? '',
      brand: dynamicData['brand'] ?? '',
      businessMode: dynamicData['business_mode'] ?? '',
      isSoldOut: dynamicData['is_sold_out'] ?? '',
      title: dynamicData['title'] ?? '',
      address: dynamicData['address'] ?? '',
      lat: dynamicData['lat'] ?? '',
      lng: dynamicData['lng'] ?? '',
      status: dynamicData['status'] ?? '',
      addedDate: dynamicData['added_date'] ?? '',
      addedUserId: dynamicData['added_user_id'] ?? '',
      updatedDate: dynamicData['updated_date'] ?? '',
      updatedUserId: dynamicData['updated_user_id'] ?? '',
      updatedFlag: dynamicData['updated_flag'] ?? '',
      touchCount: dynamicData['touch_count'] ?? '',
      favouriteCount: dynamicData['favourite_count'] ?? '',
      isPaid: dynamicData['is_paid'] ?? '',
      dynamicLink: dynamicData['dynamic_link'] ?? '',
      addedDateStr: dynamicData['added_date_str'] ?? '',
      paidStatus: dynamicData['paid_status'] ?? '',
      photoCount: dynamicData['photo_count']?.toString() ?? '',
      isFavourited: dynamicData['is_favourited']?.toString() ?? '',
      isOwner: dynamicData['is_owner']?.toString() ?? '',
      discountRate: dynamicData['discount_rate_by_percentage'] ?? '',
      discountedPrice: dynamicData['discounted_price'] ?? '',
      interestMatchType: dynamicData['interest_match_type']?.toString(),
      interestOwnerUserId: dynamicData['interest_owner_user_id']?.toString(),
      interestOwnerName: dynamicData['interest_owner_name']?.toString(),
      interestOwnerRelationType: dynamicData['interest_owner_relation_type']?.toString(),
      interestOwnerRelationLabel: dynamicData['interest_owner_relation_label']?.toString(),
      defaultPhoto: DefaultPhoto().fromMap(dynamicData['default_photo']),
      image: dynamicData['image']?.toString(),
      imgPath: dynamicData['img_path']?.toString() ?? dynamicData['imgPath']?.toString(),
      fullPath: dynamicData['full_path']?.toString() ?? dynamicData['fullPath']?.toString(),
      video: DefaultPhoto().fromMap(dynamicData['default_video']),
      videoThumbnail: DefaultPhoto().fromMap(dynamicData['default_video_icon']),

      category: Category().fromMap(dynamicData['category']),
      subCategory: SubCategory().fromMap(dynamicData['sub_category']),
      itemType: ItemType().fromMap(dynamicData['item_type'] ?? ""),
      itemPriceType: ItemPriceType().fromMap(dynamicData['item_price_type']),
      itemCurrency: ItemCurrency().fromMap(dynamicData['item_currency']),
      itemLocation: ItemLocation().fromMap(dynamicData['item_location']),
      itemLocationTownship:
      ItemLocationTownship().fromMap(dynamicData['item_location_township']),
      conditionOfItem: ConditionOfItem().fromMap(dynamicData['condition_of_item']),
      dealOption: DealOption().fromMap(dynamicData['deal_option']),
      user: User().fromMap(dynamicData['user']),
      ratingDetail: RatingDetail().fromMap(dynamicData['rating_details']),
      adType: dynamicData['ad_type'],

      // ✅ NEW fields
      relationCode: dynamicData['relation_code']?.toString(),
      relationType: dynamicData['relation_type']?.toString(),

      swapScore: dynamicData['swap_score']?.toString(),
      swapScorePercent: dynamicData['swap_score_percent']?.toString(),
      swapLabel: dynamicData['swap_label']?.toString(),
      swapScoreBreakdown: breakdown,

      // ✅ Hawadeet Taapdeel / Wish story fields
      hawadeetId: dynamicData['hawadeet_id']?.toString() ??
          dynamicData['hawadeetId']?.toString(),
      storyTitle: dynamicData['story_title']?.toString() ??
          dynamicData['storyTitle']?.toString(),
      hookPhrase: dynamicData['hook_phrase']?.toString() ??
          dynamicData['hookPhrase']?.toString(),
      storyText: dynamicData['story_text']?.toString() ??
          dynamicData['storyText']?.toString(),
      narratorComment: dynamicData['narrator_comment']?.toString() ??
          dynamicData['narratorComment']?.toString(),
      storyType: dynamicData['story_type']?.toString() ??
          dynamicData['storyType']?.toString(),
      personaType: dynamicData['persona_type']?.toString() ??
          dynamicData['personaType']?.toString(),
      needReason: dynamicData['need_reason']?.toString() ??
          dynamicData['needReason']?.toString(),
      occasion: dynamicData['occasion']?.toString(),
      genderTarget: dynamicData['gender_target']?.toString() ??
          dynamicData['genderTarget']?.toString(),
      ageMin: dynamicData['age_min']?.toString() ??
          dynamicData['ageMin']?.toString(),
      ageMax: dynamicData['age_max']?.toString() ??
          dynamicData['ageMax']?.toString(),
      familyRoleTarget: dynamicData['family_role_target']?.toString() ??
          dynamicData['familyRoleTarget']?.toString(),
      meTooCount: dynamicData['me_too_count']?.toString() ??
          dynamicData['meTooCount']?.toString(),
      shareCount: dynamicData['share_count']?.toString() ??
          dynamicData['shareCount']?.toString(),
      offerCount: dynamicData['offer_count']?.toString() ??
          dynamicData['offerCount']?.toString(),
      hawadeetStatus: dynamicData['hawadeet_status']?.toString() ??
          dynamicData['hawadeetStatus']?.toString(),
      userReactedMeToo: dynamicData['user_reacted_me_too']?.toString() ??
          dynamicData['userReactedMeToo']?.toString(),
      storyThemeId: dynamicData['story_theme_id']?.toString() ??
          dynamicData['storyThemeId']?.toString(),

      roleOneLabel: dynamicData['role_one_label']?.toString() ??
          dynamicData['roleOneLabel']?.toString(),

      roleTwoLabel: dynamicData['role_two_label']?.toString() ??
          dynamicData['roleTwoLabel']?.toString(),

      dialogueOne: dynamicData['dialogue_one']?.toString() ??
          dynamicData['dialogueOne']?.toString(),

      dialogueTwo: dynamicData['dialogue_two']?.toString() ??
          dynamicData['dialogueTwo']?.toString(),

      storyCardTitle: dynamicData['story_card_title']?.toString() ??
          dynamicData['storyCardTitle']?.toString(),

      happenedLikeMeCount: dynamicData['happened_like_me_count']?.toString() ??
          dynamicData['happenedLikeMeCount']?.toString(),

      userReactedHappenedLikeMe:
      dynamicData['user_reacted_happened_like_me']?.toString() ??
          dynamicData['userReactedHappenedLikeMe']?.toString(),
    );
  }

  @override
  Map<String, dynamic>? toMap(dynamic object) {
    if (object == null) return null;

    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = object.id;
    data['cat_id'] = object.catId;
    data['subcat_id'] = object.subCatId;
    data['item_type_id'] = object.itemTypeId;
    data['item_price_type_id'] = object.itemPriceTypeId;
    data['item_location_id'] = object.itemLocationId;
    data['item_location_township_id'] = object.itemLocationTownshipId;
    data['condition_of_item_id'] = object.conditionOfItemId;
    data['deal_option_remark'] = object.dealOptionRemark;
    data['description'] = object.description;
    data['highlight_info'] = object.highlightInformation;
    data['price'] = object.price;
    data['low_price'] = object.lowPrice;
    data['high_price'] = object.highPrice;
    data['deal_option_id'] = object.dealOptionId;
    data['brand'] = object.brand;
    data['business_mode'] = object.businessMode;
    data['is_sold_out'] = object.isSoldOut;
    data['title'] = object.title;
    data['address'] = object.address;
    data['lat'] = object.lat;
    data['lng'] = object.lng;
    data['status'] = object.status;
    data['added_date'] = object.addedDate;
    data['added_user_id'] = object.addedUserId;
    data['updated_date'] = object.updatedDate;
    data['updated_user_id'] = object.updatedUserId;
    data['updated_flag'] = object.updatedFlag;
    data['touch_count'] = object.touchCount;
    data['favourite_count'] = object.favouriteCount;
    data['is_paid'] = object.isPaid;
    data['dynamic_link'] = object.dynamicLink;
    data['added_date_str'] = object.addedDateStr;
    data['paid_status'] = object.paidStatus;
    data['photo_count'] = object.photoCount;
    data['is_favourited'] = object.isFavourited;
    data['is_owner'] = object.isOwner;
    data['discount_rate_by_percentage'] = object.discountRate;
    data['discounted_price'] = object.discountedPrice;

    data['default_photo'] = DefaultPhoto().toMap(object.defaultPhoto);
    data['image'] = object.image;
    data['img_path'] = object.imgPath;
    data['full_path'] = object.fullPath;
    data['default_video'] = DefaultPhoto().toMap(object.video);
    data['default_video_icon'] = DefaultPhoto().toMap(object.videoThumbnail);

    data['category'] = Category().toMap(object.category);
    data['sub_category'] = SubCategory().toMap(object.subCategory);
    data['item_type'] = ItemType().toMap(object.itemType);
    data['item_price_type'] = ItemPriceType().toMap(object.itemPriceType);
    data['item_currency'] = ItemCurrency().toMap(object.itemCurrency);
    data['item_location'] = ItemLocation().toMap(object.itemLocation);
    data['item_location_township'] =
        ItemLocationTownship().toMap(object.itemLocationTownship);
    data['condition_of_item'] = ConditionOfItem().toMap(object.conditionOfItem);
    data['deal_option'] = DealOption().toMap(object.dealOption);
    data['user'] = User().toMap(object.user);
    data['rating_details'] = RatingDetail().toMap(object.ratingDetail);

    data['ad_type'] = object.adType;

    // ✅ NEW fields: correct mapping
    data['relation_code'] = object.relationCode;
    data['relation_type'] = object.relationType;
    data['interest_match_type'] = object.interestMatchType;
    data['interest_owner_user_id'] = object.interestOwnerUserId;
    data['interest_owner_name'] = object.interestOwnerName;
    data['interest_owner_relation_type'] = object.interestOwnerRelationType;
    data['interest_owner_relation_label'] = object.interestOwnerRelationLabel;
    data['swap_score'] = object.swapScore;
    data['swap_score_percent'] = object.swapScorePercent;
    data['swap_label'] = object.swapLabel;
    data['swap_score_breakdown'] = object.swapScoreBreakdown;

    // ✅ Hawadeet Taapdeel / Wish story fields
    data['hawadeet_id'] = object.hawadeetId;
    data['story_title'] = object.storyTitle;
    data['hook_phrase'] = object.hookPhrase;
    data['story_text'] = object.storyText;
    data['narrator_comment'] = object.narratorComment;
    data['story_type'] = object.storyType;
    data['persona_type'] = object.personaType;
    data['need_reason'] = object.needReason;
    data['occasion'] = object.occasion;
    data['gender_target'] = object.genderTarget;
    data['age_min'] = object.ageMin;
    data['age_max'] = object.ageMax;
    data['family_role_target'] = object.familyRoleTarget;
    data['me_too_count'] = object.meTooCount;
    data['share_count'] = object.shareCount;
    data['offer_count'] = object.offerCount;
    data['hawadeet_status'] = object.hawadeetStatus;
    data['user_reacted_me_too'] = object.userReactedMeToo;
    data['story_theme_id'] = object.storyThemeId;
    data['role_one_label'] = object.roleOneLabel;
    data['role_two_label'] = object.roleTwoLabel;
    data['dialogue_one'] = object.dialogueOne;
    data['dialogue_two'] = object.dialogueTwo;
    data['story_card_title'] = object.storyCardTitle;
    data['happened_like_me_count'] = object.happenedLikeMeCount;
    data['user_reacted_happened_like_me'] = object.userReactedHappenedLikeMe;
    return data;
  }

  @override
  List<Product> fromMapList(List<dynamic> dynamicDataList) {
    final List<Product> newFeedList = <Product>[];
    for (dynamic json in dynamicDataList) {
      if (json != null) {
        newFeedList.add(fromMap(json));
      }
    }
    return newFeedList;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<dynamic> objectList) {
    final List<Map<String, dynamic>?> dynamicList = <Map<String, dynamic>?>[];
    for (dynamic data in objectList) {
      if (data != null) {
        dynamicList.add(toMap(data));
      }
    }
    return dynamicList;
  }

  List<Product> checkDuplicate(List<Product> dataList) {
    final Map<String?, String?> idCache = <String?, String?>{};
    final List<Product> _tmpList = <Product>[];
    for (int i = 0; i < dataList.length; i++) {
      if (idCache[dataList[i].id] == null) {
        _tmpList.add(dataList[i]);
        idCache[dataList[i].id] = dataList[i].id;
      } else {
        Utils.psPrint('Duplicate');
      }
    }
    return _tmpList;
  }

  bool isSame(List<Product> cache, List<Product> newList) {
    if (cache.length == newList.length) {
      bool status = true;
      for (int i = 0; i < cache.length; i++) {
        if (cache[i].id != newList[i].id) {
          status = false;
          break;
        }
      }
      return status;
    } else {
      return false;
    }
  }
}
