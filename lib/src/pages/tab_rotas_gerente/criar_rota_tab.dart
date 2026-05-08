import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// ---------------------------------------------------------
// Classe para gerenciar os controladores de cada parada
// ---------------------------------------------------------
class ParadaModel {
  TextEditingController ordem = TextEditingController(); // NOVO CAMPO
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
  TextEditingController valorPorParada = TextEditingController(); // NOVO CAMPO

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
        SnackBar(content: Text('Selecione um motorista e um veículo!'), backgroundColor: Colors.red),
      );
      return;
    }

    for (var p in listaParadas) {
      if (p.cidade.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preencha a cidade em todas as paradas!'), backgroundColor: Colors.red),
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

      // Salva as paradas exatamente na ordem em que estão na tela,
      // pegando o número manual que o usuário digitou no campo "Ordem".
      List<Map<String, dynamic>> paradasParaInserir = [];
      for (int i = 0; i < listaParadas.length; i++) {
        final p = listaParadas[i];
        
        // Se o usuário esquecer de digitar a ordem, o sistema coloca a ordem da tela (i+1)
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
          'valor_por_parada': valorParada, // NOVO CAMPO INSERIDO NO BANCO
          'status': 'pendente',
        });
      }

      await supabase.from('paradas').insert(paradasParaInserir);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Rota criada com sucesso!'), backgroundColor: Colors.green),
      );
      
      // Limpar campos após salvar
      descricaoController.clear();
      motoristaSearchController.clear();
      veiculoSearchController.clear();
      tempoController.clear();
      totalKmController.clear();
      valorMotoristaController.clear();
      valorCaminhaoController.clear();
      valorCobrarController.clear();
      cargaTotalController.clear();
      
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Descrição:", descricaoController),
            SizedBox(height: 10),

            Text("Motorista:", style: TextStyle(fontWeight: FontWeight.bold)),
            TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: motoristaSearchController,
                  focusNode: focusNode,
                  decoration: _inputDeco("Nome do motorista"),
                );
              },
              suggestionsCallback: (pattern) async => await buscarMotoristasLivres(pattern),
              itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion['nome'])),
              onSelected: (suggestion) {
                motoristaSearchController.text = suggestion['nome'];
                motoristaSelecionadoId = suggestion['id'];
              },
            ),
            SizedBox(height: 10),

            Text("Veículo:", style: TextStyle(fontWeight: FontWeight.bold)),
            TypeAheadField<Map<String, dynamic>>(
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: veiculoSearchController,
                  focusNode: focusNode,
                  decoration: _inputDeco("Nome do veículo"),
                );
              },
              suggestionsCallback: (pattern) async => await buscarVeiculosLivres(pattern),
              itemBuilder: (context, suggestion) => ListTile(title: Text("${suggestion['descricao']} - ${suggestion['placa']}")),
              onSelected: (suggestion) {
                veiculoSearchController.text = suggestion['descricao'];
                veiculoSelecionadoId = suggestion['id'];
              },
            ),
            SizedBox(height: 20),

            Divider(thickness: 2),
            Text("Paradas:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listaParadas.length,
              itemBuilder: (context, index) {
                final parada = listaParadas[index];
                return Card(
                  color: Colors.grey[100],
                  margin: EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Parada ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                            if (listaParadas.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => listaParadas.removeAt(index)),
                              )
                          ],
                        ),

                        // ===== CAMPOS NOVOS AQUI =====
                        _buildTextField("Ordem", parada.ordem, isNumber: true),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            "pergunte para a IA a melhor ordem",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        ),
                        
                        _buildTextField("Valor por parada:", parada.valorPorParada, isNumber: true),
                        SizedBox(height: 8),
                        // ==============================

                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildTextField("Cidade", parada.cidade)),
                            SizedBox(width: 10),
                            Expanded(flex: 1, child: _buildTextField("UF", parada.uf)),
                          ],
                        ),
                        _buildTextField("Bairro", parada.bairro),
                        _buildTextField("CEP", parada.cep),
                        Row(
                          children: [
                            Expanded(flex: 3, child: _buildTextField("Rua", parada.rua)),
                            SizedBox(width: 10),
                            Expanded(flex: 1, child: _buildTextField("Nº", parada.numero)),
                          ],
                        ),
                        _buildTextField("Empresa/Loja", parada.empresa),
                        _buildTextField("Responsável", parada.responsavel),
                        _buildTextField("CPF/CNPJ", parada.cpfCnpj),
                        _buildTextField("Telefone", parada.telefone),
                        _buildTextField("Informação da Carga", parada.infoCarga),
                      ],
                    ),
                  ),
                );
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                backgroundColor: Colors.yellow[700],
                child: Icon(Icons.add, color: Colors.black),
                onPressed: () => setState(() => listaParadas.add(ParadaModel())),
              ),
            ),
            
            Divider(thickness: 2),
            SizedBox(height: 10),

            _buildTextField("Quant total da carga:", cargaTotalController),
            _buildTextField("Tempo estimado:", tempoController),
            _buildTextField("Total km:", totalKmController, isNumber: true),
            _buildTextField("Valor a pagar motorista:", valorMotoristaController, isNumber: true),
            _buildTextField("Valor gasto caminhão:", valorCaminhaoController, isNumber: true),
            _buildTextField("Valor a cobrar da entrega:", valorCobrarController, isNumber: true),

            SizedBox(height: 30),

            Center(
              child: _isLoading 
                ? CircularProgressIndicator() 
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[400],
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    onPressed: salvarRotaEParadas,
                    child: Text("Salvar e enviar rota", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14)),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: _inputDeco(""),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[300],
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}