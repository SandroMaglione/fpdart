sealed class PokemonError {
  const PokemonError();
}

class PokemonIdNotInt extends PokemonError {
  const PokemonIdNotInt();
}

class InvalidPokemonIdRange extends PokemonError {
  const InvalidPokemonIdRange();
}

class GetPokemonRequestError extends PokemonError {
  const GetPokemonRequestError();
}

class PokemonJsonDecodeError extends PokemonError {
  const PokemonJsonDecodeError();
}

class PokemonJsonInvalidMap extends PokemonError {
  const PokemonJsonInvalidMap();
}

class PokemonInvalidJsonModel extends PokemonError {
  const PokemonInvalidJsonModel();
}
