import 'package:taapdeel/viewobject/common/ps_object.dart';
import 'package:taapdeel/viewobject/rating_detail.dart';
import 'package:quiver/core.dart';

class User extends PsObject<User> {
  User({
    this.userId,
    this.userIsSysAdmin,
    this.googleId,
    this.phoneId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAddress,
    this.userLat,
    this.userLng,
    this.city,
    this.userAge,
    this.userGender,
    this.userPassword,
    this.userAboutMe,
    this.isShowEmail,
    this.isShowPhone,
    this.userCoverPhoto,
    this.userProfilePhoto,
    this.roleId,
    this.status,
    this.isBanned,
    this.addedDate,
    this.addedDateTimeStamp,
    this.deviceToken,
    this.code,
    this.overallRating,
    this.whatsapp,
    this.messenger,
    this.followerCount,
    this.followingCount,
    this.emailVerify,
    this.googleVerify,
    this.phoneVerify,
    this.isVerifyBlueMark,
    this.ratingCount,
    this.isFollowed,
    this.isBlocked,
    this.ratingDetail,
    this.isFavourited,
    this.isOwner,
    this.remainingPost,
    this.postCount,
    this.points,
    this.swapNo,
    this.swapBalance,
    this.activeItemCount,

    // Referral tracking
    this.referralCode,
    this.referredByUserId,
    this.referredByCode,
    this.referralRegisteredAt,

    // ✅ NEW
    this.itemsCount,
    this.wishItemsCount,
  });

  String? userId;
  String? userIsSysAdmin;
  String? googleId;
  String? phoneId;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userAddress;
  String? userLat;
  String? userLng;
  String? city;
  String? userPassword;
  String? userAge;
  String? userGender;
  String? userAboutMe;
  String? isShowEmail;
  String? isShowPhone;
  String? userCoverPhoto;
  String? userProfilePhoto;
  String? roleId;
  String? status;
  String? isBanned;
  String? addedDate;
  String? addedDateTimeStamp;
  String? deviceToken;
  String? code;
  String? overallRating;
  String? whatsapp;
  String? messenger;
  String? followerCount;
  String? followingCount;
  String? emailVerify;
  String? googleVerify;
  String? phoneVerify;
  String? ratingCount;
  String? isFollowed;
  String? isBlocked;
  RatingDetail? ratingDetail;
  String? isFavourited;
  String? isOwner;
  String? isVerifyBlueMark;
  String? remainingPost;
  String? postCount;
  String? activeItemCount;
  String? points;
  String? swapBalance;
  String? swapNo;

  // Referral tracking
  String? referralCode;
  String? referredByUserId;
  String? referredByCode;
  String? referralRegisteredAt;

  // ✅ NEW
  int? itemsCount;
  int? wishItemsCount;

  @override
  bool operator ==(dynamic other) => other is User && userId == other.userId;

  @override
  int get hashCode => hash2(userId.hashCode, userId.hashCode);

  @override
  String getPrimaryKey() => userId ?? '';

  int _parseInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? fallback;
  }

  @override
  User fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return User(
        userId: dynamicData['user_id'],
        userIsSysAdmin: dynamicData['user_is_sys_admin'],
        googleId: dynamicData['google_id'],
        phoneId: dynamicData['phone_id'],
        userName: dynamicData['user_name'],
        userEmail: dynamicData['user_email'],
        userPhone: dynamicData['user_phone'],
        userAddress: dynamicData['user_address'],
        userLat: dynamicData['user_lat'],
        userLng: dynamicData['user_lng'],
        city: dynamicData['city'],
        userAge: dynamicData['user_age'],
        userGender: dynamicData['user_gender'],
        userPassword: dynamicData['user_password'],
        userAboutMe: dynamicData['user_about_me'],
        isShowEmail: dynamicData['is_show_email'],
        isShowPhone: dynamicData['is_show_phone'],
        userCoverPhoto: dynamicData['user_cover_photo'],
        userProfilePhoto: dynamicData['user_profile_photo'],
        roleId: dynamicData['role_id'],
        status: dynamicData['status'],
        isBanned: dynamicData['is_banned'],
        addedDate: dynamicData['added_date'],
        addedDateTimeStamp: dynamicData['added_date_timestamp'],
        deviceToken: dynamicData['device_token'],
        code: dynamicData['code'],
        overallRating: dynamicData['overall_rating'],
        whatsapp: dynamicData['whatsapp'],
        messenger: dynamicData['messenger'],
        followerCount: dynamicData['follower_count'],
        followingCount: dynamicData['following_count'],
        emailVerify: dynamicData['email_verify'],
        googleVerify: dynamicData['google_verify'],
        phoneVerify: dynamicData['phone_verify'],
        ratingCount: dynamicData['rating_count'],
        isFollowed: dynamicData['is_followed'],
        isBlocked: dynamicData['is_blocked'],
        ratingDetail: RatingDetail().fromMap(dynamicData['rating_details']),
        isFavourited: dynamicData['is_favourited'],
        isOwner: dynamicData['is_owner'],
        isVerifyBlueMark: dynamicData['is_verify_blue_mark'],
        remainingPost: dynamicData['remaining_post'],
        postCount: dynamicData['post_count'],
        activeItemCount: dynamicData['active_item_count'],
        points: dynamicData['points'],
        swapBalance: dynamicData['swap_balance'],
        swapNo: dynamicData['swap_no'],

        // Referral tracking
        referralCode: dynamicData['referral_code'],
        referredByUserId: dynamicData['referred_by_user_id'],
        referredByCode: dynamicData['referred_by_code'],
        referralRegisteredAt: dynamicData['referral_registered_at'],

        // ✅ NEW: keys from API
        itemsCount: _parseInt(dynamicData['items_count']),
        wishItemsCount: _parseInt(dynamicData['wishitems_count']),
      );
    } else {
      return User();
    }
  }

  @override
  Map<String, dynamic>? toMap(User object) {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['user_id'] = object.userId;
    data['user_is_sys_admin'] = object.userIsSysAdmin;
    data['google_id'] = object.googleId;
    data['phone_id'] = object.phoneId;
    data['user_name'] = object.userName;
    data['user_email'] = object.userEmail;
    data['user_phone'] = object.userPhone;
    data['user_address'] = object.userAddress;
    data['user_lat'] = object.userLat;
    data['user_lng'] = object.userLng;
    data['city'] = object.city;
    data['user_password'] = object.userPassword;
    data['user_gender'] = object.userGender;
    data['user_age'] = object.userAge;
    data['user_about_me'] = object.userAboutMe;
    data['is_show_email'] = object.isShowEmail;
    data['is_show_phone'] = object.isShowPhone;
    data['user_cover_photo'] = object.userCoverPhoto;
    data['user_profile_photo'] = object.userProfilePhoto;
    data['role_id'] = object.roleId;
    data['status'] = object.status;
    data['is_banned'] = object.isBanned;
    data['added_date'] = object.addedDate;
    data['added_date_timestamp'] = object.addedDateTimeStamp;
    data['device_token'] = object.deviceToken;
    data['code'] = object.code;
    data['overall_rating'] = object.overallRating;
    data['whatsapp'] = object.whatsapp;
    data['messenger'] = object.messenger;
    data['follower_count'] = object.followerCount;
    data['following_count'] = object.followingCount;
    data['email_verify'] = object.emailVerify;
    data['google_verify'] = object.googleVerify;
    data['phone_verify'] = object.phoneVerify;
    data['is_verify_blue_mark'] = object.isVerifyBlueMark;
    data['rating_count'] = object.ratingCount;
    data['is_followed'] = object.isFollowed;
    data['is_blocked'] = object.isBlocked;
    data['rating_details'] = RatingDetail().toMap(object.ratingDetail);
    data['is_favourited'] = object.isFavourited;
    data['is_owner'] = object.isOwner;
    data['remaining_post'] = object.remainingPost;
    data['post_count'] = object.postCount;
    data['active_item_count'] = object.activeItemCount;
    data['points'] = object.points;
    data['swap_balance'] = object.swapBalance;
    data['swap_no'] = object.swapNo;

    // Referral tracking
    data['referral_code'] = object.referralCode;
    data['referred_by_user_id'] = object.referredByUserId;
    data['referred_by_code'] = object.referredByCode;
    data['referral_registered_at'] = object.referralRegisteredAt;

    // ✅ NEW
    data['items_count'] = object.itemsCount ?? 0;
    data['wishitems_count'] = object.wishItemsCount ?? 0;

    return data;
  }

  @override
  List<User> fromMapList(List<dynamic> dynamicDataList) {
    final List<User> subUserList = <User>[];
    for (dynamic dynamicData in dynamicDataList) {
      if (dynamicData != null) {
        subUserList.add(fromMap(dynamicData));
      }
    }
    return subUserList;
  }

  @override
  List<Map<String, dynamic>?> toMapList(List<User?> objectList) {
    final List<Map<String, dynamic>?> mapList = <Map<String, dynamic>?>[];
    for (User? data in objectList) {
      if (data != null) {
        mapList.add(toMap(data));
      }
    }
    return mapList;
  }
}
