import 'package:enquete_online_app_mobile/models/opcao_enquete.dart';

class EnqueteViewModel {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime encerramento;
  final List<OpcaoEnqueteViewModel> opcoes;
  final String createdBy;

  EnqueteViewModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.encerramento,
    required this.opcoes,
    required this.createdBy,
  });

  factory EnqueteViewModel.fromJson(Map<String, dynamic> json) {
    return EnqueteViewModel(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      encerramento: DateTime.parse(json['encerramento']),
      opcoes: (json['opcoes'] as List<dynamic>)
          .map((e) => OpcaoEnqueteViewModel.fromJson(e))
          .toList(),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'encerramento': encerramento.toIso8601String(),
      'opcoes': opcoes.map((e) => e.toJson()).toList(),
      'createdBy': createdBy,
    };
  }
}