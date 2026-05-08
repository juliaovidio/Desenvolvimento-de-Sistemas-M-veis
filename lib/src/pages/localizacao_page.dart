import 'package:app_mobile/core/service/localizacao_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../layout/main_layout.dart';

class LocalizacaoPage extends StatefulWidget {
  final String cargo;
  final String nome;
  final int autorId;

  const LocalizacaoPage({
    Key? key,
    required this.cargo,
    required this.nome,
    required this.autorId,
  }) : super(key: key);

  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage> {
  final MapController mapController = MapController();
  LatLng? localizacaoAtual;
  String endereco = 'Carregando...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacaoInicial();
  }

  Future<void> _carregarLocalizacaoInicial() async {
    try {
      final ultimaLocalizacao =
          await MapaService.obterUltimaLocalizacao(widget.autorId);

      if (ultimaLocalizacao != null) {
        final lat = ultimaLocalizacao['latitude'] as double;
        final lng = ultimaLocalizacao['longitude'] as double;

        setState(() {
          localizacaoAtual = LatLng(lat, lng);
        });

        await _obterEndereco(lat, lng);
      } else {
        await _atualizarLocalizacao();
      }
    } catch (e) {
      _atualizarLocalizacao();
    }
  }

  Future<void> _atualizarLocalizacao() async {
    setState(() => _isLoading = true);

    try {
      final position = await MapaService.obterLocalizacaoAtual();

      if (position != null) {
        final novaLocalizacao = LatLng(position.latitude, position.longitude);

        await MapaService.salvarLocalizacao(
          widget.autorId,
          position.latitude,
          position.longitude,
        );

        setState(() {
          localizacaoAtual = novaLocalizacao;
        });

        await _obterEndereco(position.latitude, position.longitude);

        mapController.move(novaLocalizacao, 18);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Localização atualizada!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erro ao obter localização'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _obterEndereco(double latitude, double longitude) async {
    try {
      final enderecoMap =
          await MapaService.obterEnderecoDoMapa(latitude, longitude);

      setState(() {
        endereco =
            '${enderecoMap['rua']}, ${enderecoMap['bairro']} - ${enderecoMap['cep']}, ${enderecoMap['cidade']}';
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      cargo: widget.cargo,
      nome: widget.nome,
      titulo: 'Localização atual',
      paginaAtiva: 'localizacao_atual',
      autorId: widget.autorId,
      child: Stack(
        children: [
          // 1. CAMADA BASE: MAPA EM TELA CHEIA
          localizacaoAtual != null
              ? FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: localizacaoAtual!,
                    initialZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app_mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: localizacaoAtual!,
                          width: 80.0,
                          height: 80.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.blue[800],
                                    size: 50,
                                  ),
                                  Positioned(
                                    top: 6,
                                    child: CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(Icons.person,
                                          size: 18, color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                transform: Matrix4.translationValues(0.0, -5.0, 0.0),
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
                                  widget.nome,
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
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),

          // 2. CAMADA SUPERIOR: BOTÃO FLUTUANTE DE ATUALIZAR
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00214B),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              onPressed: _isLoading ? null : _atualizarLocalizacao,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color.fromARGB(137, 255, 255, 255),
                      ),
                    )
                  : const Icon(Icons.my_location, color: Colors.black87, size: 20),
              label: Text(
                _isLoading ? 'Atualizando...' : 'Atualizar',
                style: const TextStyle(
                  color: Color.fromARGB(221, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 3. CAMADA INFERIOR: CARTÃO DE ENDEREÇO
          if (localizacaoAtual != null)
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