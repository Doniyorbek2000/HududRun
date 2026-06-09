import 'dart:convert';

import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  final ApiService apiService;

  const RegisterScreen({super.key, required this.apiService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (username.isEmpty) {
      setState(() {
        _error = 'Username is required.';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _error = 'Password must be at least 8 characters long.';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await widget.apiService.register(username, phone, password);
      if (mounted) {
        Navigator.of(context).pop<User>(user);
      }
    } catch (error) {
      setState(() {
        if (error is ApiException) {
          try {
            final body = jsonDecode(error.body) as Map<String, dynamic>;
            _error =
                body['message'] as String? ??
                'Registration failed. Try a different username or phone.';
          } catch (_) {
            _error = 'Registration failed. Try a different username or phone.';
          }
        } else {
          _error = 'Registration failed. Try a different username or phone.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF051025),
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome to HududRun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up and begin your premium territory battle journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1A34),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  padding: const EdgeInsets.all(22),
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
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
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
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
