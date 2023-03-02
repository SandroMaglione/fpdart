// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: Option<int>.fromJson(json['id'], (value) => value as int),
      birthDate: Option<DateTime>.fromJson(
          json['birthDate'], (value) => DateTime.parse(value as String)),
      phone: Option<String>.fromJson(json['phone'], (value) => value as String),
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
