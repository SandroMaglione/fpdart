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
      final (client, json) = await $(Effect.env());

      final id = await $(
        Either.fromNullable(
          int.tryParse(pokemonId),
          PokemonIdNotInt.new,
        ),
      );

      if (id < Constants.minimumPokemonId && id > Constants.maximumPokemonId) {
        return await $(Effect.fail(const InvalidPokemonIdRange()));
      }

      final uri = Uri.parse(Constants.requestAPIUrl(id));
      final body = await $(Effect.tryCatch(
        execute: () => client.get(uri),
        onError: (_, __) => const GetPokemonRequestError(),
      ));

      final bodyJson = await $(Either.tryCatch(
        execute: () => json.decode(body),
        onError: (_, __) => const PokemonJsonDecodeError(),
      ));

      final bodyJsonMap = await $<Map<String, dynamic>>(
        Either.safeCastStrict(
          bodyJson,
          (value) => const PokemonJsonInvalidMap(),
        ),
      );

      return $(Effect.tryCatch(
        execute: () => Pokemon.fromJson(bodyJsonMap),
        onError: (_, __) => const PokemonInvalidJsonModel(),
      ));
    });
