import 'package:app_mobile/core/service/localizacao_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  FakeGeolocatorPlatform({required this.permission, this.position});

  final LocationPermission permission;
  final Position? position;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    if (position != null) return position!;
    throw Exception('Sem posição');
  }
}

class FakeGeocodingPlatform extends GeocodingPlatform {
  FakeGeocodingPlatform({required this.placemarks});

  final List<Placemark> placemarks;

  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return placemarks;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TC04 - Permissão negada retorna null', () async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      permission: LocationPermission.denied,
    );

    final position = await MapaService.obterLocalizacaoAtual();
    expect(position, isNull);
  });

  test('TC05 - Permissão concedida retorna Position', () async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform(
      permission: LocationPermission.always,
      position: Position(
        latitude: -23.0,
        longitude: -46.0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        altitudeAccuracy: 1,
        heading: 0,
        headingAccuracy: 1,
        speed: 0,
        speedAccuracy: 0,
      ),
    );

    final position = await MapaService.obterLocalizacaoAtual();
    expect(position, isNotNull);
    expect(position?.latitude, -23.0);
    expect(position?.longitude, -46.0);
  });

  test('TC06 - Geocoding válido retorna endereço completo', () async {
    GeocodingPlatform.instance = FakeGeocodingPlatform(
      placemarks: [
        const Placemark(
          street: 'Rua A',
          subLocality: 'Centro',
          postalCode: '01000-000',
          locality: 'São Paulo',
        ),
      ],
    );

    final endereco = await MapaService.obterEnderecoDoMapa(-23.0, -46.0);
    expect(endereco['rua'], 'Rua A');
    expect(endereco['bairro'], 'Centro');
    expect(endereco['cep'], '01000-000');
    expect(endereco['cidade'], 'São Paulo');
  });

  test('TC07 - Geocoding vazio retorna "-"', () async {
    GeocodingPlatform.instance = FakeGeocodingPlatform(placemarks: []);

    final endereco = await MapaService.obterEnderecoDoMapa(-23.0, -46.0);
    expect(endereco['rua'], '-');
    expect(endereco['bairro'], '-');
    expect(endereco['cep'], '-');
    expect(endereco['cidade'], '-');
  });

  test('TC08 - Geocoding com erro retorna "-"', () async {
    GeocodingPlatform.instance = _ErroGeocodingPlatform();

    final endereco = await MapaService.obterEnderecoDoMapa(-23.0, -46.0);
    expect(endereco['rua'], '-');
    expect(endereco['bairro'], '-');
    expect(endereco['cep'], '-');
    expect(endereco['cidade'], '-');
  });
}

class _ErroGeocodingPlatform extends GeocodingPlatform {
  @override
  Future<List<Placemark>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    throw Exception('Erro geocoding');
  }
}