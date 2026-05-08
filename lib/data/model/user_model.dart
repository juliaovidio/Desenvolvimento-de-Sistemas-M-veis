class UserModel {
  final int id; // 🔥 ADICIONAMOS O ID AQUI
  final String email;
  final String senhaHash;
  final String cargo;
  final String nome;

  UserModel({
    required this.id, // 🔥 AQUI TAMBÉM
    required this.email,
    required this.senhaHash,
    required this.cargo,
    required this.nome,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'], // 🔥 E AQUI (puxando da coluna 'id' do banco)
      email: json['email'],
      senhaHash: json['senha_hash'],
      cargo: json['cargo'],
      nome: json['nome'],
    );
  }
}