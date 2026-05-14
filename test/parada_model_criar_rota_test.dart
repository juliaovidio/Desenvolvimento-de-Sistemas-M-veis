import 'package:app_mobile/src/pages/tabs_rotas_gerente/criar_rota_tab.dart' as criar;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TC11 - ParadaModel (criar) armazena dados e dispose não falha', () {
    final parada = criar.ParadaModel();

    parada.ordem.text = '1';
    parada.cidade.text = 'São Paulo';
    parada.uf.text = 'SP';
    parada.valorPorParada.text = '150.50';

    expect(parada.ordem.text, '1');
    expect(parada.cidade.text, 'São Paulo');
    expect(parada.uf.text, 'SP');
    expect(parada.valorPorParada.text, '150.50');

    expect(() => parada.dispose(), returnsNormally);
  });
}