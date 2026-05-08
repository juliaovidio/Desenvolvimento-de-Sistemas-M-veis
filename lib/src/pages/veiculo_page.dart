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

  // EXCLUIR
  final buscaExcluirController = TextEditingController();
  List filtradosExcluir = [];

  // CORES DO DESIGN
  final Color primaryDark = const Color(0xFF0A1E3F);
  final Color bgColor = const Color(0xFFF6F8FB);
  final Color primaryBlue = const Color(0xFF1351B4);

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
    buscaExcluirController.dispose();
    super.dispose();
  }

  // ================== DADOS ==================
  Future<void> carregarVeiculos() async {
    final response = await supabase.from('veiculos').select();

    setState(() {
      veiculos = response;
      filtrados = response;
      filtradosExcluir = response;
    });
  }

  // ================== FILTROS ==================
  void filtrar(String valor) {
    final texto = valor.toLowerCase();

    setState(() {
      filtrados = veiculos.where((v) {
        return v['id'].toString().contains(texto) ||
            (v['placa'] ?? '').toLowerCase().contains(texto) ||
            (v['descricao'] ?? '').toLowerCase().contains(texto);
      }).toList();
    });
  }

  void filtrarEditar(String valor) {
    final texto = valor.toLowerCase();

    setState(() {
      sugestoesEditar = veiculos.where((v) {
        return v['id'].toString().contains(texto) ||
            (v['placa'] ?? '').toLowerCase().contains(texto) ||
            (v['descricao'] ?? '').toLowerCase().contains(texto);
      }).toList();
    });
  }

  void filtrarExcluir(String valor) {
    final texto = valor.toLowerCase();

    setState(() {
      filtradosExcluir = veiculos.where((v) {
        return v['id'].toString().contains(texto) ||
            (v['placa'] ?? '').toLowerCase().contains(texto) ||
            (v['descricao'] ?? '').toLowerCase().contains(texto);
      }).toList();
    });
  }

  // ================== CREATE ==================
  Future<void> criarVeiculo() async {
    await supabase.from('veiculos').insert({
      'descricao': descricaoController.text,
      'placa': placaController.text,
      'carga_maxima': int.tryParse(cargaController.text) ?? 0,
    });

    descricaoController.clear();
    placaController.clear();
    cargaController.clear();

    await carregarVeiculos();
    
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
          'carga_maxima': int.tryParse(cargaController.text) ?? 0,
        })
        .eq('id', veiculoSelecionado['id']);

    await carregarVeiculos();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Veículo atualizado")),
    );
  }

  // ================== DELETE ==================
  Future<void> deletarVeiculo(int id) async {
    await supabase.from('veiculos').delete().eq('id', id);
    await carregarVeiculos();
  }

  // ================== UI WIDGETS AUXILIARES ==================
  
  Widget _buildTextField({
    required String label, 
    required TextEditingController controller, 
    IconData? icon, 
    String? hint, 
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(color: Colors.black87, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            filled: true,
            fillColor: Colors.white,
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
              borderSide: BorderSide(color: primaryDark),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(String title, {String? subtitle, String? supertitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (supertitle != null)
            Text(
              supertitle.toUpperCase(),
              style: TextStyle(color: primaryBlue, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
            ),
          if (supertitle != null) const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryDark),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ]
        ],
      ),
    );
  }

  Widget abaBottomNav(IconData icon, String titulo, String valor) {
    final ativo = abaSelecionada == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          abaSelecionada = valor;
          if (valor != 'editar') {
             descricaoController.clear();
             placaController.clear();
             cargaController.clear();
             veiculoSelecionado = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFFEAF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ativo ? primaryDark : Colors.grey.shade500),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                color: ativo ? primaryDark : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARD PARA A TELA "VISUALIZAR"
  Widget cardVeiculoVisualizar(v) {
    String codigoFormatado = "V${v['id'].toString().padLeft(3, '0')}";
    bool disponivel = v['id'] % 2 != 0; // Fake status para visual visual (substituir por lógica real caso exista no BD)

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(10)),
                child: Icon(disponivel ? Icons.local_shipping : Icons.moped, color: primaryBlue),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: disponivel ? const Color(0xFFDDF5E6) : const Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  disponivel ? "Disponível" : "Em Rota",
                  style: TextStyle(
                    color: disponivel ? const Color(0xFF1B8A44) : primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CÓDIGO", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
              Text(codigoFormatado, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text("DESCRIÇÃO", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("${v['descricao']}", style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PLACAS", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${v['placa']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CARGA MÁXIMA", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${v['carga_maxima']} kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CARD PARA A TELA "EXCLUIR"
  Widget cardVeiculoExcluir(v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_shipping, color: Colors.grey, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${v['descricao']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("Placa: ${v['placa']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDDF5E6), borderRadius: BorderRadius.circular(6)),
                  child: const Text("DISPONÍVEL", style: TextStyle(color: Color(0xFF1B8A44), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFDE8E8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirmar Exclusão"),
                  content: const Text("Deseja deletar esse veículo da frota permanentemente?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        deletarVeiculo(v['id']);
                        Navigator.pop(context);
                      },
                      child: const Text("Deletar", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
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
      titulo: "",
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // ================= VISUALIZAR =================
                    if (abaSelecionada == "visualizar") 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            
                            TextField(
                              controller: buscaController,
                              onChanged: filtrar,
                              decoration: InputDecoration(
                                hintText: "Buscar por placa, descrição ou código...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Filtros Visuais Estáticos
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Chip(label: const Text("Todos", style: TextStyle(color: Colors.white)), backgroundColor: primaryDark, avatar: const Icon(Icons.local_shipping, color: Colors.white, size: 16)),
                                  const SizedBox(width: 8),
                                  Chip(label: const Text("Disponíveis"), backgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)), avatar: const Icon(Icons.check_circle_outline, size: 16)),
                                  const SizedBox(width: 8),
                                  Chip(label: const Text("Em Rota"), backgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)), avatar: const Icon(Icons.access_time, size: 16)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filtrados.length,
                                padding: const EdgeInsets.only(bottom: 80),
                                itemBuilder: (_, i) => cardVeiculoVisualizar(filtrados[i]),
                              ),
                            )
                          ],
                        ),
                      ),

                    // ================= CRIAR =================
                    if (abaSelecionada == "criar")
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(
                              "",
                          
                             
                            ),
                            // Imagem Placeholder
                            Container(
                              height: 140,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent]),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))
                                ),
                                child: const Text("Novo Registro de Frota", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                children: [
                                  _buildTextField(label: "Descrição", controller: descricaoController, icon: Icons.description_outlined, hint: "Ex: Caminhão Baú Scania R450"),
                                  _buildTextField(label: "Placa", controller: placaController, icon: Icons.credit_card_outlined, hint: "ABC-1234"),
                                  _buildTextField(label: "Carga máxima", controller: cargaController, icon: Icons.shopping_bag_outlined, hint: "0.00", suffixText: "KG", keyboardType: TextInputType.number),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      onPressed: criarVeiculo,
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                                      label: const Text("Adicionar Veículo", style: TextStyle(color: Colors.white, fontSize: 16)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFE6EFFF), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: primaryDark),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text("Os veículos adicionados serão revisados pelo gerente de frota antes da ativação.", style: TextStyle(color: primaryDark))),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                    // ================= EDITAR =================
                    if (abaSelecionada == "editar")
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          
                            TextField(
                              controller: buscaEditarController,
                              onChanged: filtrarEditar,
                              decoration: InputDecoration(
                                hintText: "Buscar veículo",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              ),
                            ),
                            if (sugestoesEditar.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                child: Column(
                                  children: sugestoesEditar.map((v) => ListTile(
                                    leading: const Icon(Icons.local_shipping),
                                    title: Text(v['descricao']),
                                    subtitle: Text(v['placa']),
                                    onTap: () {
                                      setState(() {
                                        veiculoSelecionado = v;
                                        descricaoController.text = v['descricao'];
                                        placaController.text = v['placa'];
                                        cargaController.text = v['carga_maxima'].toString();
                                        sugestoesEditar.clear();
                                      });
                                    },
                                  )).toList(),
                                ),
                              ),
                            
                            const SizedBox(height: 20),
                            // Imagem Placeholder (Mock)
                            Container(
                              height: 160,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(20)),
                                  child: Text(veiculoSelecionado != null ? "Veículo ID: #TM-${veiculoSelecionado['id']}" : "Selecione um veículo", style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                children: [
                                  _buildTextField(label: "Descrição", controller: descricaoController),
                                  _buildTextField(label: "Placa", controller: placaController, icon: null), // Icone na direita no mock (omitido para reusabilidade)
                                  _buildTextField(label: "Carga máxima (kg)", controller: cargaController, keyboardType: TextInputType.number),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      onPressed: editarVeiculo,
                                      icon: const Icon(Icons.save_outlined, color: Colors.white),
                                      label: const Text("Salvar edição", style: TextStyle(color: Colors.white, fontSize: 16)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),

                    // ================= EXCLUIR =================
                    if (abaSelecionada == "excluir")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                          
                            TextField(
                              controller: buscaExcluirController,
                              onChanged: filtrarExcluir,
                              decoration: InputDecoration(
                                hintText: "Buscar para excluir...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filtradosExcluir.length,
                                padding: const EdgeInsets.only(bottom: 80),
                                itemBuilder: (_, i) => cardVeiculoExcluir(filtradosExcluir[i]),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      // FAB "BOT" (Flutuando em todas as abas)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          backgroundColor: primaryDark,
                          onPressed: () {},
                          child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

              // ================= BOTTOM NAVIGATION CUSTOMIZADA =================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      abaBottomNav(Icons.visibility_outlined, "Visualizar", "visualizar"),
                      abaBottomNav(Icons.add_box_outlined, "Criar", "criar"),
                      abaBottomNav(Icons.edit_outlined, "Editar", "editar"),
                      abaBottomNav(Icons.warning_amber_rounded, "Falhas", "excluir"), // Mantive o texto "Falhas" correspondente a imagem, linkado a logica excluir
                    ],
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