// ignore: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';
// Adicione no pubspec.yaml se não tiver, para formatar a data visualmente

class ReportarProblemaPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId; // 🔥 ADICIONADO: Necessário para salvar quem criou o relato no banco

  const ReportarProblemaPage({
    required this.cargo,
    required this.nome,
    required this.autorId, // Passe isso na hora de abrir a tela (Navigator.push)
  });

  @override
  State<ReportarProblemaPage> createState() => _ReportarProblemaPageState();
}

class _ReportarProblemaPageState extends State<ReportarProblemaPage> {
  final supabase = Supabase.instance.client;

  // 🔥 Começa na aba 'adicionar' como você pediu
  String abaSelecionada = "adicionar";

  List relatos = [];
  XFile? imagemSelecionada;

  // Controllers dos campos
  final tituloCtrl = TextEditingController();
  final descricaoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarRelatos();
  }

  // =============================
  // 🔥 BANCO DE DADOS
  // =============================

  Future<void> carregarRelatos() async {
    // Busca os relatos e ordena do mais novo pro mais antigo
    final response = await supabase
        .from('relatos_problema')
        .select()
        .order('criado_em', ascending: false);

    setState(() {
      relatos = response;
    });
  }

  // =============================
  // 📷 CÂMERA
  // =============================

  Future<void> tirarFoto() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permissão de câmera negada")),
      );
      return;
    }

    final picker = ImagePicker();

    final foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (foto != null) {
      setState(() {
        imagemSelecionada = foto;
      });
    }
  }

  // =============================
  // 🔐 SALVAR RELATO
  // =============================

  Future<void> salvarRelato() async {
    if (tituloCtrl.text.isEmpty || descricaoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha título e descrição")),
      );
      return;
    }

    try {
      String? urlImagem;

      // 1. Fazer Upload da imagem (se ele tirou foto)
      if (imagemSelecionada != null) {
        final bytes = await imagemSelecionada!.readAsBytes();
        final fileName = 'relato_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Faz o upload no bucket 'relatos'
        await supabase.storage.from('relatos').uploadBinary(fileName, bytes);

        // Pega a URL pública da foto
        urlImagem = supabase.storage.from('relatos').getPublicUrl(fileName);
      }

      // 2. Salvar no banco de dados
      await supabase.from('relatos_problema').insert({
        'titulo': tituloCtrl.text,
        'descricao': descricaoCtrl.text,
        'foto_url': urlImagem,
        'autor_id': widget.autorId, // Pega o ID passado no construtor
        'criado_em': DateTime.now().toIso8601String(), // Pega data e hora atual
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Relato salvo com sucesso!")),
      );

      // 3. Limpar campos, recarregar a lista e voltar para Visualizar
      limparCampos();
      carregarRelatos();
      setState(() => abaSelecionada = "visualizar");

    } catch (e) {
      print("Erro ao salvar relato: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar o relato")),
      );
    }
  }

  void limparCampos() {
    tituloCtrl.clear();
    descricaoCtrl.clear();
    setState(() {
      imagemSelecionada = null;
    });
  }

  // =============================
  // UI WIDGETS
  // =============================

  Widget aba(String titulo, String valor) {
    final ativo = abaSelecionada == valor;

    return GestureDetector(
      onTap: () {
        setState(() => abaSelecionada = valor);
        if (valor == "adicionar") limparCampos();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
          color: ativo ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: ativo ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget campo(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget cardRelato(Map f) {
    // Formatando a data visualmente (opcional, mas fica melhor na UI)
    String dataFormatada = "";
    if (f['criado_em'] != null) {
      DateTime data = DateTime.parse(f['criado_em']);
      dataFormatada = "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📷 FOTO OU QUADRO CINZA
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: f['foto_url'] != null && f['foto_url'].toString().isNotEmpty
                ? Image.network(
                    f['foto_url'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
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
          SizedBox(width: 12),
          // 📄 DADOS DO RELATO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['titulo'] ?? 'Sem título',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  f['descricao'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  "Data: $dataFormatada",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
      titulo: "Reportar Problema",
      autorId: widget.autorId, // 🔥 CORREÇÃO: Passando o autorId para o MainLayout!
      child: SafeArea(
        child: Column(
          children: [
            // ================= MENU ABAS =================
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  aba("Adicionar", "adicionar"),
                  aba("Visualizar", "visualizar"),
                ],
              ),
            ),

            // ================= VISUALIZAR =================
            if (abaSelecionada == "visualizar")
              Expanded(
                child: relatos.isEmpty
                    ? Center(child: Text("Nenhum relato encontrado."))
                    : ListView.builder(
                        itemCount: relatos.length,
                        itemBuilder: (_, i) => cardRelato(relatos[i]),
                      ),
              ),

            // ================= ADICIONAR =================
            if (abaSelecionada == "adicionar")
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Tirar Foto
                      GestureDetector(
                        onTap: tirarFoto,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imagemSelecionada == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, size: 40),
                                    SizedBox(height: 8),
                                    Text("Tirar Foto")
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(imagemSelecionada!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Campos do Formulário
                      campo("Título do Problema", tituloCtrl),
                      campo("Descrição do Problema", descricaoCtrl, maxLines: 4),
                      
                      SizedBox(height: 20),
                      
                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: salvarRelato,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Salvar Relato",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}