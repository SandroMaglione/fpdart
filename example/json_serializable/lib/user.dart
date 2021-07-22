import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final Option<int> id;
  final Option<DateTime> birthDate;
  final Option<String> phone;

  const User({
    required this.id,
    required this.birthDate,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
