import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';

abstract class OpenMeteoApiLocationFailure implements Exception {}

abstract class OpenMeteoApiWeatherFailure implements Exception {}

/// [OpenMeteoApiLocationFailure] when **http request** fails
class LocationHttpRequestFailure implements OpenMeteoApiLocationFailure {}

/// [OpenMeteoApiLocationFailure] when request is not successful (`status != 200`)
class LocationRequestFailure implements OpenMeteoApiLocationFailure {}

/// [OpenMeteoApiLocationFailure] when the provided location is not found
class LocationNotFoundFailure implements OpenMeteoApiLocationFailure {}

/// [OpenMeteoApiLocationFailure] when the response is not a valid [Location]
class LocationFormattingFailure implements OpenMeteoApiLocationFailure {}

/// [OpenMeteoApiWeatherFailure] when **http request** fails
class WeatherHttpRequestFailure implements OpenMeteoApiWeatherFailure {}

/// [OpenMeteoApiWeatherFailure] when getWeather fails
class WeatherRequestFailure implements OpenMeteoApiWeatherFailure {}

/// [OpenMeteoApiWeatherFailure] when weather for provided location is not found
class WeatherNotFoundFailure implements OpenMeteoApiWeatherFailure {}

/// [OpenMeteoApiLocationFailure] when the response is not a valid [Weather]
class WeatherFormattingFailure implements OpenMeteoApiWeatherFailure {}

/// {@template open_meteo_api_client}
/// Dart API Client which wraps the [Open Meteo API](https://open-meteo.com).
/// {@endtemplate}
class OpenMeteoApiClient {
  /// {@macro open_meteo_api_client}
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrlWeather = 'api.open-meteo.com';
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  final http.Client _httpClient;

  /// Finds a [Location] `/v1/search/?name=(query)`.
  TaskEither<OpenMeteoApiLocationFailure, Location> locationSearch(
          String query) =>
      TaskEither<OpenMeteoApiLocationFailure, http.Response>.tryCatch(
        () => _httpClient.get(
          Uri.https(
            _baseUrlGeocoding,
            '/v1/search',
            {'name': query, 'count': '1'},
          ),
        ),
        (_, __) => LocationHttpRequestFailure(),
      )
          .chainEither(
            (response) => Either<OpenMeteoApiLocationFailure,
                http.Response>.fromPredicate(
              response,
              (r) => r.statusCode != 200,
              (r) => LocationRequestFailure(),
            ).map((r) => r.body),
          )
          .chainEither(
            (body) => Either<OpenMeteoApiLocationFailure,
                Map<dynamic, dynamic>>.fromPredicate(
              jsonDecode(body) as Map,
              (r) => r.containsKey('results'),
              (r) => LocationRequestFailure(),
            ).map((r) => r['results']),
          )
          .chainEither(
            (results) => Either<OpenMeteoApiLocationFailure, dynamic>.tryCatch(
              () => (results as List).first,
              (_, __) => LocationNotFoundFailure(),
            ),
          )
          .chainEither(
            (r) => Either.tryCatch(
              () => Location.fromJson(r as Map<String, dynamic>),
              (_, __) => LocationFormattingFailure(),
            ),
          );

  /// Fetches [Weather] for a given [latitude] and [longitude].
  TaskEither<OpenMeteoApiWeatherFailure, Weather> getWeather({
    required double latitude,
    required double longitude,
  }) =>
      TaskEither<OpenMeteoApiWeatherFailure, http.Response>.tryCatch(
        () async => _httpClient.get(
          Uri.https(
            _baseUrlWeather,
            'v1/forecast',
            {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current_weather': 'true'
            },
          ),
        ),
        (_, __) => WeatherHttpRequestFailure(),
      )
          .chainEither(
            _validResponseBodyCurry(
              (response) => WeatherRequestFailure(),
            ),
          )
          .chainEither(
            (body) =>
                (jsonDecode(body) as Map).lookup('current_weather').toEither(
                      WeatherRequestFailure.new,
                    ),
          )
          .chainEither(
            (results) => (results as List).head.toEither(
                  WeatherNotFoundFailure.new,
                ),
          )
          .chainEither(
            (weather) => Either.tryCatch(
              () => Weather.fromJson(weather as Map<String, dynamic>),
              (_, __) => WeatherFormattingFailure(),
            ),
          );

  /// Verify that the response status code is 200,
  /// and extract the response's body.
  Either<E, String> _validResponseBody<E>(
    E Function(http.Response) onError,
    http.Response response,
  ) =>
      Either<E, http.Response>.fromPredicate(
        response,
        (r) => r.statusCode != 200,
        onError,
      ).map((r) => r.body);

  /// Use `curry2` to make the function more concise.
  final _validResponseBodyCurry = curry2<
      OpenMeteoApiWeatherFailure Function(http.Response),
      http.Response,
      Either<OpenMeteoApiWeatherFailure, String>>(
    _validResponseBody,
  );
}
