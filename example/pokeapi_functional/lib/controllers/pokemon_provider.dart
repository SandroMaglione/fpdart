import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pokeapi_functional/api/fetch_pokemon.dart';
import 'package:pokeapi_functional/constants/constants.dart';
import 'package:pokeapi_functional/models/pokemon.dart';
import 'package:pokeapi_functional/unions/request_status.dart';

/// Manage the [Pokemon] state using [Either] ([TaskEither]) to handle possible errors.
///
/// Each [RequestStatus] change the UI displayed to the user.
class PokemonState extends StateNotifier<RequestStatus> {
  PokemonState() : super(const RequestStatus.initial());

  /// Initial request, fetch random pokemon passing the pokemon id.
  Future<Unit> fetchRandom() async => _pokemonRequest(
        () => fetchPokemon(
          randomInt(
            Constants.minimumPokemonId,
            Constants.maximumPokemonId + 1,
          ).run(),
        ),
      );

  /// User request, try to convert user input to [int].
  Future<Unit> fetch(String pokemonId) async => _pokemonRequest(
        () => fetchPokemonFromUserInput(pokemonId),
      );

  /// Generic private method to perform request and update the state.
  Future<Unit> _pokemonRequest(
    TaskEither<String, Pokemon> Function() request,
  ) async {
    state = RequestStatus.loading();
    final pokemon = request();
    state = (await pokemon.run()).match(
      (error) => RequestStatus.error(error),
      (pokemon) => RequestStatus.success(pokemon),
    );
    return unit;
  }
}

final pokemonProvider = StateNotifierProvider<PokemonState, RequestStatus>(
  (_) => PokemonState(),
);
