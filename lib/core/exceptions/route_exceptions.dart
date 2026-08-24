export 'backend_required_exception.dart';

class BackendUnavailableException implements Exception {
  final String message;
  BackendUnavailableException(this.message);
  @override
  String toString() => 'BackendUnavailableException: $message';
}

class RouteApiException implements Exception {
  final String message;
  RouteApiException(this.message);
  @override
  String toString() => 'RouteApiException: $message';
}

class InvalidRouteRequestException implements Exception {
  final String message;
  InvalidRouteRequestException(this.message);
  @override
  String toString() => 'InvalidRouteRequestException: $message';
}

class RouteTimeoutException implements Exception {
  final String message;
  RouteTimeoutException(this.message);
  @override
  String toString() => 'RouteTimeoutException: $message';
}
