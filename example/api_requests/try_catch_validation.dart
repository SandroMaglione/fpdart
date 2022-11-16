import 'dart:convert';

import 'package:fpdart/fpdart.dart';

/// Example of API request with `fpdart` with validation
/// Source: https://github.com/SandroMaglione/fpdart/issues/50#issue-1372504529

/// Mock [Response] implementation
class Response {
  final String body;
  Response(this.body);
}

/// Mock for `post` API request
Response post(
  Uri uri, {
  Map<String, String>? headers,
}) =>
    Response('');

TaskEither<String, String> request() => TaskEither.tryCatch(
      () async {
        final Response getPrice = await post(
          Uri.parse("URL"),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        final Map<String, dynamic> json =
            jsonDecode(getPrice.body) as Map<String, dynamic>;

        if (!json.containsKey("pricing")) {
          throw Exception("I don't have price");
        }

        return json["pricing"].toString();
      },
      (error, stackTrace) {
        return error.toString();
      },
    );

/// Instead of placing all the request + validation inside `tryCatch`
/// we want to chain different [TaskEither] methods.
///
/// This allows to create a pipeline where each step is responsible
/// for a specific purpose (request, extract parameters, validation).
///
/// It's also important to implement a solid error reporting system,
/// ideally by adding our own [Error] class.
///
/// Finally, in order for the request to be a **pure function** we want to
/// pass all the parameters as inputs to the function
typedef Pricing = String;

abstract class RequestError {
  String get message;
}

class ApiRequestError implements RequestError {
  final Object error;
  final StackTrace stackTrace;

  ApiRequestError(this.error, this.stackTrace);

  @override
  String get message => "Error in the API request";
}

class MissingPricingRequestError implements RequestError {
  @override
  String get message => "Missing pricing in API response";
}

TaskEither<RequestError, Response> makeRequest(String url) =>
    TaskEither<RequestError, Response>.tryCatch(
      () async => post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      (error, stackTrace) => ApiRequestError(error, stackTrace),
    );

Map<String, dynamic> mapToJson(Response response) =>
    jsonDecode(response.body) as Map<String, dynamic>;

TaskEither<RequestError, Map<String, dynamic>> mappingRequest(String url) =>
    makeRequest(url).map(mapToJson);

TaskEither<RequestError, String> validationRequest(Map<String, dynamic> json) =>
    !json.containsKey("pricing")
        ? TaskEither.left(MissingPricingRequestError())
        : TaskEither.of(json["pricing"].toString());

TaskEither<RequestError, Pricing> requestTE(String url) =>
    makeRequest(url).map(mapToJson).flatMap(validationRequest);

/// **Note**: Ideally we should not access `post`, `Uri.parse`, and `jsonDecode` inside the function.
/// 
/// We should instead pass them as inputs to the function. This will allow to make the function
/// completely pure, without hidden dependencies (i.e. accessing variables in the global scope).
/// 
/// Furthermore, doing this will help with testing, since we can provide our own mock
/// implementation of those function for testing purposes.
