import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pokeapi_functional/api/fetch_pokemon.dart';
import 'package:pokeapi_functional/models/pokemon.dart';

/// Manage the [Pokemon] state using [Either] to handle possible errors
class PokemonState extends StateNotifier<Either<String, Pokemon>> {
  PokemonState() : super(Either.left('Loading data'));

  /// Initial request, passing the first pokemon id
  Future<Unit> init(int pokemonId) async {
    final pokemon = fetchPokemon(pokemonId);
    state = await pokemon.run();
    return unit;
  }

  /// User request, try to convert user input to [int]
  Future<Unit> fetch(String pokemonId) async {
    final pokemon = fetchPokemonFromUserInput(pokemonId);
    state = await pokemon.run();
    return unit;
  }
}

final pokemonProvider =
    StateNotifierProvider<PokemonState, Either<String, Pokemon>>(
  (ref) => PokemonState(),
);
