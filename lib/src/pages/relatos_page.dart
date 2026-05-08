// ignore: file_names
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';

class RelatosPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const RelatosPage({
    super.key,
    required this.cargo,
    required this.nome,
    required this.autorId,
  });

  @override
  State<RelatosPage> createState() => _RelatosPageState();
}

class _RelatosPageState extends State<RelatosPage> {
  final supabase = Supabase.instance.client;
  
  List relatosOriginais = []; // Guarda todos os relatos
  List relatosFiltrados = []; // Guarda os relatos após pesquisa
  bool isLoading = true;

  final buscaCtrl = TextEditingController();

  // 🔥 CORES DO DESIGN REFINADO
  final Color primaryDarkBlue = const Color(0xFF04122E); // Azul escuro do ROBÔ/Fundo FAB
  final Color bgColor = const Color(0xFFF5F6FA); // Fundo cinza bem claro
  final Color primaryBlueTitle = const Color(0xFF1447A6); // Azul vibrante para títulos
  final Color placeholderColor = const Color(0xFFE9EDF2); // Cor de fundo da foto vazia

  @override
  void initState() {
    super.initState();
    carregarRelatos();
  }

  // =============================
  // 🔥 BANCO DE DADOS
  // =============================

  Future<void> carregarRelatos() async {
    try {
      // O Supabase vai pegar os relatos e cruzar com a tabela funcionários
      // para trazer o 'nome' de quem tem o autor_id correspondente
      final response = await supabase
          .from('relatos_problema')
          .select('*, funcionarios(nome)')
          .order('criado_em', ascending: false); // Mais novos primeiro

      setState(() {
        relatosOriginais = response;
        relatosFiltrados = response; // Inicialmente, mostra tudo
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar relatos: $e");
      setState(() => isLoading = false);
    }
  }

  // =============================
  // 🔍 SISTEMA DE BUSCA
  // =============================

  void filtrarRelatos(String termo) {
    if (termo.isEmpty) {
      setState(() => relatosFiltrados = relatosOriginais);
      return;
    }

    final termoLimpo = termo.toLowerCase().trim();

    setState(() {
      relatosFiltrados = relatosOriginais.where((relato) {
        // 1. Pega o nome do motorista
        final nomeMotorista = relato['funcionarios'] != null 
            ? relato['funcionarios']['nome'].toString().toLowerCase() 
            : '';

        // 2. Formata a data do relato para o formato DD/MM/YYYY para comparar
        String dataFormatadaBusca = "";
        if (relato['criado_em'] != null) {
          DateTime data = DateTime.parse(relato['criado_em']);
          dataFormatadaBusca = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
        }

        // Verifica se o termo digitado tem no nome OU na data
        return nomeMotorista.contains(termoLimpo) || dataFormatadaBusca.contains(termoLimpo);
      }).toList();
    });
  }

  // =============================
  // 🖼️ EXPANDIR IMAGEM
  // =============================

  void mostrarImagem(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, // Fundo transparente
        insetPadding: const EdgeInsets.all(10), // Margem das bordas da tela
        child: Stack(
          alignment: Alignment.center,
          children: [
            // InteractiveViewer permite dar zoom na imagem com os dedos!
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            // Botão de fechar (X)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // UI WIDGETS (VISUAL FIEL)
  // =============================

  Widget cardRelato(Map f) {
    // Formatando a data visualmente para o rodapé
    String horaMinuto = "";
    String dataFormatada = "";
    if (f['criado_em'] != null) {
      DateTime data = DateTime.parse(f['criado_em']);
      dataFormatada = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
      horaMinuto = "${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
    }

    // Pega o nome vindo do Join (ou mostra aviso se não achar)
    String nomeMotorista = f['funcionarios'] != null ? f['funcionarios']['nome'] : 'Motorista Desconhecido';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), // Sombra bem sutil igual ao design moderno
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📷 FOTO DO RELATO
                GestureDetector(
                  onTap: () {
                    if (f['foto_url'] != null && f['foto_url'].toString().isNotEmpty) {
                      mostrarImagem(f['foto_url']);
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: f['foto_url'] != null && f['foto_url'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            f['foto_url'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              "SEM IMAGEM",
                              style: TextStyle(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 📄 DADOS DO RELATO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        f['titulo'] ?? 'Sem título',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlueTitle),
                      ),
                      const SizedBox(height: 2),
                      // Motorista
                      Text(
                        "Motorista: $nomeMotorista",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      // Descrição
                      Text(
                        f['descricao'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Barra inferior com a data (igual ao padrão da foto de Falhas)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "$dataFormatada  $horaMinuto",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId,
      titulo: "Relatos",
      child: Scaffold(
        backgroundColor: bgColor, // Aplicando a cor de fundo cinza/azul claro
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ================= CAMPO DE BUSCA (REFINADO) =================
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: buscaCtrl,
                        onChanged: filtrarRelatos,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Buscar por Motorista ou Data",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),

                  // ================= LISTA DE RELATOS =================
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : relatosFiltrados.isEmpty
                            ? Center(
                                child: Text("Nenhum relato encontrado.", 
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600)
                                ))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 80),
                                itemCount: relatosFiltrados.length,
                                itemBuilder: (_, i) => cardRelato(relatosFiltrados[i]),
                              ),
                  ),
                ],
              ),
              
              // ================= BOTÃO FAB (Design Fiel) =================
              Positioned(
                bottom: 20,
                right: 20,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    backgroundColor: primaryDarkBlue, // Cor exata do robozinho
                    elevation: 4,
                    highlightElevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      // Ação do Botão
                    },
                    child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}