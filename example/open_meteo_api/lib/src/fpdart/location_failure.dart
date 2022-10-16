abstract class OpenMeteoApiFpdartLocationFailure implements Exception {}

/// [OpenMeteoApiFpdartLocationFailure] when **http request** fails
class LocationHttpRequestFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {}

/// [OpenMeteoApiFpdartLocationFailure] when request is not successful
/// (`status != 200`)
class LocationRequestFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {}

/// [OpenMeteoApiFpdartLocationFailure] when the provided location is not found
class LocationNotFoundFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {}

/// [OpenMeteoApiFpdartLocationFailure] when the response is not
/// a valid [Location]
class LocationFormattingFpdartFailure
    implements OpenMeteoApiFpdartLocationFailure {}
