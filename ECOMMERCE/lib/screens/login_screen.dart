import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Email and password sign in screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // A GlobalKey is a handle to a widget that lives somewhere else in the tree.
  // This one lets us reach the Form below from inside our own methods, which is
  // how _submit can call _formKey.currentState!.validate() and run every field
  // validator at once. Without the key there is no way to talk to that Form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true; // Controls the show/hide password toggle
  bool _loading = false; // True while the login request is running
  String? _errorMessage; // Shown inline under the fields when login fails

  @override
  void dispose() {
    // Controllers hold resources, so they must be released with the screen
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validator for the email field. Returning null means valid, returning a
  // string means invalid and that string is shown under the field.
  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    // Simple check for text, an @, more text, a dot and a domain ending
    final emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    // Clear any error left over from a previous attempt
    setState(() {
      _errorMessage = null;
    });

    // Runs every validator in the Form. If any of them returns a string the
    // form is invalid, the messages appear under the fields and we stop here.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Flip into the loading state before the await so the button immediately
    // shows a spinner and stops accepting taps while the request is in flight.
    setState(() {
      _loading = true;
    });

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // The await above may have taken long enough for this screen to be gone,
    // so check before calling setState or touching the navigator.
    if (!mounted) return;

    if (result.success) {
      // pushReplacement drops the login screen from the history, so pressing
      // back from the home page does not return the user to the login form.
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // Failed, so leave the loading state and show the reason inline
    setState(() {
      _loading = false;
      _errorMessage = result.error ?? 'Login failed, please try again';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'), // Title of the app bar
        centerTitle: true, // Center the title
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Scrollable so the fields stay reachable when the keyboard opens
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Connects the Form to the GlobalKey declared above
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.shopping_bag, // Stand in logo
                  size: 64.0,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome back', // Heading
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_loading, // Locked while the request runs
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Hides the characters
                  textInputAction: TextInputAction.done,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    // Show/hide password toggle
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(), // Enter key submits
                ),
                // Inline error message, only built when there is one to show
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ],
                const SizedBox(height: 24),
                // Login button, swaps its label for a spinner while loading
                ElevatedButton(
                  // A null onPressed disables the button, which is what stops
                  // a second tap from firing another login request.
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 16.0)),
                ),
                const SizedBox(height: 16),
                // Link to the sign up screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              // push, not pushReplacement, so the sign up
                              // screen can pop straight back to this one
                              Navigator.pushNamed(context, '/signup');
                            },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
