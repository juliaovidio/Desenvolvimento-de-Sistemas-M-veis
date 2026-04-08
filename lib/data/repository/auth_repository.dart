import '../../core/service/api_service.dart';
import '../model/user_model.dart';


class AuthRepository {
  final api = ApiService();

  Future<UserModel?> login(String email, String senha) async {
    try {
      final response = await api.supabase
          .from('funcionarios')
          .select()
          .eq('email', email)
          .maybeSingle(); // 👈 evita erro se não existir

      // ❌ Email não encontrado
      if (response == null) {
        return null;
      }

      final user = UserModel.fromJson(response);

      // ❌ Senha incorreta
      if (senha != user.senhaHash) {
        return null;
      }

      // ✅ Login OK
      return user;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }
}