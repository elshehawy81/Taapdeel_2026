

class UsersPhoneModel {
  String? userId;
  String? userIsSysAdmin;
  String? facebookId;
  String? googleId;
  String? phoneId;
  String? appleId;
  String? userName;
  /// Name as saved by current user in phone book. Used only for UI display.
  String? localContactName;
  String? userEmail;
  String? userPhone;
  String? userAddress;
  String? city;
  String? points;
  String? swapBalance;
  String? swapNo;
  String? userAge;
  String? userGender;
  String? userAboutMe;
  String? userCoverPhoto;
  String? userProfilePhoto;
  String? roleId;
  String? status;
  String? isBanned;
  String? addedDate;
  String? addedDateTimestamp;
  String? deviceToken;
  String? code;
  String? overallRating;
  String? whatsapp;
  String? messenger;
  String? followerCount;
  String? followingCount;
  String? emailVerify;
  String? facebookVerify;
  String? googleVerify;
  String? phoneVerify;
  String? appleVerify;
  String? isShowEmail;
  String? isShowPhone;
  String? isVerifyBlueMark;
  String? blueMarkNote;
  String? remainingPost;
  String? addedDateStr;
  String? postCount;
  String? activeItemCount;
  String? ratingCount;
  String? isFollowed;
  String? isBlocked;
  int? itemsCount;
  RatingDetails? ratingDetails;

  UsersPhoneModel(
      {this.userId,
        this.userIsSysAdmin,
        this.facebookId,
        this.googleId,
        this.phoneId,
        this.appleId,
        this.userName,
        this.localContactName,
        this.userEmail,
        this.userPhone,
        this.userAddress,
        this.city,
        this.points,
        this.swapBalance,
        this.swapNo,
        this.userAge,
        this.userGender,
        this.userAboutMe,
        this.userCoverPhoto,
        this.userProfilePhoto,
        this.roleId,
        this.status,
        this.isBanned,
        this.addedDate,
        this.addedDateTimestamp,
        this.deviceToken,
        this.code,
        this.overallRating,
        this.whatsapp,
        this.messenger,
        this.followerCount,
        this.followingCount,
        this.emailVerify,
        this.facebookVerify,
        this.googleVerify,
        this.phoneVerify,
        this.appleVerify,
        this.isShowEmail,
        this.isShowPhone,
        this.isVerifyBlueMark,
        this.blueMarkNote,
        this.remainingPost,
        this.addedDateStr,
        this.postCount,
        this.activeItemCount,
        this.ratingCount,
        this.isFollowed,
        this.isBlocked,
        this.itemsCount,
        this.ratingDetails});


  static int? _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    final s = v.toString().trim();
    return int.tryParse(s) ?? 0;
  }

  UsersPhoneModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userIsSysAdmin = json['user_is_sys_admin'];
    facebookId = json['facebook_id'];
    googleId = json['google_id'];
    phoneId = json['phone_id'];
    appleId = json['apple_id'];
    userName = json['user_name'];
    localContactName = json['local_contact_name'] ?? json['contact_display_name'] ?? json['phonebook_name'] ?? json['contact_name'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
    userAddress = json['user_address'];
    city = json['city'];
    points = json['points'];
    swapBalance = json['swap_balance'];
    swapNo = json['swap_no'];
    userAge = json['user_age'];
    userGender = json['user_gender'];
    userAboutMe = json['user_about_me'];
    userCoverPhoto = json['user_cover_photo'];
    userProfilePhoto = json['user_profile_photo'];
    roleId = json['role_id'];
    status = json['status'];
    isBanned = json['is_banned'];
    addedDate = json['added_date'];
    addedDateTimestamp = json['added_date_timestamp'];
    deviceToken = json['device_token'];
    code = json['code'];
    overallRating = json['overall_rating'];
    whatsapp = json['whatsapp'];
    messenger = json['messenger'];
    followerCount = json['follower_count'];
    followingCount = json['following_count'];
    emailVerify = json['email_verify'];
    facebookVerify = json['facebook_verify'];
    googleVerify = json['google_verify'];
    phoneVerify = json['phone_verify'];
    appleVerify = json['apple_verify'];
    isShowEmail = json['is_show_email'];
    isShowPhone = json['is_show_phone'];
    isVerifyBlueMark = json['is_verify_blue_mark'];
    blueMarkNote = json['blue_mark_note'];
    remainingPost = json['remaining_post'];
    addedDateStr = json['added_date_str'];
    postCount = json['post_count'];
    activeItemCount = json['active_item_count'];
    ratingCount = json['rating_count'];
    isFollowed = json['is_followed'];
    isBlocked = json['is_blocked'];
    itemsCount = _parseInt(json['items_count']);
    ratingDetails = json['rating_details'] != null
        ? new RatingDetails.fromJson(json['rating_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_is_sys_admin'] = this.userIsSysAdmin;
    data['facebook_id'] = this.facebookId;
    data['google_id'] = this.googleId;
    data['phone_id'] = this.phoneId;
    data['apple_id'] = this.appleId;
    data['user_name'] = this.userName;
    data['local_contact_name'] = this.localContactName;
    data['user_email'] = this.userEmail;
    data['user_phone'] = this.userPhone;
    data['user_address'] = this.userAddress;
    data['items_count'] = itemsCount;
    data['city'] = this.city;
    data['points'] = this.points;
    data['swap_balance'] = this.swapBalance;
    data['swap_no'] = this.swapNo;
    data['user_age'] = this.userAge;
    data['user_gender'] = this.userGender;
    data['user_about_me'] = this.userAboutMe;
    data['user_cover_photo'] = this.userCoverPhoto;
    data['user_profile_photo'] = this.userProfilePhoto;
    data['role_id'] = this.roleId;
    data['status'] = this.status;
    data['is_banned'] = this.isBanned;
    data['added_date'] = this.addedDate;
    data['added_date_timestamp'] = this.addedDateTimestamp;
    data['device_token'] = this.deviceToken;
    data['code'] = this.code;
    data['overall_rating'] = this.overallRating;
    data['whatsapp'] = this.whatsapp;
    data['messenger'] = this.messenger;
    data['follower_count'] = this.followerCount;
    data['following_count'] = this.followingCount;
    data['email_verify'] = this.emailVerify;
    data['facebook_verify'] = this.facebookVerify;
    data['google_verify'] = this.googleVerify;
    data['phone_verify'] = this.phoneVerify;
    data['apple_verify'] = this.appleVerify;
    data['is_show_email'] = this.isShowEmail;
    data['is_show_phone'] = this.isShowPhone;
    data['is_verify_blue_mark'] = this.isVerifyBlueMark;
    data['blue_mark_note'] = this.blueMarkNote;
    data['remaining_post'] = this.remainingPost;
    data['added_date_str'] = this.addedDateStr;
    data['post_count'] = this.postCount;
    data['active_item_count'] = this.activeItemCount;
    data['rating_count'] = this.ratingCount;
    data['is_followed'] = this.isFollowed;
    data['is_blocked'] = this.isBlocked;
    if (this.ratingDetails != null) {
      data['rating_details'] = this.ratingDetails!.toJson();
    }
    return data;
  }
}

class RatingDetails {
  String? fiveStarCount;
  String? fiveStarPercent;
  String? fourStarCount;
  String? fourStarPercent;
  String? threeStarCount;
  String? threeStarPercent;
  String? twoStarCount;
  String? twoStarPercent;
  String? oneStarCount;
  String? oneStarPercent;
  String? totalRatingCount;
  String? totalRatingValue;

  RatingDetails(
      {this.fiveStarCount,
        this.fiveStarPercent,
        this.fourStarCount,
        this.fourStarPercent,
        this.threeStarCount,
        this.threeStarPercent,
        this.twoStarCount,
        this.twoStarPercent,
        this.oneStarCount,
        this.oneStarPercent,
        this.totalRatingCount,
        this.totalRatingValue});

  RatingDetails.fromJson(Map<String, dynamic> json) {
    fiveStarCount = json['five_star_count'];
    fiveStarPercent = json['five_star_percent'];
    fourStarCount = json['four_star_count'];
    fourStarPercent = json['four_star_percent'];
    threeStarCount = json['three_star_count'];
    threeStarPercent = json['three_star_percent'];
    twoStarCount = json['two_star_count'];
    twoStarPercent = json['two_star_percent'];
    oneStarCount = json['one_star_count'];
    oneStarPercent = json['one_star_percent'];
    totalRatingCount = json['total_rating_count'];
    totalRatingValue = json['total_rating_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['five_star_count'] = this.fiveStarCount;
    data['five_star_percent'] = this.fiveStarPercent;
    data['four_star_count'] = this.fourStarCount;
    data['four_star_percent'] = this.fourStarPercent;
    data['three_star_count'] = this.threeStarCount;
    data['three_star_percent'] = this.threeStarPercent;
    data['two_star_count'] = this.twoStarCount;
    data['two_star_percent'] = this.twoStarPercent;
    data['one_star_count'] = this.oneStarCount;
    data['one_star_percent'] = this.oneStarPercent;
    data['total_rating_count'] = this.totalRatingCount;
    data['total_rating_value'] = this.totalRatingValue;
    return data;
  }

}
