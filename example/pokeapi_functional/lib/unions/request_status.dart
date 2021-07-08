import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:pokeapi_functional/models/pokemon.dart';

part 'request_status.freezed.dart';

@freezed
class RequestStatus with _$RequestStatus {
  const factory RequestStatus.initial() = InitialRequestStatus;
  const factory RequestStatus.loading() = LoadingRequestStatus;
  const factory RequestStatus.error(String string) = ErrorRequestStatus;
  const factory RequestStatus.success(Pokemon pokemon) = SuccessRequestStatus;
}
