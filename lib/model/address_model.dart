import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  String? id;
  double? lat;
  double? lng;
  String? address;
  String? city;
  String? userId;
  Timestamp? timestamp;

  AddressModel({
    this.id,
    this.lat,
    this.lng,
    this.address,
    this.city,
    this.userId,
    this.timestamp,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat']?.toDouble();
    lng = json['lng']?.toDouble();
    address = json['address'];
    city = json['city'];
    userId = json['userId'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lat'] = lat;
    data['lng'] = lng;
    data['address'] = address;
    data['city'] = city;
    data['userId'] = userId;
    data['timestamp'] = timestamp;
    return data;
  }
}
