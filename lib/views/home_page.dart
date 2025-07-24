import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = const FlutterSecureStorage();

    return Scaffold(
      appBar: AppBar(title: const Text('Bem-vindo')),
      body: FutureBuilder<String?>(
        future: storage.read(key: 'userName'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final nome = snapshot.data ?? 'Usuário desconhecido';
          return Center(
            child: Text(
              'Olá, $nome!',
              style: const TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }
}
