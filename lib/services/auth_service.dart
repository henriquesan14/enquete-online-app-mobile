import 'dart:convert';
import 'package:enquete_online_app_mobile/services/api_client.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  AuthService();

  final _storage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<bool> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final accessToken = auth.accessToken;

      return await _sendToken(accessToken!, 'google');
    } catch (e) {
      print('Erro ao logar com Google: $e');
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        return await _sendToken(accessToken, 'facebook');
      } else {
        print('Erro no login Facebook: ${result.message}');
        return false;
      }
    } catch (e) {
      print('Erro Facebook: $e');
      return false;
    }
  }

  Future<bool> _sendToken(String token, String provider) async {
    final url = 'auth/login/$provider';

    final response = await _apiClient.post(url, body: {'accessToken': token});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'accessToken', value: data['accessToken']);
      await _storage.write(key: 'refreshToken', value: data['refreshToken']);
      await _storage.write(key: 'user', value: jsonEncode(data['user']));
      return true;
    } else {
      print('Erro no backend: ${response.body}');
      return false;
    }
  }

  Future<bool> logout() async {
    final url = 'auth/logout';

    var refreshToken = await _storage.read(key: 'refreshToken');
    final response = await _apiClient.post(
      url,
      body: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200) {
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      await _storage.delete(key: 'user');
      return true;
    } else {
      print('Erro no backend: ${response.body}');
      return false;
    }
  }
}
