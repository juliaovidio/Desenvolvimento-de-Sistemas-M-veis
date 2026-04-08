// ignore: file_names
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';

class RelatosPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const RelatosPage({
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
        insetPadding: EdgeInsets.all(10), // Margem das bordas da tela
        child: Stack(
          alignment: Alignment.center,
          children: [
            // InteractiveViewer permite dar zoom na imagem com os dedos!
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            // Botão de fechar (X)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // UI WIDGETS
  // =============================

  Widget cardRelato(Map f) {
    // Formatando a data visualmente
    String dataFormatada = "";
    if (f['criado_em'] != null) {
      DateTime data = DateTime.parse(f['criado_em']);
      dataFormatada = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
    }

    // Pega o nome vindo do Join (ou mostra aviso se não achar)
    String nomeMotorista = f['funcionarios'] != null ? f['funcionarios']['nome'] : 'Motorista Desconhecido';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📷 FOTO COM GESTURE DETECTOR (CLIQUE)
          GestureDetector(
            onTap: () {
              if (f['foto_url'] != null && f['foto_url'].toString().isNotEmpty) {
                mostrarImagem(f['foto_url']);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: f['foto_url'] != null && f['foto_url'].toString().isNotEmpty
                  ? Image.network(
                      f['foto_url'],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[400],
                      child: Center(
                        child: Text(
                          "Sem\nImagem",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 16),
          
          // 📄 DADOS DO RELATO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['titulo'] ?? 'Sem título',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800]),
                ),
                SizedBox(height: 6),
                Text(
                  "Motorista: $nomeMotorista",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  f['descricao'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  dataFormatada,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
      titulo: "Todos os Relatos",
      child: SafeArea(
        child: Column(
          children: [
            // ================= CAMPO DE BUSCA =================
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: buscaCtrl,
                onChanged: filtrarRelatos, // Chama a função sempre que digitar algo
                decoration: InputDecoration(
                  hintText: "Buscar por Motorista ou Data (Ex: 10/02/2025)",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ================= LISTA DE RELATOS =================
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : relatosFiltrados.isEmpty
                      ? Center(child: Text("Nenhum relato encontrado.", style: TextStyle(fontSize: 16)))
                      : ListView.builder(
                          itemCount: relatosFiltrados.length,
                          itemBuilder: (_, i) => cardRelato(relatosFiltrados[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}