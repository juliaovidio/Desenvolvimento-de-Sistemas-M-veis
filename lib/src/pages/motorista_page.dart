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
  final int autorId;

  const MotoristasPage({
    required this.cargo,
    required this.nome,
    required this.autorId,
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

bool _ocultarSenha = true;
  dynamic funcionarioSelecionado;

  // Cores Base do Design
  final Color primaryBlue = const Color(0xFF00204A);
  final Color textBlue = const Color(0xFF1E40AF);
  final Color backgroundLight = const Color(0xFFF4F6F9);
  final Color sectionTitleColor = const Color(0xFF7D8FB3);

  @override
  void initState() {
    super.initState();
    carregarFuncionarios();
  }

  // =============================
  // 🔥 BANCO (Lógica Mantida)
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
            (f['nome'] ?? '').toLowerCase().contains(texto) ||
            (f['cpf'] ?? '').toLowerCase().contains(texto);
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
  // 📷 CAMERA (Lógica Mantida)
  // =============================

  Future<void> tirarFoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permissão negada")));
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
  // 🔐 SALVAR & EDITAR (Lógica Mantida)
  // =============================

  Future<void> salvarFuncionario() async {
    try {
      String? urlImagem;
      if (imagemSelecionada != null) {
        final bytes = await imagemSelecionada!.readAsBytes();
        final fileName = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('funcionarios').uploadBinary(fileName, bytes);
        urlImagem = supabase.storage.from('funcionarios').getPublicUrl(fileName);
      }

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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvo com sucesso")));
      limparCampos();
      carregarFuncionarios();
      setState(() => abaSelecionada = "visualizar");
    } catch (e) {
      print(e);
    }
  }

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
      senhaCtrl.clear();
      imagemSelecionada = null;
      sugestoesEditar.clear();
      buscaEditarController.clear();
    });
  }

Future<void> editarFuncionario() async {
    try {
      String? urlImagem = funcionarioSelecionado['perfil'];
      if (imagemSelecionada != null) {
        final bytes = await imagemSelecionada!.readAsBytes();
        final fileName = 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('funcionarios').uploadBinary(fileName, bytes);
        urlImagem = supabase.storage.from('funcionarios').getPublicUrl(fileName);
      }

      // 1. Criamos um Map com todos os dados normais
    // 1. Criamos um Map com todos os dados normais
      Map<String, dynamic> dadosAtualizados = {
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
        
        // 🔥 Adicione o .trim() no email aqui!
        'email': emailCtrl.text.trim(), 
        'perfil': urlImagem,
      };

      // 2. Se o utilizador escreveu uma senha nova, fazemos o hash e adicionamos aos dados!
      if (senhaCtrl.text.isNotEmpty) {
        // 🔥 Adicione o .trim() na senha aqui também!
        final senhaHash = BCrypt.hashpw(senhaCtrl.text.trim(), BCrypt.gensalt());
        dadosAtualizados['senha_hash'] = senhaHash;
      }

      // 3. Atualizamos a base de dados
      await supabase
          .from('funcionarios')
          .update(dadosAtualizados)
          .eq('id', funcionarioSelecionado['id']);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Atualizado com sucesso")));
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
    buscaController.clear();
  }

  // =============================
  // UI - COMPONENTES REUTILIZÁVEIS
  // =============================

 Widget buildTextField(String label, TextEditingController ctrl, {bool isPassword = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            // Usa a variável para esconder/mostrar apenas se for campo de senha
            obscureText: isPassword ? _ocultarSenha : false,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00214B)),
              ),
              // Adiciona o botão clicável para alternar a visibilidade
              suffixIcon: isPassword 
                  ? IconButton(
                      icon: Icon(
                        _ocultarSenha ? Icons.visibility_off : Icons.visibility, 
                        color: Colors.grey
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarSenha = !_ocultarSenha;
                        });
                      },
                    ) 
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: sectionTitleColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // =============================
  // UI - TELA DE LISTAGEM (VISUALIZAR)
  // =============================

Widget cardFuncionario(dynamic f) {
    // Verifica se o valor vem do banco como booleano ou como texto
    bool isAtivo = true;
    if (f['ativo'] != null) {
      if (f['ativo'] is bool) {
        isAtivo = f['ativo'];
      } else {
        // Se vier como String "true" ou "false", ele converte corretamente
        isAtivo = f['ativo'].toString().toLowerCase() == 'true';
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topo: Foto, Nome, Cargo, Status e Botão de Excluir
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: f['perfil'] != null
                    ? Image.network(f['perfil'], width: 64, height: 64, fit: BoxFit.cover)
                    : Container(
                        width: 64,
                        height: 64,
                        color: Color(0xFF00214B), // Ajuste para a sua variável primaryBlue se necessário
                        child: const Icon(Icons.person, size: 36, color: Colors.white),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            f['nome'] ?? 'Sem Nome',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAtivo ? const Color(0xFFE0F5E9) : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAtivo ? "ATIVO" : "INATIVO",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isAtivo ? const Color(0xFF1F9B54) : Colors.red),
                          ),
                        ),
                        const SizedBox(width: 8), // Espaço entre o selo e a lixeira
                        
                        // --- BOTÃO DE EXCLUIR INÍCIO ---
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                          tooltip: 'Excluir Funcionário',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Excluir Funcionário'),
                                  content: Text('Tem certeza que deseja excluir o motorista ${f['nome'] ?? 'selecionado'}?'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Apenas fecha o alerta
                                      },
                                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        // TODO: Coloque sua função de deletar do Supabase AQUI
                                        
                                        Navigator.of(context).pop(); // Fecha o alerta
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Funcionário excluído!')),
                                        );
                                      },
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        // --- BOTÃO DE EXCLUIR FIM ---
                        
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (f['cargo'] ?? 'MOTORISTA').toString().toUpperCase(),
                      style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600), // Ajuste a cor textBlue aqui
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          // Documentos
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CPF", style: TextStyle(fontSize: 10, color: Colors.black45)),
                    const SizedBox(height: 4),
                    Text(f['cpf'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CNH / CAT.", style: TextStyle(fontSize: 10, color: Colors.black45)),
                    const SizedBox(height: 4),
                    Text("${f['cnh_numero'] ?? '-'} - Cat. ${f['cnh_categoria'] ?? '-'}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contato
          const Text("CONTATO", style: TextStyle(fontSize: 10, color: Colors.black45)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              Text(f['telefone'] ?? '-', style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              Text(f['email'] ?? '-', style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          // Endereço
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ENDEREÇO COMPLETO", style: TextStyle(fontSize: 10, color: Colors.black45)),
                const SizedBox(height: 8),
                Text("${f['rua'] ?? ''}, ${f['numero'] ?? ''}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("Bairro ${f['bairro'] ?? ''} • CEP ${f['cep'] ?? ''}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("${f['cidade'] ?? ''}, ${f['uf'] ?? ''}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }
  // =============================
  // UI - TELA PRINCIPAL (BUILD)
  // =============================

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId,
      titulo: abaSelecionada == "visualizar" 
          ? "Motoristas" 
          : abaSelecionada == "criar" 
            ? "Adicionar Funcionário" 
            : "Editar Funcionário",
      paginaAtiva: 'motoristas',
      child: Scaffold(
        backgroundColor: backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // CONTEÚDO PRINCIPAL (Telas)
              Expanded(
                child: abaSelecionada == "visualizar"
                    ? _buildAbaVisualizar()
                    : abaSelecionada == "criar"
                        ? _buildAbaCriar()
                        : _buildAbaEditar(),
              ),

              // BOTTOM NAVIGATION BAR CUSTOMIZADA
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem("visualizar", Icons.remove_red_eye_outlined, "VISUALIZAR"),
                    _buildNavItem("criar", Icons.add_circle_outline, "CRIAR"),
                    _buildNavItem("editar", Icons.edit_outlined, "EDITAR"),
                   
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget do Item do Bottom Navigation
  Widget _buildNavItem(String id, IconData icon, String label, {bool disabled = false}) {
    final bool isActive = abaSelecionada == id;
    final Color color = isActive ? textBlue : (disabled ? Colors.grey.shade400 : Colors.grey.shade600);

    return InkWell(
      onTap: disabled
          ? null
          : () {
              setState(() {
                abaSelecionada = id;
                if (id == "criar") limparCampos();
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
  border: isActive 
      ? Border(top: BorderSide(color: textBlue, width: 2)) 
      : const Border(top: BorderSide(color: Colors.transparent, width: 2)),
),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // --- ABA VISUALIZAR ---
  Widget _buildAbaVisualizar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: buscaController,
            onChanged: filtrar,
            decoration: InputDecoration(
              hintText: "Buscar por nome ou CPF...",
              hintStyle: const TextStyle(color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtrados.length,
            itemBuilder: (_, i) => cardFuncionario(filtrados[i]),
          ),
        ),
      ],
    );
  }

  // --- ABA CRIAR ---
  Widget _buildAbaCriar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Profile Box
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: tirarFoto,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB3C6ED), width: 2, style: BorderStyle.solid), // Usando solid pra simplificar sem pacote externo
                    ),
                    child: imagemSelecionada != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(File(imagemSelecionada!.path), fit: BoxFit.cover))
                        : const Center(
                            child: Icon(Icons.camera_alt_outlined, size: 36, color: Color(0xFF1E40AF)),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Adicionar Foto", style: TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          buildSectionTitle("INFORMAÇÕES PESSOAIS"),
          buildTextField("Nome", nomeCtrl, hint: "Nome completo"),
          Row(
            children: [
              Expanded(child: buildTextField("CPF", cpfCtrl, hint: "000.000.000-00")),
              const SizedBox(width: 16),
              Expanded(child: buildTextField("Cargo", cargoCtrl, hint: "Ex: Motorista")), // Adaptado de Dropdown para TextField mantendo sua lógica
            ],
          ),

          buildSectionTitle("DOCUMENTAÇÃO"),
          Row(
            children: [
              Expanded(child: buildTextField("N° CNH", cnhNumeroCtrl, hint: "00000000000")),
              const SizedBox(width: 16),
              Expanded(child: buildTextField("Categoria CNH", cnhCategoriaCtrl, hint: "A, B, C, D, E")),
            ],
          ),

          buildSectionTitle("CONTATO & ENDEREÇO"),
          buildTextField("Telefone", telefoneCtrl, hint: "(00) 00000-0000"),
          Row(
            children: [
              Expanded(child: buildTextField("CEP", cepCtrl, hint: "00000-000")),
              const SizedBox(width: 16),
              Expanded(child: buildTextField("UF", ufCtrl, hint: "SP")),
            ],
          ),
          buildTextField("Cidade", cidadeCtrl, hint: "Ex: São Paulo"),
          Row(
            children: [
              Expanded(flex: 2, child: buildTextField("Rua", ruaCtrl, hint: "Logradouro")),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: buildTextField("Número", numeroCtrl, hint: "000")),
            ],
          ),
          buildTextField("Bairro", bairroCtrl, hint: "Nome do bairro"),

          buildSectionTitle("CREDENCIAIS DE ACESSO"),
          buildTextField("Email", emailCtrl, hint: "usuario@empresa.com"),
          buildTextField("Senha", senhaCtrl, isPassword: true, hint: "********"),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: salvarFuncionario,
              child: const Text("Salvar Funcionário", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- ABA EDITAR ---
  Widget _buildAbaEditar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Busca para Editar
          TextField(
            controller: buscaEditarController,
            onChanged: filtrarEditar,
            decoration: InputDecoration(
              hintText: "Buscar funcionário por nome ou CPF",
              hintStyle: const TextStyle(color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          
          if (sugestoesEditar.isNotEmpty && funcionarioSelecionado == null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: sugestoesEditar.map((f) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: f['perfil'] != null ? NetworkImage(f['perfil']) : null,
                        child: f['perfil'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(f['nome'] ?? ''),
                      subtitle: Text(f['cpf'] ?? ''),
                      onTap: () => selecionarFuncionario(f),
                    )).toList(),
              ),
            ),

          if (funcionarioSelecionado != null) ...[
            const SizedBox(height: 30),
            // Avatar Circular com Badge
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: tirarFoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: imagemSelecionada != null
                              ? FileImage(File(imagemSelecionada!.path))
                              : (funcionarioSelecionado['perfil'] != null ? NetworkImage(funcionarioSelecionado['perfil']) : null) as ImageProvider?,
                          child: (imagemSelecionada == null && funcionarioSelecionado['perfil'] == null)
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF00204A), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("ALTERAR FOTO", style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Campos de Edição (Mesmo layout do Criar)
            buildSectionTitle("INFORMAÇÕES PESSOAIS"),
            buildTextField("Nome completo", nomeCtrl),
            Row(
              children: [
                Expanded(child: buildTextField("CPF", cpfCtrl)),
                const SizedBox(width: 16),
                Expanded(child: buildTextField("Cargo", cargoCtrl)),
              ],
            ),

            buildSectionTitle("DOCUMENTAÇÃO"),
            Row(
              children: [
                Expanded(child: buildTextField("N° CNH", cnhNumeroCtrl)),
                const SizedBox(width: 16),
                Expanded(child: buildTextField("Categoria CNH", cnhCategoriaCtrl)),
              ],
            ),

            buildSectionTitle("CONTATO & ENDEREÇO"),
            buildTextField("Telefone", telefoneCtrl),
            Row(
              children: [
                Expanded(child: buildTextField("CEP", cepCtrl)),
                const SizedBox(width: 16),
                Expanded(child: buildTextField("Cidade", cidadeCtrl)),
              ],
            ),
            Row(
              children: [
                Expanded(flex: 2, child: buildTextField("Rua", ruaCtrl)),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: buildTextField("UF", ufCtrl)),
              ],
            ),
            Row(
              children: [
                Expanded(flex: 1, child: buildTextField("Número", numeroCtrl)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: buildTextField("Bairro", bairroCtrl)),
              ],
            ),

            buildSectionTitle("CREDENCIAIS DE ACESSO"),
            buildTextField("Email", emailCtrl),
            buildTextField("Senha (nova)", senhaCtrl, isPassword: true), 

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: editarFuncionario,
                child: const Text("Salvar Alterações", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ]
        ],
      ),
    );
  }
}