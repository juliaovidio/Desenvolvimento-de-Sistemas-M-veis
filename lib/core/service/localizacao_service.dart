import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

class MapaService {
  static final supabase = Supabase.instance.client;

  // ==========================================
  // OBTER LOCALIZAÇÃO ATUAL
  // ==========================================
  static Future<Position?> obterLocalizacaoAtual() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // OBTER ENDEREÇO
  // ==========================================
  static Future<Map<String, String>> obterEnderecoDoMapa(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return {
          'rua': placemark.street ?? '-',
          'bairro': placemark.subLocality ?? '-',
          'cep': placemark.postalCode ?? '-',
          'cidade': placemark.locality ?? '-',
        };
      }

      return {
        'rua': '-',
        'bairro': '-',
        'cep': '-',
        'cidade': '-',
      };
    } catch (e) {
      return {
        'rua': '-',
        'bairro': '-',
        'cep': '-',
        'cidade': '-',
      };
    }
  }

  // ==========================================
  // SALVAR LOCALIZAÇÃO
  // ==========================================
  static Future<bool> salvarLocalizacao(
    int motoristaId,
    double latitude,
    double longitude,
  ) async {
    try {
      await supabase.from('localizacoes').insert({
        'motorista_id': motoristaId,
        'latitude': latitude,
        'longitude': longitude,
        'registrado_em': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // OBTER ÚLTIMA LOCALIZAÇÃO
  // ==========================================
  static Future<Map<String, dynamic>?> obterUltimaLocalizacao(
    int motoristaId,
  ) async {
    try {
      final response = await supabase
          .from('localizacoes')
          .select()
          .eq('motorista_id', motoristaId)
          .order('registrado_em', ascending: false)
          .limit(1)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // OBTER MOTORISTAS EM ANDAMENTO
  // ==========================================
  static Future<List<Map<String, dynamic>>> obterMotoristasEmAndamento() async {
    try {
      final rotas = await supabase
          .from('rotas')
          .select('motorista_id')
          .eq('status', 'em andamento')
          .not('motorista_id', 'is', null);

      Set<int> motoristasIds = {};
      for (var rota in rotas) {
        final motoristaId = rota['motorista_id'];
        if (motoristaId != null) {
          motoristasIds.add(motoristaId as int);
        }
      }

      if (motoristasIds.isEmpty) {
        return [];
      }

      final motoristas = await supabase
          .from('funcionarios')
          .select('id, nome')
          .filter('id', 'in', '(${motoristasIds.join(',')})');

      return List<Map<String, dynamic>>.from(motoristas);
    } catch (e) {
      return [];
    }
  }
}