import 'package:app_mobile/core/service/localizacao_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../layout/main_layout.dart';

class MotoristasLocalizacaoPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const MotoristasLocalizacaoPage({
    Key? key,
    required this.cargo,
    required this.nome,
    required this.autorId,
  }) : super(key: key);

  @override
  State<MotoristasLocalizacaoPage> createState() =>
      _MotoristasLocalizacaoPageState();
}

class _MotoristasLocalizacaoPageState extends State<MotoristasLocalizacaoPage> {
  final MapController mapController = MapController();
  List<Map<String, dynamic>> motoristas = [];
  int? motoristaIdSelecionado;
  String? motoristaNomeSelecionado;
  LatLng? localizacaoSelecionada;
  String endereco = '-';
  bool _isLoading = true;

  // Localização padrão inicial (ex: São Paulo) para o mapa não ficar em branco
  // antes de selecionar um motorista.
  final LatLng localizacaoPadrao = const LatLng(-23.5505, -46.6333);

  @override
  void initState() {
    super.initState();
    _carregarMotoristasEmAndamento();
  }

  Future<void> _carregarMotoristasEmAndamento() async {
    try {
      final lista = await MapaService.obterMotoristasEmAndamento();

      setState(() {
        motoristas = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarMotorista(int motoristaId) async {
    final motorista = motoristas.firstWhere((m) => m['id'] == motoristaId);
    
    try {
      final localizacao =
          await MapaService.obterUltimaLocalizacao(motoristaId);

      if (localizacao != null) {
        final lat = localizacao['latitude'] as double;
        final lng = localizacao['longitude'] as double;
        final novaLocalizacao = LatLng(lat, lng);

        setState(() {
          motoristaIdSelecionado = motoristaId;
          motoristaNomeSelecionado = motorista['nome'];
          localizacaoSelecionada = novaLocalizacao;
        });

        final enderecoMap =
            await MapaService.obterEnderecoDoMapa(lat, lng);

        setState(() {
          endereco =
              '${enderecoMap['rua']}, ${enderecoMap['bairro']} - ${enderecoMap['cep']}, ${enderecoMap['cidade']}';
        });

        mapController.move(novaLocalizacao, 16);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma localização encontrada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      titulo: 'Localização de motoristas',
      paginaAtiva: 'localizacao_motorista',
      autorId: widget.autorId,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 1. CAMADA BASE: MAPA EM TELA CHEIA
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: localizacaoSelecionada ?? localizacaoPadrao,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app_mobile',
                    ),
                    if (localizacaoSelecionada != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: localizacaoSelecionada!,
                            width: 80.0,
                            height: 80.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Ícone do Motorista estilizado como na foto
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Color(0xFF00214B),
                                      size: 50,
                                    ),
                                    Positioned(
                                      top: 6,
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: Colors.grey[300],
                                        // Usando ícone genérico, substitua por backgroundImage se tiver a URL da foto do motorista
                                        child: Icon(Icons.person, size: 18, color: Colors.grey[700]), 
                                      ),
                                    ),
                                  ],
                                ),
                                // Rótulo do nome
                                Container(
                                  transform: Matrix4.translationValues(0.0, -5.0, 0.0), // Ajuste fino para aproximar do pino
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    motoristaNomeSelecionado ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // 2. CAMADA SUPERIOR: BARRA DE PESQUISA / DROPDOWN
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                              hint: const Text(
                                'Selecionar Motorista',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              value: motoristaIdSelecionado,
                              items: motoristas.map((motorista) {
                                return DropdownMenuItem<int>(
                                  value: motorista['id'],
                                  child: Text(
                                    motorista['nome'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _selecionarMotorista(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. CAMADA INFERIOR: CARTÃO DE ENDEREÇO
                if (localizacaoSelecionada != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 28,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Endereço Atual',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  endereco,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}