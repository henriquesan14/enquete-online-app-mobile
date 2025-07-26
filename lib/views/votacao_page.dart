import 'package:enquete_online_app_mobile/models/enquete.dart';
import 'package:enquete_online_app_mobile/services/enquete_service.dart';
import 'package:enquete_online_app_mobile/services/enquete_signalr_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VotacaoPage extends StatefulWidget {
  final String enqueteId;

  const VotacaoPage({super.key, required this.enqueteId});

  @override
  State<VotacaoPage> createState() => _VotacaoPageState();
}

class _VotacaoPageState extends State<VotacaoPage> {
  String? opcaoSelecionadaId;
  bool mostrarResultado = false;
  EnqueteService enqueteService = EnqueteService();
  final EnqueteSignalRService signalRService = EnqueteSignalRService();

  EnqueteViewModel? enquete;

  @override
  void initState() {
    super.initState();

    getEnquete();

    signalRService.startConnection(widget.enqueteId);

    signalRService.resultadoStream.listen((resultadoAtualizado) {
      print('rweteste websocket');
      getEnquete();
      setState(() {
        mostrarResultado = true;
      });
    });
  }

  getEnquete() async {
    var result = await enqueteService.getEnqueteById(widget.enqueteId);
    setState(() {
      enquete = result;
    });
  }

  @override
  void dispose() {
    signalRService.stopConnection(widget.enqueteId);
    signalRService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (enquete == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(enquete!.titulo),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFFF0F2F5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!mostrarResultado) ...[
                ...enquete!.opcoes.map((opcao) {
                  return RadioListTile<String>(
                    title: Text(opcao.descricao),
                    activeColor: const Color(0xFF1877F2),
                    value: opcao.id,
                    groupValue: opcaoSelecionadaId,
                    onChanged: (value) {
                      setState(() {
                        opcaoSelecionadaId = value;
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.check, color: Colors.white),
                  label: const Text('Votar'),
                  onPressed: opcaoSelecionadaId == null
                      ? null
                      : () => _votar(enquete!.id, opcaoSelecionadaId!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.squarePollHorizontal,
                      color: Color(0xFF1877F2)),
                  label: const Text('Ver resultado'),
                  onPressed: () {
                    setState(() {
                      mostrarResultado = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1877F2),
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
              ] else ...[
                // Modo resultado
                ...enquete!.opcoes.map((opcao) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opcao.descricao),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (opcao.porcentagem / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFF1877F2),
                            minHeight: 10,
                          ),
                        ),
                        Text('${opcao.quantidadeVotos} votos (${opcao.porcentagem}%)'),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.arrowRotateLeft,
                      color: Colors.white),
                  label: const Text('Votar novamente'),
                  onPressed: () {
                    setState(() {
                      mostrarResultado = false;
                      opcaoSelecionadaId = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _votar(String enqueteId, String opcaoEnqueteId) async {
    await enqueteService.addVoto(enqueteId, opcaoEnqueteId);

    getEnquete();
    setState(() {
      mostrarResultado = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voto registrado!")),
    );
  }
}
