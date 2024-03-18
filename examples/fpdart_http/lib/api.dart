import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'http_error.dart';

/// 1️⃣ Define dependencies, errors, response
Effect<http.Client, HttpError, http.Response> get(
  Uri url, {
  Map<String, String>? headers,
}) =>

    /// 2️⃣ Use the Do notation with the `gen` constructor
    Effect.gen((_) async {
      /// 3️⃣ Extract the dependency using `env` (environment)
      final client = await _(Effect.env());

      /// 4️⃣ Perform a request, catch errors, extract the response
      final response = await _(Effect.tryCatch(
        execute: () => client.get(url, headers: headers),
        onError: (_, __) => const RequestError(),
      ));

      /// 5️⃣ Use plain dart code to check for valid status
      if (response.statusCode != 200) {
        return await _(Effect.fail(const ResponseError()));
      }

      /// 6️⃣ Return extracted/valid response
      return response;
    });
