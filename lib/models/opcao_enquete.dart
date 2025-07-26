class OpcaoEnqueteViewModel {
  final String id;
  final String descricao;
  final int quantidadeVotos;
  final double porcentagem;

  OpcaoEnqueteViewModel({
    required this.id,
    required this.descricao,
    required this.quantidadeVotos,
    required this.porcentagem,
  });

  factory OpcaoEnqueteViewModel.fromJson(Map<String, dynamic> json) {
    return OpcaoEnqueteViewModel(
      id: json['id'],
      descricao: json['descricao'],
      quantidadeVotos: json['quantidadeVotos'],
      porcentagem: (json['porcentagem'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'quantidadeVotos': quantidadeVotos,
      'porcentagem': porcentagem,
    };
  }
}