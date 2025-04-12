class DomainException implements Exception {
  final String message;
  DomainException(this.message);
  
  @override
  String toString() => 'DomainException: $message';
}
