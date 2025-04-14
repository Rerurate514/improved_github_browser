class AuthResult {
  final bool isSuccess;
  final String? token;
  final String? errorMessage;

  AuthResult({
    required this.isSuccess,
    this.token,
    this.errorMessage,
  });

  factory AuthResult.success(String token) {
    return AuthResult(
      isSuccess: true,
      token: token,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
