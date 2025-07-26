import 'dart:async';

import 'package:enquete_online_app_mobile/services/auth_service.dart';
import 'package:enquete_online_app_mobile/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin(Future<bool> Function() loginMethod) async {
    setState(() => _isLoading = true);
    final success = await loginMethod();
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2329),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("e-Enquetes", style: TextStyle(color: Colors.white, fontSize: 30)),
                  SizedBox(height: 10),
                  Image.asset("assets/images/icon-enquete.png", width: 100),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                    label: Text('Entrar com Google'),
                    onPressed: () => _handleLogin(_authService.loginWithGoogle),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(220, 48),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                    label: Text('Entrar com Facebook'),
                    onPressed: () => _handleLogin(_authService.loginWithFacebook),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      minimumSize: Size(220, 48),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
