class LocationPermissionDeniedException implements Exception {
  final String message;

  LocationPermissionDeniedException(this.message);
}
