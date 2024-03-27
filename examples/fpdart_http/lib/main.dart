import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

void main() async {
  await get(
    Uri.https("pokeapi.co", "/api/v2/pokemon/10"),
  )
      .tap(
        (response) => Effect.functionSucceed(
          () => print(response.body),
        ),
      )
      .provide(
        http.Client(),
      )
      .runFuture();
}
