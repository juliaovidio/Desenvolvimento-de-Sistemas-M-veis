# Registro do Trabalho de Testes — App Mobile (Supabase + Flutter)

Data: 2026-05-12  
Repositório: juliaovidio/Desenvolvimento-de-Sistemas-M-veis  
Escopo: Testes de UI/serviço baseados no app real (sem ViewModel)

## 1. Análise do projeto
Foram analisados os seguintes arquivos reais do app:
- lib/src/pages/login_page.dart
- lib/core/service/localizacao_service.dart
- lib/data/model/user_model.dart
- lib/src/pages/rotasGerente_page.dart
- lib/src/pages/rotasMotorista_page.dart
- lib/src/pages/reportarProblema_page.dart
- lib/src/pages/relatos_page.dart
- lib/src/pages/veiculo_page.dart
- lib/src/pages/motorista_page.dart
- lib/src/pages/localizacao_page.dart
- lib/src/pages/motoristas_localizacao_page.dart
- lib/src/pages/tabs_rotas_gerente/*
- lib/src/pages/tab_rotas_motorista/*

## 2. Documentos de teste gerados
Foram criados documentos no padrão ISO/IEC/IEEE 29119:
- Documento A — Base Conceitual de Teste
- Documento B — Processo de Teste
- Documento C — Técnicas e Casos de Teste

## 3. Conjunto de testes criado (12 casos)
Os testes criados cobrem:
- Validações da tela de login
- Controle de visibilidade de senha
- Comportamento de serviços de localização
- Mapeamento de dados do UserModel
- Tratamento de erro em geocoding
- Estruturas de dados das paradas (criar/editar)

Arquivos de teste:
- test/login_page_test.dart (3 testes)
- test/mapa_service_test.dart (5 testes)
- test/user_model_test.dart (2 testes)
- test/parada_model_criar_rota_test.dart (1 teste)
- test/parada_model_editar_rota_test.dart (1 teste)

## 4. Como executar
flutter test

## 5. Observações
- Testes não alteram o repositório.
- Nenhum teste depende de ViewModel (não existe no projeto).
- Uso de Supabase ficou restrito aos serviços mockados pelos testes.
