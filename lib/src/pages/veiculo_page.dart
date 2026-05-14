import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';

class VeiculosPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const VeiculosPage({
    required this.cargo,
    required this.nome,
    required this.autorId,
  });

  @override
  _VeiculosPageState createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  final supabase = Supabase.instance.client;

  String abaSelecionada = "visualizar";
  String filtroStatus = "todos"; // todos, disponiveis, em_rota

  List veiculos = [];
  List filtrados = [];

  final buscaController = TextEditingController();

  // FORM
  final descricaoController = TextEditingController();
  final placaController = TextEditingController();
  final cargaController = TextEditingController();

  // EDITAR
  final buscaEditarController = TextEditingController();
  List sugestoesEditar = [];
  dynamic veiculoSelecionado;

  // CORES DO DESIGN
  final Color _darkBlue = const Color(0xFF0D2556);
  final Color _bgColor = const Color(0xFFF4F7FC);
  final Color _lightBlue = const Color(0xFFE8F0FE);

  @override
  void initState() {
    super.initState();
    carregarVeiculos();
  }

  @override
  void dispose() {
    buscaController.dispose();
    descricaoController.dispose();
    placaController.dispose();
    cargaController.dispose();
    buscaEditarController.dispose();
    super.dispose();
  }

  // ================== DADOS ==================
  Future<void> carregarVeiculos() async {
    final response = await supabase.from('veiculos').select();

    setState(() {
      veiculos = response;
      aplicarFiltros();
    });
  }

  // ================== FILTROS ==================
  void aplicarFiltros() {
    final texto = buscaController.text.toLowerCase();

    setState(() {
      filtrados = veiculos.where((v) {
        final atendeBusca = v['id'].toString().contains(texto) ||
            (v['placa'] ?? '').toLowerCase().contains(texto) ||
            (v['descricao'] ?? '').toLowerCase().contains(texto);

        // Se no futuro houver status no banco, você adiciona a lógica aqui.
        // Por enquanto filtra apenas visualmente pelos botões superiores.
        bool atendeStatus = true;
        if (filtroStatus == 'disponiveis') {
          atendeStatus = (v['status'] ?? 'disponível').toLowerCase() == 'disponível';
        } else if (filtroStatus == 'em_rota') {
          atendeStatus = (v['status'] ?? '').toLowerCase() == 'em rota';
        }

        return atendeBusca && atendeStatus;
      }).toList();
    });
  }

  void filtrarEditar(String valor) {
    final texto = valor.toLowerCase();

    setState(() {
      if (texto.isEmpty) {
        sugestoesEditar = [];
        return;
      }
      sugestoesEditar = veiculos.where((v) {
        return v['id'].toString().contains(texto) ||
            (v['placa'] ?? '').toLowerCase().contains(texto) ||
            (v['descricao'] ?? '').toLowerCase().contains(texto);
      }).toList();
    });
  }

  // ================== CREATE ==================
  Future<void> criarVeiculo() async {
    if (descricaoController.text.isEmpty || placaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha descrição e placa")),
      );
      return;
    }

    await supabase.from('veiculos').insert({
      'descricao': descricaoController.text,
      'placa': placaController.text,
      'carga_maxima': double.tryParse(cargaController.text) ?? 0,
    });

    descricaoController.clear();
    placaController.clear();
    cargaController.clear();

    await carregarVeiculos();
    setState(() => abaSelecionada = "visualizar");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Veículo adicionado com sucesso")),
    );
  }

  // ================== UPDATE ==================
  Future<void> editarVeiculo() async {
    if (veiculoSelecionado == null) return;

    await supabase
        .from('veiculos')
        .update({
          'descricao': descricaoController.text,
          'placa': placaController.text,
          'carga_maxima': double.tryParse(cargaController.text) ?? 0,
        })
        .eq('id', veiculoSelecionado['id']);

    await carregarVeiculos();

    setState(() {
      veiculoSelecionado = null;
      buscaEditarController.clear();
      descricaoController.clear();
      placaController.clear();
      cargaController.clear();
      abaSelecionada = "visualizar";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Veículo atualizado")),
    );
  }

  // ================== DELETE ==================
  Future<void> deletarVeiculo(int id) async {
    await supabase.from('veiculos').delete().eq('id', id);
    await carregarVeiculos();
    
    // Limpa a seleção se excluiu enquanto editava
    if (veiculoSelecionado != null && veiculoSelecionado['id'] == id) {
      setState(() {
        veiculoSelecionado = null;
        buscaEditarController.clear();
        descricaoController.clear();
        placaController.clear();
        cargaController.clear();
      });
    }
  }

  // ================== UI COMPONENTS ==================
  Widget _buildFiltroChip(String titulo, IconData icone, String valor, Color corIcone) {
    bool ativo = filtroStatus == valor;
    return GestureDetector(
      onTap: () {
        setState(() {
          filtroStatus = valor;
          aplicarFiltros();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ativo ? _darkBlue : Colors.white,
          border: Border.all(color: ativo ? _darkBlue : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icone, size: 16, color: ativo ? Colors.white : corIcone),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                color: ativo ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldCustom(String label, IconData icon, TextEditingController controller, {String hint = "", TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _darkBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardVeiculo(v) {
    // Simulando status baseado na UI que você mandou
    String status = v['status'] ?? 'Disponível';
    bool isDisponivel = status.toLowerCase() == 'disponível';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_shipping, color: _darkBlue),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDisponivel ? Colors.green[100] : _lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isDisponivel ? Colors.green[800] : _darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CÓDIGO", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("V${v['id'].toString().padLeft(3, '0')}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("CARGA MÁXIMA", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("${v['carga_maxima']} kg", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("DESCRIÇÃO", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("${v['descricao']}", style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("PLACAS", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("${v['placa']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ================== MENU INFERIOR ==================
  Widget _buildBottomMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuItem("Visualizar", Icons.remove_red_eye_outlined, "visualizar"),
            _buildMenuItem("Criar", Icons.add_box_outlined, "criar"),
            _buildMenuItem("Editar", Icons.edit_outlined, "editar"),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, IconData icon, String valor) {
    bool ativo = abaSelecionada == valor;
    return GestureDetector(
      onTap: () {
        setState(() {
          abaSelecionada = valor;
          if (valor != 'editar') {
            veiculoSelecionado = null;
            buscaEditarController.clear();
            descricaoController.clear();
            placaController.clear();
            cargaController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? _lightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ativo ? _darkBlue : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: ativo ? _darkBlue : Colors.grey,
                fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId,
      titulo: "Veículos", // Mantém veículos escrito no topo
      paginaAtiva: 'veiculos',
      child: Container(
        color: _bgColor,
        child: Column(
          children: [
            Expanded(
              child: _buildBodyContent(),
            ),
            _buildBottomMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    // ================= VISUALIZAR =================
    if (abaSelecionada == "visualizar") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // CAMPO DE BUSCA
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: buscaController,
                    onChanged: (_) => aplicarFiltros(),
                    decoration: InputDecoration(
                      hintText: "Buscar por placa, descrição ou códig...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // FILTROS
              
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => cardVeiculo(filtrados[i]),
            ),
          )
        ],
      );
    }

    // ================= CRIAR =================
    if (abaSelecionada == "criar") {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldCustom("Descrição", Icons.description_outlined, descricaoController, hint: "Ex: Caminhão Baú Scania R450"),
              _buildTextFieldCustom("Placa", Icons.credit_card, placaController, hint: "ABC-1234"),
              _buildTextFieldCustom("Carga máxima", Icons.shopping_bag_outlined, cargaController, hint: "0.00", type: TextInputType.number),
              
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: criarVeiculo,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    "Adicionar Veículo",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ================= EDITAR =================
    if (abaSelecionada == "editar") {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de busca para edição
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: buscaEditarController,
                onChanged: filtrarEditar,
                decoration: const InputDecoration(
                  hintText: "Buscar veículo para editar...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            if (sugestoesEditar.isNotEmpty && veiculoSelecionado == null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sugestoesEditar.length,
                  itemBuilder: (context, index) {
                    final v = sugestoesEditar[index];
                    return ListTile(
                      leading: Icon(Icons.local_shipping, color: _darkBlue),
                      title: Text(v['descricao'] ?? ''),
                      subtitle: Text(v['placa'] ?? ''),
                      onTap: () {
                        setState(() {
                          veiculoSelecionado = v;
                          descricaoController.text = v['descricao'] ?? '';
                          placaController.text = v['placa'] ?? '';
                          cargaController.text = v['carga_maxima'].toString();
                          sugestoesEditar.clear();
                          buscaEditarController.text = v['descricao'] ?? '';
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // O mesmo formulário visual do Criar
            if (veiculoSelecionado != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Editando Veículo",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkBlue),
                        ),
                        // Botão de excluir integrado no editar
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirmar"),
                                content: const Text("Deseja deletar esse veículo?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deletarVeiculo(veiculoSelecionado['id']);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Deletar", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextFieldCustom("Descrição", Icons.description_outlined, descricaoController),
                    _buildTextFieldCustom("Placa", Icons.credit_card, placaController),
                    _buildTextFieldCustom("Carga máxima", Icons.shopping_bag_outlined, cargaController, type: TextInputType.number),
                    
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: editarVeiculo,
                        icon: const Icon(Icons.save_outlined, color: Colors.white),
                        label: const Text(
                          "Salvar edição",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}