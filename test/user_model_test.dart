import 'package:app_mobile/data/model/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TC09 - UserModel.fromJson mapeia id e cargo', () {
    final user = UserModel.fromJson({
      'id': 10,
      'email': 'teste@empresa.com',
      'senha_hash': '123',
      'cargo': 'motorista',
      'nome': 'Carlos',
    });

    expect(user.id, 10);
    expect(user.cargo, 'motorista');
    expect(user.nome, 'Carlos');
  });

  test('TC10 - UserModel.fromJson mapeia senha_hash', () {
    final user = UserModel.fromJson({
      'id': 11,
      'email': 'teste@empresa.com',
      'senha_hash': 'abc123',
      'cargo': 'gerente',
      'nome': 'Ana',
    });

    expect(user.senhaHash, 'abc123');
  });
}