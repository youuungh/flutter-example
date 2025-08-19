import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed_user_model.g.dart';

part 'freezed_user_model.freezed.dart';

@freezed
abstract class FreezedUserModel with _$FreezedUserModel {
  const factory FreezedUserModel({
    int? id,
    String? name,
    String? username,
    String? email,
    Address? address,
  }) = _FreezedUserModel;

  factory FreezedUserModel.fromJson(Map<String, dynamic> json) =>
      _$FreezedUserModelFromJson(json);
}

@freezed
abstract class Address with _$Address {
  const factory Address({String? street, String? zipcode}) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
