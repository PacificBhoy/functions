// Storage package used to remember the login state between app launches
import 'package:shared_preferences/shared_preferences.dart';

/// The value every auth call returns.
///
/// The UI never sees how the login actually happened, it only reads
/// [success] and [error]. That means a real backend can replace the mock
/// code below without any of the screen files changing.
class AuthResult {
  final bool success; // true when the call worked
  final String? error; // human readable message, only set when success is false

  // Named constructor for the happy path
  const AuthResult.success()
      : success = true,
        error = null;

  // Named constructor for the failure path, carries the message to show
  const AuthResult.failure(this.error) : success = false;
}

/// Mock authentication service.
///
/// Every method waits one second to imitate a network request, then reports
/// success. Replace the bodies with real API calls later, the signatures can
/// stay exactly the same.
class AuthService {
  // Keys used inside shared_preferences. They are private constants so a typo
  // in one place cannot silently read a different value somewhere else.
  static const String _loggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  // Pretend network delay, kept in one place so it is easy to remove
  static const Duration _fakeNetworkDelay = Duration(seconds: 1);

  /// Signs an existing user in.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_fakeNetworkDelay); // stand in for the API call

    // A real service would send the credentials and check the response here.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_userEmailKey, email);

    return const AuthResult.success();
  }

  /// Creates a new account and signs the user in.
  Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(_fakeNetworkDelay); // stand in for the API call

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, fullName);

    return const AuthResult.success();
  }

  /// Clears the stored session.
  Future<void> logout() async {
    await Future.delayed(_fakeNetworkDelay); // stand in for the API call

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
  }

  /// Reads the saved login state. The splash screen calls this to decide
  /// whether to show the login screen or jump straight to the home page.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // getBool returns null when the key was never written, so default to false
    return prefs.getBool(_loggedInKey) ?? false;
  }

  /// Email of the signed in user, or null when nobody is signed in.
  Future<String?> currentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
}
