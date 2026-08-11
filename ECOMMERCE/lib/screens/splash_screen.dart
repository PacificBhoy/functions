import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// First screen the app shows.
///
/// On launch it checks whether a session was saved. A returning user is sent
/// straight to the home page, everyone else sees a welcome screen with a
/// "Get Started" button that leads to the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  // True while the saved login state is being read. The button is hidden
  // until this finishes, so a logged in user never sees it flash past.
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    // initState cannot be async itself, so it kicks off the async work and
    // lets it finish on its own while the first frame is being drawn.
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final bool loggedIn = await _authService.isLoggedIn();

    // After an await the user may have left this screen already. Touching the
    // navigator or calling setState with a dead context throws, so stop here.
    if (!mounted) return;

    if (loggedIn) {
      // pushReplacement swaps this route for the new one instead of stacking
      // it on top. The splash is removed from the history, so the back gesture
      // can never bring the user back to it.
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // Nobody is signed in, so reveal the Get Started button and wait for a tap
    setState(() {
      _checkingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Brand colored background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.shopping_bag, // Stand in logo until a real asset exists
                size: 90.0,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Shopeasy', // App name
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Everything you need, in one place', // Tagline
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              // While the saved login state is being read there is nothing for
              // the user to do yet, so show a spinner in the button's place.
              if (_checkingAuth)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    // pushReplacement again, so the welcome screen is dropped
                    // from the history and back cannot return to it.
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White button on blue
                    foregroundColor: Colors.blue, // Blue label
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
