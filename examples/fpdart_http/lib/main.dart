import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

void main() async {
  final main = await get(
    Uri.https("pokeapi.co", "/api/v2/pokemon/10"),
  )
      .tap(
        (response) => Effect.function(
          () => print(response.body),
        ),
      )
      .runFuture(
        http.Client(),
      );
}
