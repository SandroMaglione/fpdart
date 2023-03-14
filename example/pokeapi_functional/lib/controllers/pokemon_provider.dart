import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/fetch_pokemon.dart';
import '../constants/constants.dart';
import '../models/pokemon.dart';

part 'pokemon_provider.g.dart';

@riverpod
class PokemonState extends _$PokemonState {
  @override
  FutureOr<Pokemon> build() async {
    final poke = (await fetchPokemon(
      randomInt(
        Constants.minimumPokemonId,
        Constants.maximumPokemonId + 1,
      ).run(),
    ).run());

    return poke.match((l) => throw l, (r) => r);
  }

  /// Initial request, fetch random pokemon passing the pokemon id.
  Future<Unit> fetchRandom() async => _pokemonRequest(
        () => fetchPokemon(
          randomInt(
            Constants.minimumPokemonId,
            Constants.maximumPokemonId + 1,
          ).run(),
        ),
      );

  /// User request, try to convert user input to [int] and then
  /// request the pokemon if successful.
  Future<Unit> fetch(String pokemonId) async => _pokemonRequest(
        () => fetchPokemonFromUserInput(pokemonId),
      );

  /// Generic private method to perform request and update the state.
  Future<Unit> _pokemonRequest(
    TaskEither<String, Pokemon> Function() request,
  ) async {
    state = AsyncLoading();
    final pokemon = request();
    state = (await pokemon.run()).match(
        (error) => AsyncError(error, StackTrace.current),
        (pokemon) => AsyncData(pokemon));
    return unit;
  }
}
