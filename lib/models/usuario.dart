class UsuarioViewModel {
  final String id;
  final String nome;
  final String email;
  final String? avatarUrl;

  UsuarioViewModel({
    required this.id,
    required this.nome,
    required this.email,
    this.avatarUrl,
  });

  // Construtor fromJson
  factory UsuarioViewModel.fromJson(Map<String, dynamic> json) {
    return UsuarioViewModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }

  // Método toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }
}