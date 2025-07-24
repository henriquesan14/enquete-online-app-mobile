import 'dart:async';
import 'dart:convert';

import 'package:enquete_online_app_mobile/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _storage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final _isLoading = false;

  Future<void> _loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // usuário cancelou

      final auth = await account.authentication;

      final accessToken = auth.accessToken;
      
      await getTokenGoogle(accessToken!);

    } catch (e) {
      print('Erro ao logar com Google: $e');
    }
  }

  Future<void> _loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final String accessToken = result.accessToken!.token;
      await getTokenFacebook(accessToken);
      // Aqui você pode enviar o token para sua API
    } else {
      print('Erro no login: ${result.message}');
    }
  }

  Future<void> getTokenGoogle(String accessToken) async {
    final response = await http.post(
      Uri.parse('https://enquete-online-api-production.up.railway.app/api/auth/login/google'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'accessToken': accessToken,
      }),
    );
    final data = jsonDecode(response.body);

    await _storage.write(key: 'accessToken', value: data['accessToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    // Se quiser armazenar o nome do usuário, etc.
    await _storage.write(key: 'userName', value: data['user']['nome']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()), // troque pelo nome da sua tela
    );
  }

  Future<void> getTokenFacebook(String accessToken) async {
    final response = await http.post(
      Uri.parse('https://enquete-online-api-production.up.railway.app/api/auth/login/facebook'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'accessToken': accessToken,
      }),
    );
    print(accessToken);
    final data = jsonDecode(response.body);

    await _storage.write(key: 'accessToken', value: data['accessToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    // Se quiser armazenar o nome do usuário, etc.
    await _storage.write(key: 'userName', value: data['user']['nome']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()), // troque pelo nome da sua tela
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                    label: Text('Entrar com Google'),
                    onPressed: _loginWithGoogle,
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
                    onPressed: _loginWithFacebook,
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
