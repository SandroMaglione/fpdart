// ignore_for_file: prefer_const_constructors, lines_longer_than_80_chars
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/fpdart/location_failure.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void _isLeftOfType<E, R, T>(
  Either<E, R> result, {
  dynamic Function(TypeMatcher<T>)? typeMatch,
}) {
  expect(result, isA<Left<E, R>>());
  result.match(
    (l) => expect(l, typeMatch != null ? typeMatch(isA<T>()) : isA<T>()),
    (_) => fail('should not be right'),
  );
}

void main() {
  group('OpenMeteoApiClientFpdart', () {
    late http.Client httpClient;
    late OpenMeteoApiClientFpdart apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClientFpdart(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OpenMeteoApiClientFpdart(), isNotNull);
      });
    });

    group('locationSearch', () {
      const query = 'mock-query';
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        /// No need of try/catch
        await apiClient.locationSearch(query).run();

        verify(
          () => httpClient.get(
            Uri.https(
              'geocoding-api.open-meteo.com',
              '/v1/search',
              {'name': query, 'count': '1'},
            ),
          ),
        ).called(1);
      });

      test('returns LocationHttpRequestFpdartFailure when http request fails',
          () async {
        when(() => httpClient.get(any())).thenThrow(Exception());

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationHttpRequestFpdartFailure>(
          result,
          typeMatch: (m) => m.having(
            (failure) => failure.object,
            'Exception',
            isA<Exception>(),
          ),
        );
      });

      test('returns LocationRequestFpdartFailure on non-200 response',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationRequestFpdartFailure>(
          result,
          typeMatch: (m) => m.having(
            (failure) => failure.response,
            'MockResponse',
            response,
          ),
        );
      });

      test(
          'returns LocationInvalidJsonDecodeFpdartFailure when response is invalid',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('_{}_');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationInvalidJsonDecodeFpdartFailure>(
          result,
          typeMatch: (m) => m.having(
            (failure) => failure.body,
            'body',
            '_{}_',
          ),
        );
      });

      test('returns LocationInvalidMapFpdartFailure when response is not a Map',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('[]');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationInvalidMapFpdartFailure>(
          result,
          typeMatch: (m) => m.having(
            (failure) => failure.json,
            'json',
            [],
          ),
        );
      });

      test(
          'returns LocationKeyNotFoundFpdartFailure when the response is missing the correct key',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationKeyNotFoundFpdartFailure>(result);
      });

      test(
          'returns LocationInvalidListFpdartFailure when Map key does not contain a valid List',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results": {}}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationInvalidListFpdartFailure>(
          result,
          typeMatch: (m) => m.having(
            (failure) => failure.value,
            'value',
            {},
          ),
        );
      });

      test('returns LocationDataNotFoundFpdartFailure on empty response',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results": []}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationDataNotFoundFpdartFailure>(result);
      });

      test(
          'returns LocationFormattingFpdartFailure when response is not a correct Location object',
          () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
  "results": [
    {
      "_id": 4887398,
      "_name": "Chicago",
      "_latitude": 41.85003,
      "_longitude": -87.65005
    }
  ]
}''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();

        _isLeftOfType<OpenMeteoApiFpdartLocationFailure, Location,
            LocationFormattingFpdartFailure>(result);
      });

      test('returns Location on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
  "results": [
    {
      "id": 4887398,
      "name": "Chicago",
      "latitude": 41.85003,
      "longitude": -87.65005
    }
  ]
}''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        final result = await apiClient.locationSearch(query).run();
        expect(
          result,
          isA<Right<OpenMeteoApiFpdartLocationFailure, Location>>()
              .having((l) => l.value.name, 'name', 'Chicago')
              .having((l) => l.value.id, 'id', 4887398)
              .having((l) => l.value.latitude, 'latitude', 41.85003)
              .having((l) => l.value.longitude, 'longitude', -87.65005),
        );
      });
    });
  });
}
