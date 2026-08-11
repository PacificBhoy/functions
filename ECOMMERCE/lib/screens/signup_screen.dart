import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Account creation screen.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Handle to the Form below, used by _submit to run every field validator
  // in one call. See the same pattern in login_screen.dart.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true; // Toggle for the password field
  bool _obscureConfirmPassword = true; // Toggle for the confirm field
  bool _loading = false; // True while the sign up request is running
  String? _errorMessage; // Shown inline when sign up fails

  @override
  void dispose() {
    // Release every controller this screen created
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Please enter your full name';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    final emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    // Compare against whatever is currently typed in the password field
    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null; // Clear the previous attempt
    });

    // Runs every validator in the Form, including the confirm password check
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Turn on the loading state before awaiting, so the button shows a spinner
    // and refuses further taps until the request finishes.
    setState(() {
      _loading = true;
    });

    final result = await _authService.signup(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // The screen may have been disposed while the request was running
    if (!mounted) return;

    if (result.success) {
      // Sign up also signs the user in, so replace the whole stack with home.
      // pushNamedAndRemoveUntil with a route filter that always returns false
      // clears every earlier route, including the login screen underneath.
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    setState(() {
      _loading = false;
      _errorMessage = result.error ?? 'Sign up failed, please try again';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'), // Title of the app bar
        centerTitle: true, // Center the title
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Scrollable so nothing hides behind the keyboard
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Connects the Form to the GlobalKey above
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Join Shopeasy', // Heading
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Full name field
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !_loading,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_loading,
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
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
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
                ),
                const SizedBox(height: 16),
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: _validateConfirmPassword,
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
                // Sign up button, swaps its label for a spinner while loading
                ElevatedButton(
                  onPressed: _loading ? null : _submit, // null disables it
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text('Sign Up', style: TextStyle(fontSize: 16.0)),
                ),
                const SizedBox(height: 16),
                // Link back to the login screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              // This screen was pushed from login, so popping
                              // returns there without stacking another copy.
                              Navigator.pop(context);
                            },
                      child: const Text('Sign In'),
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
