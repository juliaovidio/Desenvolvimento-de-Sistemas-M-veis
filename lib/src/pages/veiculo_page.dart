import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layout/main_layout.dart';

class VeiculosPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId; // 🔥 1. Adicionamos o ID aqui

  const VeiculosPage({
    required this.cargo,
    required this.nome,
    required this.autorId, // 🔥 2. Pedimos no construtor
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
      SnackBar(content: Text("✅ Veículo atualizado")),
    );
  }

  // ================== DELETE ==================
  Future<void> deletarVeiculo(int id) async {
    await supabase.from('veiculos').delete().eq('id', id);
    await carregarVeiculos();
  }

  // ================== UI ==================
  Widget aba(String titulo, String valor) {
    final ativo = abaSelecionada == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          abaSelecionada = valor;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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

  Widget cardVeiculo(v, {bool mostrarDelete = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("CÓDIGO: ${v['id']}"),
          Text("DESCRIÇÃO: ${v['descricao']}"),
          Text("PLACA: ${v['placa']}"),
          Text("CARGA MÁXIMA: ${v['carga_maxima']}"),

          if (mostrarDelete)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Confirmar"),
                      content: Text("Deseja deletar esse veículo?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            deletarVeiculo(v['id']);
                            Navigator.pop(context);
                          },
                          child: Text("Deletar"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      autorId: widget.autorId, // 🔥 3. Passamos o ID para o MainLayout
      titulo: "Veículos",
      child: SafeArea(
        child: Column(
          children: [
            // ABAS
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  aba("Visualizar", "visualizar"),
                  aba("Criar", "criar"),
                  aba("Editar", "editar"),
                  aba("Excluir", "excluir"),
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
                    hintText: "Buscar...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filtrados.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (_, i) => cardVeiculo(filtrados[i]),
                ),
              )
            ],

            // ================= CRIAR =================
            if (abaSelecionada == "criar")
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: descricaoController,
                        decoration: InputDecoration(labelText: "Descrição"),
                      ),
                      TextField(
                        controller: placaController,
                        decoration: InputDecoration(labelText: "Placa"),
                      ),
                      TextField(
                        controller: cargaController,
                        decoration:
                            InputDecoration(labelText: "Carga máxima"),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: criarVeiculo,
                        child: Text("Adicionar Veículo"),
                      )
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
                      Text("Buscar veículo"),
                      TextField(
                        controller: buscaEditarController,
                        onChanged: filtrarEditar,
                      ),

                      // LISTA DE SUGESTÕES
                      ...sugestoesEditar.map((v) => ListTile(
                            title: Text(v['descricao']),
                            subtitle: Text(v['placa']),
                            onTap: () {
                              setState(() {
                                veiculoSelecionado = v;
                                descricaoController.text = v['descricao'];
                                placaController.text = v['placa'];
                                cargaController.text =
                                    v['carga_maxima'].toString();
                                sugestoesEditar.clear();
                              });
                            },
                          )),

                      SizedBox(height: 20),

                      TextField(
                        controller: descricaoController,
                        decoration: InputDecoration(labelText: "Descrição"),
                      ),
                      TextField(
                        controller: placaController,
                        decoration: InputDecoration(labelText: "Placa"),
                      ),
                      TextField(
                        controller: cargaController,
                        decoration:
                            InputDecoration(labelText: "Carga máxima"),
                      ),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: editarVeiculo,
                          child: Text("Salvar edição"),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            // ================= EXCLUIR =================
            if (abaSelecionada == "excluir")
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: TextField(
                        controller: buscaExcluirController,
                        onChanged: filtrarExcluir,
                        decoration: InputDecoration(
                          hintText: "Buscar para excluir...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtradosExcluir.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10),
                        itemBuilder: (_, i) => cardVeiculo(
                          filtradosExcluir[i],
                          mostrarDelete: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}