import 'dart:convert';
import 'package:enquete_online_app_mobile/models/enquete.dart';
import 'package:enquete_online_app_mobile/models/usuario.dart';
import 'package:enquete_online_app_mobile/services/enquete_service.dart';
import 'package:enquete_online_app_mobile/views/login_page.dart';
import 'package:enquete_online_app_mobile/views/votacao_page.dart';
import 'package:enquete_online_app_mobile/widgets/card_enquete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  final EnqueteService enqueteService = EnqueteService();
  final ScrollController _scrollController = ScrollController();

  UsuarioViewModel? _usuario;
  List<EnqueteViewModel> _enquetes = [];

  int _page = 1;
  int _pageSize = 6;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
    _loadEnquetes();

    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        _loadEnquetes();
      }
    });
  }

  void _loadUsuario() async {
    final jsonStr = await storage.read(key: 'user');
    if (jsonStr != null) {
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      setState(() {
        _usuario = UsuarioViewModel.fromJson(json);
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _loadEnquetes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final paginated = await enqueteService.getEnquetes(_page, _pageSize);
      setState(() {
        _enquetes.addAll(paginated.data);
        _page++;
        _hasMore = paginated.data.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Erro ao carregar enquetes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reloadEnquetes() async {
    setState(() {
      _page = 1;
      _hasMore = true;
      _enquetes.clear();
    });
    await _loadEnquetes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue,)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: _usuario!.avatarUrl != null
                  ? NetworkImage(_usuario!.avatarUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            const Text('e-Enquetes'),
            InkWell(
              onTap: _logout,
              child: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 15),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF0F2F5),
        child: _enquetes.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
            : RefreshIndicator(
                color: Colors.blue,
                onRefresh: _reloadEnquetes,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _enquetes.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _enquetes.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Colors.blue),
                      ));
                    }

                    final enquete = _enquetes[index];
                    return InkWell(
                      child: EnqueteCard(enquete: enquete),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VotacaoPage(enqueteId: enquete.id),
                          ),
                        );
                        await _reloadEnquetes(); // Atualiza após votar
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

