import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pokeapi_functional/models/pokemon.dart';

part 'request_status.freezed.dart';

/// Different request status when making API request.
///
/// Each status maps to a different UI.
@freezed
class RequestStatus with _$RequestStatus {
  const factory RequestStatus.initial() = InitialRequestStatus;
  const factory RequestStatus.loading() = LoadingRequestStatus;
  const factory RequestStatus.error(String string) = ErrorRequestStatus;
  const factory RequestStatus.success(Pokemon pokemon) = SuccessRequestStatus;
}
