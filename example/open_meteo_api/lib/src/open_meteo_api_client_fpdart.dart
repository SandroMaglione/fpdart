import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';

abstract class OpenMeteoApiFailure implements Exception {}

/// [OpenMeteoApiFailure] when **http request** fails
class LocationHttpRequestFailure implements OpenMeteoApiFailure {}

/// [OpenMeteoApiFailure] when request is not successful (`status != 200`)
class LocationRequestFailure implements OpenMeteoApiFailure {}

/// [OpenMeteoApiFailure] when the provided location is not found
class LocationNotFoundFailure implements OpenMeteoApiFailure {}

/// [OpenMeteoApiFailure] when the response is not a valid [Location]
class LocationFormattingFailure implements OpenMeteoApiFailure {}

/// [OpenMeteoApiFailure] when getWeather fails
class WeatherRequestFailure implements OpenMeteoApiFailure {}

/// [OpenMeteoApiFailure] when weather for provided location is not found
class WeatherNotFoundFailure implements OpenMeteoApiFailure {}

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
  TaskEither<OpenMeteoApiFailure, Location> locationSearch(String query) =>
      TaskEither<OpenMeteoApiFailure, http.Response>.tryCatch(
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
            (response) =>
                Either<OpenMeteoApiFailure, http.Response>.fromPredicate(
              response,
              (r) => r.statusCode != 200,
              (r) => LocationRequestFailure(),
            ).map((r) => r.body),
          )
          .chainEither(
            (body) => Either<OpenMeteoApiFailure,
                Map<dynamic, dynamic>>.fromPredicate(
              jsonDecode(body) as Map,
              (r) => r.containsKey('results'),
              (r) => LocationRequestFailure(),
            ).map((r) => r['results']),
          )
          .chainEither(
            (results) => Either<OpenMeteoApiFailure, dynamic>.tryCatch(
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
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final weatherRequest = Uri.https(_baseUrlWeather, 'v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current_weather': 'true'
    });

    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final bodyJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    final weatherJson = bodyJson['current_weather'] as Map<String, dynamic>;

    return Weather.fromJson(weatherJson);
  }
}
