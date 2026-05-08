import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// ---------------------------------------------------------
// Classe para gerenciar os controladores de cada parada
// ---------------------------------------------------------
class ParadaModel {
  TextEditingController ordem = TextEditingController(); 
  TextEditingController cidade = TextEditingController();
  TextEditingController uf = TextEditingController();
  TextEditingController bairro = TextEditingController();
  TextEditingController cep = TextEditingController();
  TextEditingController rua = TextEditingController();
  TextEditingController numero = TextEditingController();
  TextEditingController empresa = TextEditingController();
  TextEditingController responsavel = TextEditingController();
  TextEditingController cpfCnpj = TextEditingController();
  TextEditingController telefone = TextEditingController();
  TextEditingController infoCarga = TextEditingController();
  TextEditingController valorPorParada = TextEditingController(); 

  void dispose() {
    ordem.dispose();
    cidade.dispose();
    uf.dispose();
    bairro.dispose();
    cep.dispose();
    rua.dispose();
    numero.dispose();
    empresa.dispose();
    responsavel.dispose();
    cpfCnpj.dispose();
    telefone.dispose();
    infoCarga.dispose();
    valorPorParada.dispose();
  }
}

// ---------------------------------------------------------
// WIDGET PRINCIPAL
// ---------------------------------------------------------
class CriarRotaTab extends StatefulWidget {
  @override
  _CriarRotaTabState createState() => _CriarRotaTabState();
}

class _CriarRotaTabState extends State<CriarRotaTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Controladores da Rota
  final descricaoController = TextEditingController();
  final tempoController = TextEditingController();
  final totalKmController = TextEditingController();
  final valorMotoristaController = TextEditingController();
  final valorCaminhaoController = TextEditingController();
  final valorCobrarController = TextEditingController();
  final cargaTotalController = TextEditingController();

  // Controladores de Busca
  final motoristaSearchController = TextEditingController();
  final veiculoSearchController = TextEditingController();
  
  // IDs selecionados para salvar no banco
  int? motoristaSelecionadoId;
  int? veiculoSelecionadoId;

  // Lista dinâmica de paradas (começa com 1)
  List<ParadaModel> listaParadas = [ParadaModel()];

  @override
  void dispose() {
    descricaoController.dispose();
    tempoController.dispose();
    totalKmController.dispose();
    valorMotoristaController.dispose();
    valorCaminhaoController.dispose();
    valorCobrarController.dispose();
    cargaTotalController.dispose();
    motoristaSearchController.dispose();
    veiculoSearchController.dispose();
    for (var parada in listaParadas) {
      parada.dispose();
    }
    super.dispose();
  }

  // ==========================================
  // BUSCA DE MOTORISTAS E VEÍCULOS
  // ==========================================
  Future<List<Map<String, dynamic>>> buscarMotoristasLivres(String query) async {
    final rotasOcupadas = await supabase
        .from('rotas')
        .select('motorista_id')
        .inFilter('status', ['em andamento', 'a realizar']);

    List<int> motoristasOcupadosIds = rotasOcupadas
        .map<int>((rota) => rota['motorista_id'] as int)
        .toList();

    var queryBuilder = supabase
        .from('funcionarios')
        .select('id, nome')
        .ilike('cargo', '%motorista%')
        .ilike('nome', '%$query%');

    final response = await queryBuilder;
    return response.where((m) => !motoristasOcupadosIds.contains(m['id'])).toList();
  }

  Future<List<Map<String, dynamic>>> buscarVeiculosLivres(String query) async {
    final rotasOcupadas = await supabase
        .from('rotas')
        .select('veiculo_id')
        .inFilter('status', ['em andamento', 'a realizar']);

    List<int> veiculosOcupadosIds = rotasOcupadas
        .map<int>((rota) => rota['veiculo_id'] as int)
        .toList();

    var queryBuilder = supabase
        .from('veiculos')
        .select('id, descricao, placa')
        .ilike('descricao', '%$query%');

    final response = await queryBuilder;
    return response.where((v) => !veiculosOcupadosIds.contains(v['id'])).toList();
  }

  // ==========================================
  // SALVAR TUDO NO SUPABASE
  // ==========================================
  Future<void> salvarRotaEParadas() async {
    if (motoristaSelecionadoId == null || veiculoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um motorista e um veículo!'), backgroundColor: Colors.red),
      );
      return;
    }

    for (var p in listaParadas) {
      if (p.cidade.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha a cidade em todas as paradas!'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final rotaResponse = await supabase.from('rotas').insert({
        'descricao': descricaoController.text,
        'motorista_id': motoristaSelecionadoId,
        'veiculo_id': veiculoSelecionadoId,
        'tempo_estimado': tempoController.text,
        'total_km': double.tryParse(totalKmController.text) ?? 0.0,
        'valor_pagar_motorista': double.tryParse(valorMotoristaController.text) ?? 0.0,
        'valor_gasto_caminhao': double.tryParse(valorCaminhaoController.text) ?? 0.0,
        'valor_cobrar_entrega': double.tryParse(valorCobrarController.text) ?? 0.0,
        'carga_total': cargaTotalController.text,
        'status': 'a realizar',
        'criada_em': DateTime.now().toIso8601String(),
      }).select('id').single();

      final int rotaId = rotaResponse['id'];

      List<Map<String, dynamic>> paradasParaInserir = [];
      for (int i = 0; i < listaParadas.length; i++) {
        final p = listaParadas[i];
        
        int ordemManual = int.tryParse(p.ordem.text) ?? (i + 1);
        double valorParada = double.tryParse(p.valorPorParada.text) ?? 0.0;

        paradasParaInserir.add({
          'rota_id': rotaId,
          'ordem': ordemManual,
          'cidade': p.cidade.text,
          'uf': p.uf.text,
          'bairro': p.bairro.text,
          'cep': p.cep.text,
          'rua': p.rua.text,
          'numero': p.numero.text,
          'empresa_loja': p.empresa.text,
          'responsavel': p.responsavel.text,
          'cpf_cnpj': p.cpfCnpj.text,
          'telefone_empresa': p.telefone.text,
          'info_carga': p.infoCarga.text,
          'valor_por_parada': valorParada, 
          'status': 'pendente',
        });
      }

      await supabase.from('paradas').insert(paradasParaInserir);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Rota criada com sucesso!'), backgroundColor: Colors.green),
      );
      
      descricaoController.clear();
      motoristaSearchController.clear();
      veiculoSearchController.clear();
      tempoController.clear();
      totalKmController.clear();
      valorMotoristaController.clear();
      valorCaminhaoController.clear();
      valorCobrarController.clear();
      cargaTotalController.clear();
      motoristaSelecionadoId = null;
      veiculoSelecionadoId = null;
      
      setState(() {
        listaParadas = [ParadaModel()];
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // INTERFACE DE USUÁRIO (UI)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fundo mais moderno
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dados Principais da Rota",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F265C)),
            ),
            const SizedBox(height: 16),

            _buildTextField("Descrição da Rota", descricaoController, hint: "Ex: Entregas centro SP..."),
            
            const Text("Motorista", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: motoristaSearchController,
                  focusNode: focusNode,
                  decoration: _inputDeco("Buscar motorista disponível..."),
                );
              },
              suggestionsCallback: (pattern) async => await buscarMotoristasLivres(pattern),
              itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion['nome'])),
              onSelected: (suggestion) {
                motoristaSearchController.text = suggestion['nome'];
                motoristaSelecionadoId = suggestion['id'];
              },
            ),
            const SizedBox(height: 16),

            const Text("Veículo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: veiculoSearchController,
                  focusNode: focusNode,
                  decoration: _inputDeco("Buscar veículo disponível..."),
                );
              },
              suggestionsCallback: (pattern) async => await buscarVeiculosLivres(pattern),
              itemBuilder: (context, suggestion) => ListTile(title: Text("${suggestion['descricao']} - ${suggestion['placa']}")),
              onSelected: (suggestion) {
                veiculoSearchController.text = suggestion['descricao'];
                veiculoSelecionadoId = suggestion['id'];
              },
            ),
            
            const SizedBox(height: 32),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Roteiro de Paradas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F265C))),
                TextButton.icon(
                  onPressed: () => setState(() => listaParadas.add(ParadaModel())),
                  icon: const Icon(Icons.add_circle, color: Color(0xFF00214B)),
                  label: const Text("Nova Parada", style: TextStyle(color: Color(0xFF00214B), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaParadas.length,
              itemBuilder: (context, index) {
                final parada = listaParadas[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                            child: Text("Parada ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00214B))),
                          ),
                          if (listaParadas.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => setState(() => listaParadas.removeAt(index)),
                              tooltip: "Remover Parada",
                            )
                        ],
                      ),
                      const SizedBox(height: 20),

                      _buildTextField("Ordem", parada.ordem, isNumber: true, hint: "Ex: 1"),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: Color(0xFF00214B)),
                            const SizedBox(width: 4),
                            Text(
                              "Pergunte para a IA a melhor ordem",
                              style: TextStyle(fontSize: 12, color: Color(0xFF00214B), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildTextField("Valor por parada", parada.valorPorParada, isNumber: true, hint: "R\$ 0.00"),
                      
                      Row(
                        children: [
                          Expanded(flex: 3, child: _buildTextField("Cidade", parada.cidade)),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: _buildTextField("UF", parada.uf, hint: "SP")),
                        ],
                      ),
                      _buildTextField("Bairro", parada.bairro),
                      _buildTextField("CEP", parada.cep),
                      Row(
                        children: [
                          Expanded(flex: 3, child: _buildTextField("Rua", parada.rua)),
                          const SizedBox(width: 12),
                          Expanded(flex: 1, child: _buildTextField("Nº", parada.numero)),
                        ],
                      ),
                      _buildTextField("Empresa/Loja", parada.empresa),
                      _buildTextField("Responsável", parada.responsavel),
                      _buildTextField("CPF/CNPJ", parada.cpfCnpj),
                      _buildTextField("Telefone", parada.telefone),
                      _buildTextField("Informação da Carga", parada.infoCarga, maxLines: 2),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.black12),
            const SizedBox(height: 20),

            const Text("Valores e Resumo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F265C))),
            const SizedBox(height: 16),

            _buildTextField("Quantidade total da carga", cargaTotalController, hint: "Ex: 1500 kg"),
            _buildTextField("Tempo estimado", tempoController, hint: "Ex: 4 horas"),
            _buildTextField("Total (km)", totalKmController, isNumber: true),
            _buildTextField("Valor a pagar ao motorista", valorMotoristaController, isNumber: true, hint: "R\$"),
            _buildTextField("Valor gasto com o caminhão", valorCaminhaoController, isNumber: true, hint: "R\$"),
            _buildTextField("Valor a cobrar da entrega", valorCobrarController, isNumber: true, hint: "R\$"),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00214B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    onPressed: salvarRotaEParadas,
                    child: const Text("Salvar e Enviar Rota", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // COMPONENTE: INPUT PADRÃO MODERNIZADO
  // ==========================================
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, String hint = "", int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            decoration: _inputDeco(hint),
          ),
        ],
      ),
    );
  }

  // Decoração padrão para os Inputs
  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0F265C), width: 1.5),
      ),
    );
  }
}