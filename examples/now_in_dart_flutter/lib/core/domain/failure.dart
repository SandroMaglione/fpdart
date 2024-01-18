import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, {this.code, this.stackTrace, this.errorObject});

  final String message;
  final int? code;
  final Object? errorObject;
  final StackTrace? stackTrace;
}

class ApiFailure extends Failure {
  const ApiFailure(
    super.message, {
    super.code,
    super.stackTrace,
    super.errorObject,
  });

  @override
  List<Object?> get props => [message, code, stackTrace, errorObject];
}

class UriParserFailure extends Failure {
  const UriParserFailure(super.message, {super.errorObject, super.stackTrace});

  @override
  List<Object?> get props => [message, errorObject, stackTrace];
}
