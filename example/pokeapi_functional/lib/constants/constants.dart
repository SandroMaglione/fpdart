/// App constants under 'Constants' namespace.
// ignore_for_file: avoid_classes_with_only_static_members

abstract class Constants {
  static const int minimumPokemonId = 1;
  static const int maximumPokemonId = 898;
  static String requestAPIUrl(int pokemonId) =>
      'https://pokeapi.co/api/v2/pokemon/$pokemonId';
}
