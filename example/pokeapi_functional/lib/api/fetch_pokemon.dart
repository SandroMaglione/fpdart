import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:pokeapi_functional/models/pokemon.dart';

/// Make HTTP request to fetch pokemon information from the pokeAPI
TaskEither<String, Pokemon> fetchPokemon(int pokemonId) => TaskEither.tryCatch(
      () async {
        final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonId');
        final response = await http.get(url);
        return Pokemon.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      },
      (error, __) => 'Request error: $error',
    );

/// Try to parse the user input from [String] to [int].
/// If successful, then fetch the pokemon information from the [int] id.
TaskEither<String, Pokemon> fetchPokemonFromUserInput(String pokemonId) =>
    TaskEither<String, int>.tryCatch(
      () async => int.parse(pokemonId),
      (error, __) => 'Input error: $error',
    ).flatMap(fetchPokemon);
