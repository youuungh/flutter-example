// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freezed_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FreezedUserModel _$FreezedUserModelFromJson(Map<String, dynamic> json) =>
    _FreezedUserModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FreezedUserModelToJson(_FreezedUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'email': instance.email,
      'address': instance.address,
    };

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  street: json['street'] as String?,
  zipcode: json['zipcode'] as String?,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'street': instance.street,
  'zipcode': instance.zipcode,
};
