import 'package:app_mobile/src/widget/gemini_chat_fab.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 👇 IMPORT DAS PÁGINAS
import '../pages/rotasGerente_page.dart';
import '../pages/rotasMotorista_page.dart';
import '../pages/motorista_page.dart';
import '../pages/veiculo_page.dart';
import '../pages/relatos_page.dart';
import '../pages/reportarProblema_page.dart';
import '../pages/localizacao_page.dart';
import '../pages/motoristas_localizacao_page.dart';
import '../pages/login_page.dart'; 

class MainLayout extends StatefulWidget {
  final Widget child;
  final String cargo;
  final String nome;   
  final String titulo; 
  final int autorId;
  final String? paginaAtiva;

  const MainLayout({
    required this.child,
    required this.cargo,
    required this.nome,
    required this.titulo,
    required this.autorId,
    this.paginaAtiva,
  });

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // ✅ DICA: Mudei para false para o app já abrir com o menu fechado!
  bool aberto = false; 
  String? fotoPerfilUrl;

  @override
  void initState() {
    super.initState();
    _buscarFotoPerfil();
  }

  Future<void> _buscarFotoPerfil() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('funcionarios')
          .select('perfil')
          .eq('id', widget.autorId)
          .maybeSingle();

      if (response != null && response['perfil'] != null) {
        if (mounted) {
          setState(() {
            fotoPerfilUrl = response['perfil'];
          });
        }
      }
    } catch (e) {
      // Erro ignorado
    }
  }

  void navegar(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildMenuItem(String title, String pageId, IconData icon, VoidCallback onTap) {
    bool isSelected = widget.paginaAtiva == pageId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
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
        splashColor: const Color(0xFFEEF2FF),
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
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              aberto = !aberto;
            });
          },
        ),
      ),

      // ✅ SOLUÇÃO AQUI: Trocamos o 'Row' por 'Stack' (Pilha)
      body: Stack(
        children: [
          // 1. O CONTEÚDO PRINCIPAL: Fica sempre no fundo, ocupando 100% da largura.
          Positioned.fill(
            child: widget.child,
          ),

          // 2. FUNDO ESCURO: Fica no meio. Se clicar nele, o menu fecha.
          if (aberto)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    aberto = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.4), // Dá um destaque lindo pro menu
                ),
              ),
            ),

          // 3. A SIDEBAR (MENU): Fica na frente de tudo, flutuando à esquerda.
          if (aberto)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 30, bottom: 20, right: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00214B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  cargoExibicao,
                                  style: const TextStyle(
                                    fontSize: 13,
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

                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // 👨‍💼 MENU GERENTE
                          if (widget.cargo == 'gerente') ...[
                            _buildMenuItem('Rotas', 'rotas_gerente', Icons.alt_route, () => navegar(RotasGerentePage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                            _buildMenuItem('Motoristas', 'motoristas', Icons.people_outline, () => navegar(MotoristasPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                            _buildMenuItem('Veículos', 'veiculos', Icons.local_shipping_outlined, () => navegar(VeiculosPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                            _buildMenuItem('Relatos', 'relatos', Icons.insert_chart_outlined, () => navegar(RelatosPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                            _buildMenuItem('Localização de motoristas', 'localizacao_motorista', Icons.location_on_outlined, () => navegar(MotoristasLocalizacaoPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                          ],

                          // 🚛 MENU MOTORISTA
                          if (widget.cargo == 'motorista') ...[
                            _buildMenuItem('Minhas Rotas', 'rotas_motorista', Icons.alt_route, () => navegar(RotasMotoristaPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                            _buildMenuItem('Relatar Problema', 'relatar_problema', Icons.report_problem_outlined, () => navegar(ReportarProblemaPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                            _buildMenuItem('Localização atual', 'localizacao_atual', Icons.my_location, () => navegar(LocalizacaoPage(
                              cargo: widget.cargo, nome: widget.nome, autorId: widget.autorId))),
                          ],
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) =>  LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: const [
                            Icon(Icons.logout, color: Color(0xFFDC2626), size: 22),
                            SizedBox(width: 12),
                            Text(
                              'Sair',
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: const GeminiChatFAB(),
    );
  }
}