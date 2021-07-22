// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: Option.fromJson(json['id']),
      birthDate: Option.fromJson(json['birthDate']),
      phone: Option.fromJson(json['phone']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id.toJson(
        (value) => value,
      ),
      'birthDate': instance.birthDate.toJson(
        (value) => value.toIso8601String(),
      ),
      'phone': instance.phone.toJson(
        (value) => value,
      ),
    };
