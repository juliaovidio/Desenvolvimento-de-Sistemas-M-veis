import 'package:flutter/material.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/finalizado_page.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/pendente_page.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/vizualizar_falhas_page.dart';
import 'package:app_mobile/src/pages/tab_rotas_motorista/andamento_page.dart';
import '../layout/main_layout.dart';

class RotasMotoristaPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const RotasMotoristaPage({
    Key? key,
    required this.cargo,
    required this.nome,
    required this.autorId,
  }) : super(key: key);

  @override
  State<RotasMotoristaPage> createState() => _RotasMotoristaPageState();
}

class _RotasMotoristaPageState extends State<RotasMotoristaPage> {
  // Variável para controlar a aba selecionada
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 📄 Lista de páginas que serão exibidas com base na seleção
    final List<Widget> pages = [
      PendingTab(
        autorId: widget.autorId,
        cargo: widget.cargo,
        nome: widget.nome,
      ),
      AndamentoTab(
        autorId: widget.autorId,
        cargo: widget.cargo,
        nome: widget.nome,
      ),
      FinalizadoTab(
        autorId: widget.autorId,
        cargo: widget.cargo,
        nome: widget.nome,
      ),
      VisualizarFalhasPage(
        autorId: widget.autorId,
        cargo: widget.cargo,
        nome: widget.nome,
      ),
    ];

    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId,
      titulo: "Minhas Rotas",
      paginaAtiva: 'rotas_motorista',
      child: Column(
        children: [
          // 1️⃣ Área expansível que mostra o conteúdo da página ativa
          Expanded(
            child: pages[_selectedIndex],
          ),
          
          // 2️⃣ Menu inferior estilizado (NavigationBar do Material 3)
          NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.white,
              // Fundo azul clarinho atrás do ícone quando selecionado
              indicatorColor: const Color(0xFFF0F4FA), 
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(
                    color: Color(0xFF13294B), // Azul escuro para o texto ativo
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  );
                }
                return const TextStyle(
                  color: Colors.grey, // Cinza para o texto inativo
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                );
              }),
              iconTheme: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(
                    color: Color(0xFF13294B), // Azul escuro para o ícone ativo
                  );
                }
                return const IconThemeData(
                  color: Colors.grey, // Cinza para o ícone inativo
                );
              }),
            ),
            child: NavigationBar(
              height: 65,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment), // Ícone preenchido
                  label: "Pendente",
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping), // Ícone preenchido
                  label: "Andamento",
                ),
                NavigationDestination(
                  icon: Icon(Icons.check_circle_outline),
                  selectedIcon: Icon(Icons.check_circle), // Ícone preenchido
                  label: "Finalizado",
                ),
                NavigationDestination(
                  icon: Icon(Icons.warning_amber_rounded),
                  selectedIcon: Icon(Icons.warning_rounded), // Ícone preenchido
                  label: "Falhas",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}