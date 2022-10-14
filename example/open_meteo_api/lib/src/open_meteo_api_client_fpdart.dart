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

  TaskEither<OpenMeteoApiFailure, Location> locationSearch2(String query) =>
      TaskEither<OpenMeteoApiFailure, http.Response>.tryCatch(
        () => _httpClient.get(
          Uri.https(
            _baseUrlGeocoding,
            '/v1/search',
            {'name': query, 'count': '1'},
          ),
        ),
        (error, stackTrace) => LocationHttpRequestFailure(),
      )
          .flatMap(
        (response) => (response.statusCode != 200
                ? Either<OpenMeteoApiFailure, String>.left(
                    LocationRequestFailure(),
                  )
                : Either<OpenMeteoApiFailure, String>.of(response.body))
            .toTaskEither(),
      )
          .flatMap(
        (r) {
          final locationJson = jsonDecode(r) as Map;
          return (!locationJson.containsKey('results')
                  ? Either<OpenMeteoApiFailure, dynamic>.left(
                      LocationNotFoundFailure(),
                    )
                  : Either<OpenMeteoApiFailure, dynamic>.of(
                      locationJson['results'],
                    ))
              .toTaskEither();
        },
      ).flatMap(
        (r) {
          final results = r as List;
          return (results.isEmpty
                  ? Either<OpenMeteoApiFailure, dynamic>.left(
                      LocationNotFoundFailure(),
                    )
                  : Either<OpenMeteoApiFailure, dynamic>.of(
                      results.first,
                    ))
              .toTaskEither();
        },
      ).flatMap(
        (r) => Either.tryCatch(
          () => Location.fromJson(r as Map<String, dynamic>),
          (o, s) => LocationFormattingFailure(),
        ).toTaskEither(),
      );

  /// Finds a [Location] `/v1/search/?name=(query)`.
  Future<Location> locationSearch(String query) async {
    final locationRequest = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      {'name': query, 'count': '1'},
    );

    final locationResponse = await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }

    final locationJson = jsonDecode(locationResponse.body) as Map;

    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

    final results = locationJson['results'] as List;

    if (results.isEmpty) throw LocationNotFoundFailure();

    return Location.fromJson(results.first as Map<String, dynamic>);
  }

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
