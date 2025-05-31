class AuthResult {
  final bool isSuccess;
  final String? token;
  final String? errorMessage;
  final Map<String, dynamic>? userProfile;

  AuthResult({
    required this.isSuccess,
    this.token,
    this.errorMessage,
    this.userProfile
  });

  factory AuthResult.success(String token) {
    return AuthResult(
      isSuccess: true,
      token: token
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
