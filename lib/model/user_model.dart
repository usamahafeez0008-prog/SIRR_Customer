import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? userTitle;
  String? fullName;
  String? id;
  String? email;
  String? loginType;
  String? profilePic;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  String? reviewsCount;
  String? reviewsSum;
  String? walletAmount;
  bool? isActive;
  Timestamp? createdAt;
  String? password;

  UserModel(
      {this.userTitle,
      this.fullName,
      this.id,
      this.email,
      this.loginType,
      this.profilePic,
      this.fcmToken,
      this.countryCode,
      this.phoneNumber,
      this.reviewsCount,
      this.reviewsSum,
      this.isActive,
      this.walletAmount,
      this.createdAt,
      this.password});

  UserModel.fromJson(Map<String, dynamic> json) {
    userTitle = json['userTitle'];
    fullName = json['fullName'];
    id = json['id'];
    email = json['email'];
    loginType = json['loginType'];
    profilePic = json['profilePic'];
    fcmToken = json['fcmToken'];
    countryCode = json['countryCode'];
    phoneNumber = json['phoneNumber'];
    reviewsCount = json['reviewsCount'] ?? "0.0";
    reviewsSum = json['reviewsSum'] ?? "0.0";
    isActive = json['isActive'];
    walletAmount = json['walletAmount'] ?? "0.0";
    createdAt = json['createdAt'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userTitle'] = userTitle;
    data['fullName'] = fullName;
    data['id'] = id;
    data['email'] = email;
    data['loginType'] = loginType;
    data['profilePic'] = profilePic;
    data['fcmToken'] = fcmToken;
    data['countryCode'] = countryCode;
    data['phoneNumber'] = phoneNumber;
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    data['isActive'] = isActive;
    data['walletAmount'] = walletAmount;
    data['createdAt'] = createdAt;
    data['password'] = password;
    return data;
  }
}
