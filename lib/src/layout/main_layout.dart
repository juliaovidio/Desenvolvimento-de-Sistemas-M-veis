import 'package:flutter/material.dart';
import '../widget/menu_button.dart';

// 👇 IMPORT DAS PÁGINAS
import '../pages/rotasGerente_page.dart';
import '../pages/rotasMotorista_page.dart';
import '../pages/motorista_page.dart';
import '../pages/veiculo_page.dart';
import '../pages/relatos_page.dart';
import '../pages/reportarProblema_page.dart';
import '../pages/localizacao_page.dart';

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
  bool aberto = true;

  void navegar(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(widget.titulo), 
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              setState(() {
                aberto = !aberto;
              });
            },
          ),
        ],
      ),

      body: Row(
        children: [
          if (aberto)
            Container(
              width: 250,
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    // 👤 NOME DO USUÁRIO
                    Text(
                      "Seja bem-vindo,",
                      style: TextStyle(fontSize: 14),
                    ),

                    Text(
                      widget.nome, 
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text("Cargo: ${widget.cargo}"),

                    SizedBox(height: 20),

                    // 👨‍💼 GERENTE
                    if (widget.cargo == 'gerente') ...[
                      MenuButton(
                        titulo: "Rotas",
                        onTap: () => navegar(
                          RotasGerentePage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, // 🔥 Corrigido
                          ),
                        ),
                      ),

                      MenuButton(
                        titulo: "Motoristas",
                        onTap: () => navegar(
                          MotoristasPage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, // 🔥 Corrigido
                          ),
                        ),
                      ),

                      MenuButton(
                        titulo: "Veículos",
                        onTap: () => navegar(
                          VeiculosPage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, // 🔥 Corrigido (assumindo que essa tela também pede)
                          ),
                        ),
                      ),

                      MenuButton(
                        titulo: "Relatos",
                        onTap: () => navegar(
                          RelatosPage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, // 🔥 Corrigido
                          ),
                        ),
                      ),
                    ],

                    // 🚛 MOTORISTA
                    if (widget.cargo == 'motorista') ...[
                      MenuButton(
                        titulo: "Minhas Rotas",
                        onTap: () => navegar(
                          RotasMotoristaPage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, // 🔥 Corrigido
                          ),
                        ),
                      ),

                      MenuButton(
                        titulo: "Relatar Problema",
                        onTap: () => navegar(
                          ReportarProblemaPage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, 
                          ),
                        ),
                      ),

                      MenuButton(
                        titulo: "Localização",
                        onTap: () => navegar(
                          LocalizacaoPage(
                            cargo: widget.cargo,
                            nome: widget.nome,
                            autorId: widget.autorId, // 🔥 Corrigido (assumindo que essa tela também pede)
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          Expanded(child: widget.child),
        ],
      ),
    );
  }
}