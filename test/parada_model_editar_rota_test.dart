import 'package:app_mobile/src/pages/tabs_rotas_gerente/editar_rota_tab.dart' as editar;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TC12 - ParadaModel (editar) status padrão e campos básicos', () {
    final parada = editar.ParadaModel();

    expect(parada.status, 'pendente');

    parada.id = 99;
    parada.cidade.text = 'Campinas';
    parada.status = 'concluido';
    parada.assinouNome.text = 'Carlos';
    parada.assinouCpf.text = '12345678900';

    expect(parada.id, 99);
    expect(parada.cidade.text, 'Campinas');
    expect(parada.status, 'concluido');
    expect(parada.assinouNome.text, 'Carlos');
    expect(parada.assinouCpf.text, '12345678900');

    expect(() => parada.dispose(), returnsNormally);
  });
}