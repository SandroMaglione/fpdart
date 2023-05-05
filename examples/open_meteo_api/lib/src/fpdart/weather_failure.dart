// ignore_for_file: comment_references

import 'package:http/http.dart' as http;

/// Abstract class which represents a failure in the `getWeather` request.
abstract class OpenMeteoApiFpdartWeatherFailure {}

/// [OpenMeteoApiFpdartWeatherFailure] when **http request** fails
class WeatherHttpRequestFpdartFailure
    implements OpenMeteoApiFpdartWeatherFailure {
  const WeatherHttpRequestFpdartFailure(this.object, this.stackTrace);
  final Object object;
  final StackTrace stackTrace;
}

/// [OpenMeteoApiFpdartWeatherFailure] when getWeather fails
class WeatherRequestFpdartFailure implements OpenMeteoApiFpdartWeatherFailure {
  const WeatherRequestFpdartFailure(this.response);
  final http.Response response;
}

/// [OpenMeteoApiFpdartWeatherFailure] when weather response is not a valid
/// [Map].
class WeatherInvalidMapFpdartFailure
    implements OpenMeteoApiFpdartWeatherFailure {
  const WeatherInvalidMapFpdartFailure(this.body);
  final String body;
}

/// [OpenMeteoApiFpdartWeatherFailure] when weather information
/// is not found (missing expected key).
class WeatherKeyNotFoundFpdartFailure
    implements OpenMeteoApiFpdartWeatherFailure {}

/// [OpenMeteoApiFpdartWeatherFailure] when weather data is not a valid [List].
class WeatherInvalidListFpdartFailure
    implements OpenMeteoApiFpdartWeatherFailure {
  const WeatherInvalidListFpdartFailure(this.value);
  final dynamic value;
}

/// [OpenMeteoApiFpdartWeatherFailure] when weather for provided location
/// is not found (missing data).
class WeatherDataNotFoundFpdartFailure
    implements OpenMeteoApiFpdartWeatherFailure {}

/// [OpenMeteoApiFpdartWeatherFailure] when the response is not a valid
/// [Weather].
class WeatherFormattingFpdartFailure
    implements OpenMeteoApiFpdartWeatherFailure {
  const WeatherFormattingFpdartFailure(this.object, this.stackTrace);
  final Object object;
  final StackTrace stackTrace;
}
