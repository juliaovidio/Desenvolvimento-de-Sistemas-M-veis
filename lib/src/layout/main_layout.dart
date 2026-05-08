import 'package:app_mobile/src/widget/gemini_chat_fab.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

// IMPORT DAS PÁGINAS
import '../pages/rotasGerente_page.dart';
import '../pages/rotasMotorista_page.dart';
import '../pages/motorista_page.dart';
import '../pages/veiculo_page.dart';
import '../pages/relatos_page.dart';
import '../pages/reportarProblema_page.dart';
import '../pages/localizacao_page.dart';
import '../pages/login_page.dart'; 

class MainLayout extends StatefulWidget {
  final Widget child;
  final String cargo;
  final String nome;   
  final String titulo; 
  final int autorId; 

  const MainLayout({
    required this.child,
    required this.cargo,
    required this.nome,
    required this.titulo,
    required this.autorId, 
  });

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? fotoPerfilUrl; // 📷 Variável para guardar o link da foto do banco

  @override
  void initState() {
    super.initState();
    _buscarFotoPerfil(); // 🔥 Busca a foto assim que o menu abre
  }

  // =============================
  // 📷 BUSCAR FOTO NO BANCO
  // =============================
  Future<void> _buscarFotoPerfil() async {
    try {
      final supabase = Supabase.instance.client;
      // Busca na tabela funcionarios onde o ID for igual ao autorId logado
      final response = await supabase
          .from('funcionarios')
          .select('perfil')
          .eq('id', widget.autorId)
          .maybeSingle();

      if (response != null && response['perfil'] != null) {
        if (mounted) {
          setState(() {
            fotoPerfilUrl = response['perfil']; // Atualiza a tela com a foto
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar foto de perfil: $e");
    }
  }

  void navegar(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // 🎨 Construtor do item de menu
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    // 🔥 Verifica se a página atual é a mesma do botão (ignora maiúsculas e espaços)
    bool isSelected = widget.titulo.trim().toLowerCase() == title.trim().toLowerCase(); 
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent, // Fundo azul se selecionado
        borderRadius: BorderRadius.circular(12),
        // Adiciona uma bordinha sutil pra dar um destaque extra se estiver selecionado
        border: isSelected ? Border.all(color: const Color(0xFF3730A3).withOpacity(0.1)) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isSelected ? const Color(0xFF3730A3) : const Color(0xFF6B7280),
        ),
        title: Text(
          title, 
          style: TextStyle(
            color: isSelected ? const Color(0xFF3730A3) : const Color(0xFF6B7280), 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          )
        ),
        splashColor: const Color(0xFFEEF2FF), // Efeito azul no momento do clique
        hoverColor: const Color(0xFFEEF2FF).withOpacity(0.5),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    String cargoExibicao = widget.cargo.isNotEmpty 
        ? '${widget.cargo[0].toUpperCase()}${widget.cargo.substring(1)}'
        : 'Usuário';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB), 
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 21, 87),
        foregroundColor: const Color.fromARGB(255, 210, 227, 245),
        centerTitle: true, 
        title: Text(widget.titulo),
        elevation: 0,
        // O Drawer adiciona o botão de menu automaticamente aqui
      ),

      // 📲 DRAWER LATERAL (Padrão Mobile)
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧑 ÁREA DO PERFIL
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 10),
                child: Row(
                  children: [
                    // 👇 CÍRCULO COM A FOTO OU ÍCONE
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF00214B),
                      backgroundImage: fotoPerfilUrl != null 
                          ? NetworkImage(fotoPerfilUrl!) 
                          : null,
                      child: fotoPerfilUrl == null
                          ? const Icon(Icons.person, color: Colors.white, size: 28) 
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00214B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            cargoExibicao,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedBox(height: 10),

              // 📋 LISTA DE BOTÕES DO MENU
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // 👨‍💼 MENU GERENTE
                    if (widget.cargo == 'gerente') ...[
                      _buildMenuItem('Rotas', Icons.alt_route, () => navegar(RotasGerentePage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                      _buildMenuItem('Motoristas', Icons.people_outline, () => navegar(MotoristasPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                      _buildMenuItem('Veículos', Icons.local_shipping_outlined, () => navegar(VeiculosPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                      _buildMenuItem('Relatos', Icons.insert_chart_outlined, () => navegar(RelatosPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                      _buildMenuItem('Localização do motorista', Icons.location_on_outlined, () => navegar(LocalizacaoPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                    ],

                    // 🚛 MENU MOTORISTA
                    if (widget.cargo == 'motorista') ...[
                      _buildMenuItem('Minhas Rotas', Icons.alt_route, () => navegar(RotasMotoristaPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                      _buildMenuItem('Relatar Problema', Icons.report_problem_outlined, () => navegar(ReportarProblemaPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                      _buildMenuItem('Localização atual', Icons.my_location, () => navegar(LocalizacaoPage(
                        cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                    ],
                  ],
                ),
              ),

              const Divider(color: Color(0xFFE5E7EB), height: 1),

              // 🚪 BOTÃO SAIR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Color(0xFFDC2626), size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Sair',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // 📄 CORPO DA PÁGINA
      body: widget.child,

      // 🤖 Chat IA Flutuante
      floatingActionButton: const GeminiChatFAB(),
    );
  }
}