import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import '../layout/main_layout.dart';

class MotoristasPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId; // 🔥 1. Adicionamos o ID aqui

  const MotoristasPage({
    required this.cargo, 
    required this.nome,
    required this.autorId, // 🔥 2. Pedimos ele no construtor
  });

  @override
  State<MotoristasPage> createState() => _MotoristasPageState();
}

class _MotoristasPageState extends State<MotoristasPage> {
  final supabase = Supabase.instance.client;

  String abaSelecionada = "visualizar";

  List funcionarios = [];
  List filtrados = [];

  XFile? imagemSelecionada;

  // controllers
  final nomeCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();
  final cargoCtrl = TextEditingController();
  final cnhNumeroCtrl = TextEditingController();
  final cnhCategoriaCtrl = TextEditingController();
  final telefoneCtrl = TextEditingController();
  final cidadeCtrl = TextEditingController();
  final ufCtrl = TextEditingController();
  final bairroCtrl = TextEditingController();
  final cepCtrl = TextEditingController();
  final ruaCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final buscaController = TextEditingController(); 
  final buscaEditarController = TextEditingController();
  List sugestoesEditar = [];

  dynamic funcionarioSelecionado;

  @override
  void initState() {
    super.initState();
    carregarFuncionarios();
  }

  // =============================
  // 🔥 BANCO
  // =============================

  Future<void> carregarFuncionarios() async {
    final response = await supabase.from('funcionarios').select();

    setState(() {
      funcionarios = response;
      filtrados = response;
    });
  }

  void filtrar(String valor) {
    final texto = valor.toLowerCase();

    setState(() {
      filtrados = funcionarios.where((f) {
        return f['id'].toString().contains(texto) ||
            (f['nome'] ?? '').toLowerCase().contains(texto);
      }).toList();
    });
  }

  void filtrarEditar(String valor) {
    final texto = valor.toLowerCase();

    setState(() {
      sugestoesEditar = funcionarios.where((f) {
        return f['id'].toString().contains(texto) ||
            (f['nome'] ?? '').toLowerCase().contains(texto) ||
            (f['cpf'] ?? '').toLowerCase().contains(texto);
      }).toList();
    });
  }
  // =============================
  // 📷 CAMERA
  // =============================

  Future<void> tirarFoto() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Permissão negada")));
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
  // 🔐 SALVAR
  // =============================

  Future<void> salvarFuncionario() async {
    try {
      String? urlImagem;

      // upload imagem
      if (imagemSelecionada != null) {
        final bytes = await imagemSelecionada!.readAsBytes();
        final fileName = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('funcionarios')
            .uploadBinary(fileName, bytes);

        urlImagem = supabase.storage
            .from('funcionarios')
            .getPublicUrl(fileName);
      }

      // 🔐 HASH
      final senhaHash = BCrypt.hashpw(senhaCtrl.text, BCrypt.gensalt());

      await supabase.from('funcionarios').insert({
        'nome': nomeCtrl.text,
        'cpf': cpfCtrl.text,
        'cargo': cargoCtrl.text,
        'cnh_numero': cnhNumeroCtrl.text,
        'cnh_categoria': cnhCategoriaCtrl.text,
        'telefone': telefoneCtrl.text,
        'cidade': cidadeCtrl.text,
        'uf': ufCtrl.text,
        'bairro': bairroCtrl.text,
        'cep': cepCtrl.text,
        'rua': ruaCtrl.text,
        'numero': numeroCtrl.text,
        'email': emailCtrl.text,
        'senha_hash': senhaHash,
        'perfil': urlImagem,
        'ativo': true,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Salvo com sucesso")));

      limparCampos();
      carregarFuncionarios();
      setState(() => abaSelecionada = "visualizar");
    } catch (e) {
      print(e);
    }
  }

  // =============================
  // ✏️ EDITAR
  // =============================

  void selecionarFuncionario(f) {
    setState(() {
      funcionarioSelecionado = f;

      nomeCtrl.text = f['nome'] ?? '';
      cpfCtrl.text = f['cpf'] ?? '';
      cargoCtrl.text = f['cargo'] ?? '';
      cnhNumeroCtrl.text = f['cnh_numero'] ?? '';
      cnhCategoriaCtrl.text = f['cnh_categoria'] ?? '';
      telefoneCtrl.text = f['telefone'] ?? '';
      cidadeCtrl.text = f['cidade'] ?? '';
      ufCtrl.text = f['uf'] ?? '';
      bairroCtrl.text = f['bairro'] ?? '';
      cepCtrl.text = f['cep'] ?? '';
      ruaCtrl.text = f['rua'] ?? '';
      numeroCtrl.text = f['numero'] ?? '';
      emailCtrl.text = f['email'] ?? '';
      imagemSelecionada = null;
      sugestoesEditar.clear();

      abaSelecionada = "editar";
    });
  }

  Future<void> editarFuncionario() async {
    try {
      String? urlImagem = funcionarioSelecionado['perfil'];

      // 📷 se tirou nova foto
      if (imagemSelecionada != null) {
        final bytes = await imagemSelecionada!.readAsBytes();
        final fileName = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('funcionarios')
            .uploadBinary(fileName, bytes);

        urlImagem = supabase.storage
            .from('funcionarios')
            .getPublicUrl(fileName);
      }
      await supabase
          .from('funcionarios')
          .update({
            'nome': nomeCtrl.text,
            'cpf': cpfCtrl.text,
            'cargo': cargoCtrl.text,
            'cnh_numero': cnhNumeroCtrl.text,
            'cnh_categoria': cnhCategoriaCtrl.text,
            'telefone': telefoneCtrl.text,
            'cidade': cidadeCtrl.text,
            'uf': ufCtrl.text,
            'bairro': bairroCtrl.text,
            'cep': cepCtrl.text,
            'rua': ruaCtrl.text,
            'numero': numeroCtrl.text,
            'email': emailCtrl.text,
            'perfil': urlImagem,
          })
          .eq('id', funcionarioSelecionado['id']);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Atualizado")));

      limparCampos();
      carregarFuncionarios();
      setState(() => abaSelecionada = "visualizar");
    } catch (e) {
      print(e);
    }
  }

  void limparCampos() {
    nomeCtrl.clear();
    cpfCtrl.clear();
    emailCtrl.clear();
    senhaCtrl.clear();
    imagemSelecionada = null;
    funcionarioSelecionado = null;
    cargoCtrl.clear();
    cnhNumeroCtrl.clear();
    cnhCategoriaCtrl.clear();
    telefoneCtrl.clear();
    cidadeCtrl.clear();
    ufCtrl.clear();
    bairroCtrl.clear();
    cepCtrl.clear();
    ruaCtrl.clear();
    numeroCtrl.clear();
  }

  // =============================
  // UI
  // =============================

  Widget aba(String titulo, String valor) {
    final ativo = abaSelecionada == valor;

    return GestureDetector(
      onTap: () => setState(() => abaSelecionada = valor),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: ativo ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          titulo,
          style: TextStyle(color: ativo ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget cardFuncionario(f) {
    return GestureDetector(
      onTap: () => selecionarFuncionario(f),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 📷 FOTO
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: f['perfil'] != null
                  ? Image.network(
                      f['perfil'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[400],
                      child: Icon(Icons.person, size: 40),
                    ),
            ),

            SizedBox(width: 12),

            // 📄 DADOS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f['nome'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("ID: ${f['id']}"),
                  Text("Nome: ${f['nome']}"),
                  Text("CPF: ${f['cpf']}"),
                  Text("Cargo: ${f['cargo']}"),
                  Text("CNH: ${f['cnh_numero']}"),
                  Text("Categoria: ${f['cnh_categoria']}"),
                  Text("Telefone: ${f['telefone']}"),
                  Text("Cidade: ${f['cidade']} - ${f['uf']}"),
                  Text("Bairro: ${f['bairro']}"),
                  Text("CEP: ${f['cep']}"),
                  Text("Rua: ${f['rua']}, ${f['numero']}"),
                  Text("Email: ${f['email']}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campo(String label, TextEditingController ctrl) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget fotoWidget() {
    return GestureDetector(
      onTap: tirarFoto,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: imagemSelecionada == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.camera_alt), Text("Foto")],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagemSelecionada!.path),
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId, // 🔥 3. Repassando o ID usando widget.autorId
      titulo: "Funcionários",
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  aba("Visualizar", "visualizar"),
                  aba("Criar", "criar"),
                  aba("Editar", "editar"),
                ],
              ),
            ),

            // ================= VISUALIZAR =================
            if (abaSelecionada == "visualizar") ...[
              Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: buscaController,
                  onChanged: filtrar,
                  decoration: InputDecoration(
                    hintText: "Buscar",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtrados.length,
                  itemBuilder: (_, i) => cardFuncionario(filtrados[i]),
                ),
              ),
            ],

            // ================= CRIAR =================
            if (abaSelecionada == "criar")
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      fotoWidget(),
                      SizedBox(height: 20),
                      campo("Nome", nomeCtrl),
                      campo("CPF", cpfCtrl),
                      campo("Cargo", cargoCtrl),
                      campo("N° CNH", cnhNumeroCtrl),
                      campo("Categoria CNH", cnhCategoriaCtrl),
                      campo("Telefone", telefoneCtrl),

                      campo("Cidade", cidadeCtrl),
                      campo("UF", ufCtrl),
                      campo("Bairro", bairroCtrl),
                      campo("CEP", cepCtrl),
                      campo("Rua", ruaCtrl),
                      campo("Número", numeroCtrl),

                      campo("Email", emailCtrl),
                      campo("Senha", senhaCtrl),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: salvarFuncionario,
                        child: Text("Salvar"),
                      ),
                    ],
                  ),
                ),
              ),

            // ================= EDITAR =================
            if (abaSelecionada == "editar")
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Buscar funcionário"),
                      TextField(
                        controller: buscaEditarController,
                        onChanged: filtrarEditar,
                        decoration: InputDecoration(
                          hintText: "Digite nome ou CPF",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),

                      // 🔍 SUGESTÕES
                      ...sugestoesEditar.map(
                        (f) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: f['perfil'] != null
                                ? NetworkImage(f['perfil'])
                                : null,
                            child: f['perfil'] == null
                                ? Icon(Icons.person)
                                : null,
                          ),
                          title: Text(f['nome'] ?? ''),
                          subtitle: Text(f['cpf'] ?? ''),
                          onTap: () {
                            selecionarFuncionario(f);
                          },
                        ),
                      ),

                      SizedBox(height: 20),

                      // 📷 FOTO
                      GestureDetector(
                        onTap: tirarFoto,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imagemSelecionada != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(imagemSelecionada!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (funcionarioSelecionado != null &&
                                      funcionarioSelecionado['perfil'] != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    funcionarioSelecionado['perfil'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt),
                                    Text("Alterar foto"),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: 20),

                      campo("Nome", nomeCtrl),
                      campo("CPF", cpfCtrl),
                      campo("Cargo", cargoCtrl),
                      campo("N° CNH", cnhNumeroCtrl),
                      campo("Categoria CNH", cnhCategoriaCtrl),
                      campo("Telefone", telefoneCtrl),

                      campo("Cidade", cidadeCtrl),
                      campo("UF", ufCtrl),
                      campo("Bairro", bairroCtrl),
                      campo("CEP", cepCtrl),
                      campo("Rua", ruaCtrl),
                      campo("Número", numeroCtrl),

                      campo("Email", emailCtrl),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: editarFuncionario,
                          child: Text("Salvar edição"),
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