import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

void main() async {
  await get(
    Uri.https("pokeapi.co", "/api/v2/pokemon/10"),
  )
      .timeout(Duration(milliseconds: 1300))
      .tap(
        (response) => Effect.succeedLazy(
          () => print(response.body),
        ),
      )
      .provideEnv(
        http.Client(),
      )
      .runFuture();
}
