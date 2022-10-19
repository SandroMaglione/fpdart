import 'package:http/http.dart' as http;

/// Abstract class which represents a failure in the `locationSearch` request.
abstract class OpenMeteoApiFpdartLocationFailure {}

/// [OpenMeteoApiFpdartLocationFailure] when **http request** fails
class LocationHttpRequestFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {
  const LocationHttpRequestFpdartFailure(this.object, this.stackTrace);
  final Object object;
  final StackTrace stackTrace;
}

/// [OpenMeteoApiFpdartLocationFailure] when request is not successful
/// (`status != 200`)
class LocationRequestFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {
  const LocationRequestFpdartFailure(this.response);
  final http.Response response;
}

/// [OpenMeteoApiFpdartLocationFailure] when location response
/// cannot be decoded from json.
class LocationInvalidJsonDecodeFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {
  const LocationInvalidJsonDecodeFpdartFailure(this.body);
  final String body;
}

/// [OpenMeteoApiFpdartLocationFailure] when location response is not a valid [Map].
class LocationInvalidMapFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {
  const LocationInvalidMapFpdartFailure(this.json);
  final dynamic json;
}

/// [OpenMeteoApiFpdartLocationFailure] when location information
/// is not found (missing expected key).
class LocationKeyNotFoundFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {}

/// [OpenMeteoApiFpdartLocationFailure] when location data is not a valid [List].
class LocationInvalidListFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {
  const LocationInvalidListFpdartFailure(this.value);
  final dynamic value;
}

/// [OpenMeteoApiFpdartLocationFailure] when location for provided location
/// is not found (missing data).
class LocationDataNotFoundFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {}

/// [OpenMeteoApiFpdartLocationFailure] when the response is not
/// a valid [Location]
class LocationFormattingFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {
  const LocationFormattingFpdartFailure(this.object, this.stackTrace);
  final Object object;
  final StackTrace stackTrace;
}
