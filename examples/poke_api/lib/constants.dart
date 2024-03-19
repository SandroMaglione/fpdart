abstract interface class Constants {
  static const int minimumPokemonId = 1;
  static const int maximumPokemonId = 898;

  static String requestAPIUrl(int pokemonId) =>
      'https://pokeapi.co/api/v2/pokemon/$pokemonId';
}
