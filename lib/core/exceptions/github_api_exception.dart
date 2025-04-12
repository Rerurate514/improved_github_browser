class GitHubApiException implements Exception {
  final int statusCode;
  final String message;

  GitHubApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GitHubApiException: $statusCode - $message';
}
