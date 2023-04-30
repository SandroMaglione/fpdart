import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:pokeapi_functional/constants/constants.dart';
import 'package:pokeapi_functional/models/pokemon.dart';

/// Parse [String] to [int] in a functional way using [IOEither].
IOEither<String, int> _parseStringToInt(String str) => IOEither.tryCatch(
      () => int.parse(str),
      (_, __) =>
          'Cannot convert input to valid pokemon id (it must be a number)!',
    );

/// Validate the pokemon id inserted by the user:
/// 1. Parse [String] from the user to [int]
/// 2. Check pokemon id in valid range
///
/// Chain (1) and (2) using `flatMap`.
IOEither<String, int> _validateUserPokemonId(String pokemonId) =>
    _parseStringToInt(pokemonId).flatMap(
      (intPokemonId) => IOEither.fromPredicate(
        intPokemonId,
        (id) =>
            id >= Constants.minimumPokemonId &&
            id <= Constants.maximumPokemonId,
        (id) =>
            'Invalid pokemon id $id: the id must be between ${Constants.minimumPokemonId} and ${Constants.maximumPokemonId + 1}!',
      ),
    );

/// Make HTTP request to fetch pokemon information from the pokeAPI
/// using [TaskEither] to perform an async request in a composable way.
TaskEither<String, Pokemon> fetchPokemon(int pokemonId) => TaskEither.tryCatch(
      () async {
        final url = Uri.parse(Constants.requestAPIUrl(pokemonId));
        final response = await http.get(url);
        return Pokemon.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      },
      (error, __) => 'Unknown error: $error',
    );

/// Try to parse the user input from [String] to [int] using [IOEither].
/// We use [IOEither] since the `parse` method is **synchronous** (no need of [Future]).
///
/// Then check that the pokemon id is in the valid range.
///
/// If the validation is successful, then fetch the pokemon information from the [int] id.
///
/// All the functions are simply chained together following the principle of composability.
TaskEither<String, Pokemon> fetchPokemonFromUserInput(String pokemonId) =>
    _validateUserPokemonId(pokemonId).flatMapTask(fetchPokemon);

TaskEither<String, Pokemon> fetchRandomPokemon() => randomInt(
      Constants.minimumPokemonId,
      Constants.maximumPokemonId + 1,
    ).toTaskEither<String>().flatMap((r) => fetchPokemon(r));
