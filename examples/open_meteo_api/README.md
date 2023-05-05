# Open Meteo API - `fpdart`
This is a re-implementation using `fpdart` and functional programming of the [Open Meteo API](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/packages/open_meteo_api) from the [flutter_weather](https://bloclibrary.dev/#/flutterweathertutorial) app example in the [bloc](https://pub.dev/packages/bloc) package.

The goal is to show a comparison between usual dart code and functional code written using `fpdart`.

## Structure
The example is simple but comprehensive.

The Open Meteo API implementation is only 1 file. The original source is [open_meteo_api_client.dart](./lib/src/open_meteo_api_client.dart) (copy of the [bloc package implementation](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/packages/open_meteo_api/lib/src/open_meteo_api_client.dart)).

Inside [lib/src/fpdart](./lib/src/fpdart/) you can then find the refactoring using functional programming and `fpdart`:
- [open_meteo_api_client_fpdart.dart](./lib/src/fpdart/open_meteo_api_client_fpdart.dart): implementation of the Open Meteo API with `fpdart`
- [location_failure.dart](./lib/src/fpdart/location_failure.dart): failure classes for the `locationSearch` request
- [weather_failure.dart](./lib/src/fpdart/weather_failure.dart): failure classes for the `getWeather` request

### Test
Also the [test](./test/) has been rewritten based on the `fpdart` refactoring:
- [open_meteo_api_client_test.dart](./test/open_meteo_api_client_test.dart): Original Open Meteo API test implementation
- [open_meteo_api_client_test_fpdart.dart](./test/open_meteo_api_client_test_fpdart.dart): Testing for the new implementation using `fpdart` and functional programming

## Types used from `fpdart`
- `TaskEither`: Used instead of `Future` to make async request that may fail
- `Either`: Used to validate the response from the API with either an error or a valid value
- `Option`: Used to get values that may be missing
  - `lookup` in a `Map`: getting a value by key in a `Map` may return nothing if the key is not found
  - `head` in a `List`: The list may be empty, so getting the first element (called _"head"_) may return nothing