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
  bool _obscurePassword = true; // Variável para controlar a visibilidade da senha

  // 🔐 LOGIN
  void fazerLogin() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    // 🛑 VALIDAÇÃO DO E-MAIL E SENHA
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Por favor, insira um e-mail válido (deve conter @ e .)')),
      );
      return; // Para a execução aqui se o e-mail for inválido
    }

    if (senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ A senha não pode estar vazia')),
      );
      return;
    }

    setState(() => loading = true);

    final user = await auth.login(email, senha);

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
    // Cores baseadas no design fornecido
    const Color primaryColor = Color(0xFF00214B); // Azul escuro
    const Color backgroundColor = Color(0xFFF4F7FB); // Fundo azul bem claro
    const Color greyTextColor = Color(0xFF6B7280); // Cinza para o subtítulo
    const Color borderColor = Color(0xFFE5E7EB); // Cinza claro para bordas

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 60), // Espaçamento superior para compensar a retirada do header

              // 🖼️ LOGO (Tamanho Aumentado)
              Image.asset(
                'assets/images/logo.jpeg', 
                height: 200, // <-- AUMENTEI O TAMANHO AQUI
              ),

              SizedBox(height: 30),

              // 📝 TÍTULO
              Text(
                'Seja\nBem-vindo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 15),

              // 📝 SUBTÍTULO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Acesse sua conta para gerenciar suas\nentregas e rotas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: greyTextColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 35),

              // 🗂️ CARD DO FORMULÁRIO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // 📧 LABEL E-MAIL
                      Text(
                        'E-mail',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // 📧 CAMPO E-MAIL
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'nome@empresa.com.br',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.mail_outline, color: greyTextColor, size: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // 🔒 LABEL SENHA
                      Text(
                        'Senha',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // 🔒 CAMPO SENHA
                      TextField(
                        controller: senhaController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.lock_outline, color: greyTextColor, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: greyTextColor,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),

                      SizedBox(height: 35),

                      // 🔘 BOTÃO LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : fazerLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40), // Espaçamento extra no final da rolagem
            ],
          ),
        ),
      ),
    );
  }
}