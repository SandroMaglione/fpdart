import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:poke_api/constants.dart';
import 'package:poke_api/pokemon.dart';
import 'package:poke_api/pokemon_error.dart';

abstract interface class HttpClient {
  String get(Uri uri);
}

Effect<(HttpClient, JsonCodec), PokemonError, Pokemon> program(
  String pokemonId,
) =>
    Effect.gen(($) async {
      final (client, json) = $.sync(Effect.env());

      final id = $.sync(
        Either.fromNullable(
          int.tryParse(pokemonId),
          PokemonIdNotInt.new,
        ),
      );

      if (id < Constants.minimumPokemonId && id > Constants.maximumPokemonId) {
        return $.sync(Effect.fail(const InvalidPokemonIdRange()));
      }

      final uri = Uri.parse(Constants.requestAPIUrl(id));
      final body = await $.async(Effect.tryCatch(
        execute: () => client.get(uri),
        onError: (_, __) => const GetPokemonRequestError(),
      ));

      final bodyJson = $.sync(Either.tryCatch(
        execute: () => json.decode(body),
        onError: (_, __) => const PokemonJsonDecodeError(),
      ));

      final bodyJsonMap = $.sync<Map<String, dynamic>>(
        Either.safeCastStrict(
          bodyJson,
          (value) => const PokemonJsonInvalidMap(),
        ),
      );

      return $.sync(Effect.tryCatch(
        execute: () => Pokemon.fromJson(bodyJsonMap),
        onError: (_, __) => const PokemonInvalidJsonModel(),
      ));
    });
