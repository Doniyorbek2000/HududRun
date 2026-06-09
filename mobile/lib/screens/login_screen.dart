import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/user.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiService apiService;
  final ValueChanged<User> onAuthenticated;

  const LoginScreen({
    super.key,
    required this.apiService,
    required this.onAuthenticated,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await widget.apiService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      widget.onAuthenticated(user);
    } catch (_) {
      setState(() {
        _error = 'Login failed. Verify your credentials and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegister() async {
    final result = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(apiService: widget.apiService),
      ),
    );

    if (result != null) {
      widget.onAuthenticated(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF051023), Color(0xFF0A1F3F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'HududRun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Territory battle reimagined for premium mobile runners.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1A34),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFFF6B6B)),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading ? null : _openRegister,
                          child: const Text('Create a new account'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Why HududRun?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _FeatureTile(
                          icon: Icons.map,
                          label: 'Live zones',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureTile(
                          icon: Icons.emoji_events,
                          label: 'Rank battles',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Expanded(
                        child: _FeatureTile(
                          icon: Icons.bolt,
                          label: 'Power modes',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FeatureTile(
                          icon: Icons.workspace_premium,
                          label: 'Premium rewards',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1A34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF7B92FF)),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
