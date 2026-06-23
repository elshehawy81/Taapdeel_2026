import 'dart:convert';

import 'package:taapdeel/viewobject/category.dart';
import 'package:taapdeel/viewobject/item_location.dart';
import 'package:taapdeel/viewobject/user.dart';

import '../../../../viewobject/default_photo.dart';
import '../../../../viewobject/item_location_township.dart';

class WishlistProductModel {
  String? id;
  String? title;
  String? status;
  String? addedUserId;
  String? catId;
  String? subCatId;
  String? lowPrice;
  String? highPrice;
  String? itemLocationId;
  String? itemLocationTownshipId;
  String? lat;
  String? lng;
  String? isSoldOut;
 
  String? conditionOfItemId;
  String? itemTypeId;
  String? dealOptionRemark;
  String? description;
  String? highlightInfo;
  String? price;
  String? itemPriceTypeId;
  String? dealOptionId;
  String? brand;
  String? businessMode;
  String? address;
  String? addedDate;
  String? updatedDate;
  String? updatedUserId;
  String? updatedFlag;
  String? touchCount;
  String? favouriteCount;
  String? isPaid;
  String? dynamicLink;
  String? paymentType;
  String? discountRateByPercentage;
  String? addedDateStr;
  String? adType;
  String? paidStatus;
  String? photoCount;
  String? videoCount;
  DefaultPhoto? defaultPhoto;
  DefaultPhoto? defaultVideo;
  DefaultPhoto? defaultVideoIcon;
  Category? category;
  ItemLocation? itemLocation;
  ItemLocationTownship? itemLocationTownship;
  User? user;
  String? isFavourited;
  String? isOwner;

  // Hawadeet Taapdeel optional story fields. These can come directly from API
  // or from highlight_info JSON for MVP compatibility.
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

  WishlistProductModel(
      {this.id,
        this.title,
        this.status,
        this.addedUserId,
        this.catId,
        this.subCatId,
        this.lowPrice,
        this.highPrice,
        this.itemLocationId,
        this.itemLocationTownshipId,
        this.lat,
        this.lng,
        this.isSoldOut,
        this.conditionOfItemId,
        this.itemTypeId,
        this.dealOptionRemark,
        this.description,
        this.highlightInfo,
        this.price,
        this.itemPriceTypeId,
        this.dealOptionId,
        this.brand,
        this.businessMode,
        this.address,
        this.addedDate,
        this.updatedDate,
        this.updatedUserId,
        this.updatedFlag,
        this.touchCount,
        this.favouriteCount,
        this.isPaid,
        this.dynamicLink,
        this.paymentType,
        this.discountRateByPercentage,
        this.addedDateStr,
        this.adType,
        this.paidStatus,
        this.photoCount,
        this.videoCount,
        this.defaultPhoto,
        this.defaultVideo,
        this.defaultVideoIcon,
        this.category,
        this.itemLocation,
        this.itemLocationTownship,
        this.user,
        this.isFavourited,
        this.isOwner,
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
        this.userReactedHappenedLikeMe});

  WishlistProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    status = json['status'];
    addedUserId = json['added_user_id'];
    catId = json['cat_id'];
    subCatId = json['subcat_id'];
    lowPrice = json['low_price'];
    highPrice = json['high_price'];
    itemLocationId = json['item_location_id'];
    itemLocationTownshipId = json['item_location_township_id'];
    lat = json['lat'];
    lng = json['lng'];
    isSoldOut = json['is_sold_out'];
    conditionOfItemId = json['condition_of_item_id'];
    itemTypeId = json['item_type_id'];
    dealOptionRemark = json['deal_option_remark'];
    description = json['description'];
    highlightInfo = json['highlight_info'];
    price = json['price'];
    itemPriceTypeId = json['item_price_type_id'];
    dealOptionId = json['deal_option_id'];
    brand = json['brand'];
    businessMode = json['business_mode'];
    address = json['address'];
    addedDate = json['added_date'];
    updatedDate = json['updated_date'];
    updatedUserId = json['updated_user_id'];
    updatedFlag = json['updated_flag'];
    touchCount = json['touch_count'];
    favouriteCount = json['favourite_count'];
    isPaid = json['is_paid'];
    dynamicLink = json['dynamic_link'];
    paymentType = json['payment_type'];
    discountRateByPercentage = json['discount_rate_by_percentage'];
    addedDateStr = json['added_date_str'];
    adType = json['ad_type'];
    paidStatus = json['paid_status'];
    photoCount = json['photo_count'];
    videoCount = json['video_count'];
    defaultPhoto = DefaultPhoto().fromMap(json['default_photo']);

    user = User().fromMap(json['user']);

    defaultVideo = DefaultPhoto().fromMap(json['default_video']);
    defaultVideoIcon = DefaultPhoto().fromMap(json['default_video_icon']);
    category = Category().fromMap(json['category']);
    itemLocation = ItemLocation().fromMap(json['item_location']);
    itemLocationTownship = ItemLocationTownship().fromMap(json['item_location_township']);
    user = User().fromMap(json['user']);
    isFavourited = json['is_favourited'];
    isOwner = json['is_owner'];

    final Map<String, dynamic> highlight = _hawadeetHighlightJson(json);
    hawadeetId = _pick(json, highlight, const <String>['hawadeet_id', 'hawadeetId']);
    storyTitle = _pick(json, highlight, const <String>['story_title', 'hawadeet_title', 'storyTitle']);
    hookPhrase = _pick(json, highlight, const <String>['hook_phrase', 'story_hook', 'hookPhrase']);
    storyText = _pick(json, highlight, const <String>['story_text', 'hawadeet_text', 'storyText']);
    narratorComment = _pick(json, highlight, const <String>['narrator_comment', 'narratorComment']);
    storyType = _pick(json, highlight, const <String>['story_type', 'storyType']);
    personaType = _pick(json, highlight, const <String>['persona_type', 'personaType']);
    needReason = _pick(json, highlight, const <String>['need_reason', 'needReason']);
    occasion = _pick(json, highlight, const <String>['occasion']);
    genderTarget = _pick(json, highlight, const <String>['gender_target', 'genderTarget']);
    ageMin = _pick(json, highlight, const <String>['age_min', 'ageMin']);
    ageMax = _pick(json, highlight, const <String>['age_max', 'ageMax']);
    familyRoleTarget = _pick(json, highlight, const <String>['family_role_target', 'familyRoleTarget']);
    meTooCount = _pick(json, highlight, const <String>['me_too_count', 'meTooCount']);
    shareCount = _pick(json, highlight, const <String>['share_count', 'shareCount']);
    offerCount = _pick(json, highlight, const <String>['offer_count', 'offerCount']);
    hawadeetStatus = _pick(json, highlight, const <String>['hawadeet_status', 'status', 'hawadeetStatus']);
    userReactedMeToo = _pick(json, highlight, const <String>['user_reacted_me_too', 'userReactedMeToo']);
    storyThemeId = _pick(json, highlight, const <String>['story_theme_id', 'theme_id', 'storyThemeId']);
    roleOneLabel = _pick(json, highlight, const <String>['role_one_label', 'speaker_one_label', 'roleOneLabel']);
    roleTwoLabel = _pick(json, highlight, const <String>['role_two_label', 'speaker_two_label', 'roleTwoLabel']);
    dialogueOne = _pick(json, highlight, const <String>['dialogue_one', 'scene_1', 'scene1', 'dialogueOne']);
    dialogueTwo = _pick(json, highlight, const <String>['dialogue_two', 'scene_2', 'scene2', 'dialogueTwo']);
    storyCardTitle = _pick(json, highlight, const <String>['story_card_title', 'card_title', 'storyCardTitle']);
    happenedLikeMeCount = _pick(json, highlight, const <String>['happened_like_me_count', 'same_story_count', 'happenedLikeMeCount']);
    userReactedHappenedLikeMe = _pick(json, highlight, const <String>['user_reacted_happened_like_me', 'userReactedHappenedLikeMe']);
  }

  bool get hasHawadeet =>
      _hasText(storyTitle) ||
      _hasText(hookPhrase) ||
      _hasText(storyText) ||
      _hasText(dialogueOne) ||
      _hasText(dialogueTwo) ||
      _hasText(storyCardTitle) ||
      storyType == 'official' ||
      storyType == 'user_generated' ||
      storyType == 'template';

  String get displayTitle {
    if (_hasText(storyCardTitle)) return storyCardTitle!.trim();
    if (_hasText(storyTitle)) return storyTitle!.trim();
    if (_hasText(title)) return title!.trim();
    return 'حاجة نفسنا فيها';
  }

  String get displayHook {
    if (_hasText(dialogueOne)) return dialogueOne!.trim();
    if (_hasText(hookPhrase)) return hookPhrase!.trim();
    final String fallback = (description ?? '').trim();
    if (fallback.isNotEmpty && fallback.length <= 90) return fallback;
    return '';
  }

  String get displayReply {
    if (_hasText(dialogueTwo)) return dialogueTwo!.trim();
    if (_hasText(storyText)) return storyText!.trim();
    return '';
  }

  static Map<String, dynamic> _hawadeetHighlightJson(Map<String, dynamic> json) {
    final dynamic raw = json['highlight_info'] ??
        json['highlightInfo'] ??
        json['highlight_information'] ??
        json['highlightInfomation'];

    if (raw is Map) return Map<String, dynamic>.from(raw);
    final String text = (raw ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return <String, dynamic>{};

    try {
      final dynamic decoded = jsonDecode(text);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return <String, dynamic>{};
  }

  static String? _pick(
    Map<String, dynamic> json,
    Map<String, dynamic> highlight,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final String direct = (json[key] ?? '').toString().trim();
      if (direct.isNotEmpty && direct.toLowerCase() != 'null') return direct;

      final String fromHighlight = (highlight[key] ?? '').toString().trim();
      if (fromHighlight.isNotEmpty && fromHighlight.toLowerCase() != 'null') return fromHighlight;
    }
    return null;
  }

  static bool _hasText(String? value) {
    final String text = (value ?? '').trim();
    return text.isNotEmpty && text.toLowerCase() != 'null';
  }

 }

