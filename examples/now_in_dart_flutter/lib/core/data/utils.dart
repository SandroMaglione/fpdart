import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';

IOEither<Failure, Uri> uriParser(String uri) {
  return IOEither.tryCatch(
    () => Uri.parse(uri),
    (e, stackTrace) => UriParserFailure(
      'Invalid Uri string',
      errorObject: e,
      stackTrace: stackTrace,
    ),
  );
}
