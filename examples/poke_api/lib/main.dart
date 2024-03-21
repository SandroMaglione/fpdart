import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:poke_api/constants.dart';
import 'package:poke_api/pokemon.dart';
import 'package:poke_api/pokemon_error.dart';

abstract interface class HttpClient {
  Effect<void, PokemonError, String> get(Uri uri);
}

class Http implements HttpClient {
  @override
  Effect<void, PokemonError, String> get(Uri uri) => Effect.gen(
        ($) async {
          final response = await $.async(Effect.tryCatch(
            execute: () => http.get(uri),
            onError: (error, stackTrace) => const GetPokemonRequestError(),
          ));

          return response.body;
        },
      );
}

typedef Env = (HttpClient, JsonCodec);

Effect<Env, PokemonError, Pokemon> program(
  String pokemonId,
) =>
    Effect.gen(($) async {
      final (client, json) = $.sync(Effect.env());

      final id = $.sync(Either.fromNullable(
        int.tryParse(pokemonId),
        PokemonIdNotInt.new,
      ).provide());

      if (id < Constants.minimumPokemonId && id > Constants.maximumPokemonId) {
        return $.sync(Effect.fail(const InvalidPokemonIdRange()));
      }

      final uri = Uri.parse(Constants.requestAPIUrl(id));
      final body = await $.async(client.get(uri).provideVoid());

      final bodyJson = $.sync(Either.tryCatch(
        execute: () => json.decode(body),
        onError: (_, __) => const PokemonJsonDecodeError(),
      ).provide());

      final bodyJsonMap = $.sync<Map<String, dynamic>>(
        Either.safeCastStrict<PokemonError, Map<String, dynamic>, dynamic>(
          bodyJson,
          (value) => const PokemonJsonInvalidMap(),
        ).provide(),
      );

      return $.sync(Effect.tryCatch(
        execute: () => Pokemon.fromJson(bodyJsonMap),
        onError: (_, __) => const PokemonInvalidJsonModel(),
      ));
    });

void main() async {
  await program("721")
      .map((pokemon) => print(pokemon))
      .catchError(
        (error) => Effect.function(
          () => print("No pokemon: $error"),
        ),
      )
      .runFuture((Http(), JsonCodec()));
}
