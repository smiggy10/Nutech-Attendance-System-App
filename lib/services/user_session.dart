class UserSession {
  UserSession._();

  static String? _loginIdentifier;

  static String? get loginIdentifier => _loginIdentifier;

  static void setLoginIdentifier(String value) {
    final trimmed = value.trim();
    _loginIdentifier = trimmed.isEmpty ? null : trimmed;
  }

  static void clear() {
    _loginIdentifier = null;
  }
}