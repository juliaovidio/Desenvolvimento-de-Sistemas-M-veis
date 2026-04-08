import 'package:app_mobile/src/pages/rotasGerente_page.dart';
import 'package:app_mobile/src/pages/rotasMotorista_page.dart';
import 'package:flutter/material.dart';
import '../../data/repository/auth_repository.dart';

// 👇 IMPORTA AS TELAS

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final auth = AuthRepository();

  bool loading = false;

  // 🔐 LOGIN
  void fazerLogin() async {
    setState(() => loading = true);

    final user = await auth.login(
      emailController.text.trim(),
      senhaController.text.trim(),
    );

    setState(() => loading = false);

    if (user != null) {
      // 👇 REDIRECIONA PELO CARGO
      if (user.cargo == 'gerente') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RotasGerentePage(
              cargo: user.cargo,
              nome: user.nome, 
              autorId: user.id, // 🔥 1. Adicionamos o envio do ID para o Gerente
            ),
          ),
        );
      } else if (user.cargo == 'motorista') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RotasMotoristaPage(
              cargo: user.cargo, 
              nome: user.nome,
              autorId: user.id, // 🔥 2. Adicionamos o envio do ID para o Motorista
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Dados incorretos')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ LOGO
              Image.asset('assets/images/logo.jpeg', height: 100),

              SizedBox(height: 30),

              // 📧 EMAIL
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // 🔒 SENHA
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              // 🔘 BOTÃO LOGIN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : fazerLogin,
                  child: loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}