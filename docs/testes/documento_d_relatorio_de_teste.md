# Documento D — Relatório de Teste
Projeto: App Mobile (Gestão de Entregas)  
Tecnologia: Flutter  
Arquitetura: Pages + Services (Supabase)  
Norma aplicada: ISO/IEC/IEEE 29119-3  

## 1. Objetivo
Registrar a execução dos testes implementados no projeto Flutter, documentando os resultados obtidos, falhas encontradas e análise final do comportamento do sistema.

## 2. Ambiente de Execução
Ambiente utilizado:
- Flutter SDK
- Dart SDK
- flutter_test
- geolocator_platform_interface
- geocoding (method channel mock)

## 3. Estrutura dos Testes Executados
```
test/
  - login_page_test.dart
  - mapa_service_test.dart
  - user_model_test.dart
  - parada_model_criar_rota_test.dart
  - parada_model_editar_rota_test.dart
```

## 4. Execução dos Testes
```
flutter test
```

## 5. Resultados dos Testes Unitários
| Caso | Objetivo | Resultado Esperado | Resultado Obtido | Status |
|------|----------|--------------------|------------------|--------|
| TC01 | Login com e-mail inválido | SnackBar "e-mail válido" | SnackBar exibido | Aprovado |
| TC02 | Login com senha vazia | SnackBar "senha não pode estar vazia" | SnackBar exibido | Aprovado |
| TC03 | Alternar visibilidade da senha | Ícone muda para visibilidade_off | Ícone alterado | Aprovado |
| TC04 | Permissão de localização negada | obterLocalizacaoAtual() retorna null | Retornou null | Aprovado |
| TC05 | Permissão concedida retorna Position | Retorna Position válida | Position válida | Aprovado |
| TC06 | Geocoding com retorno válido | Endereço completo (rua/bairro/cep/cidade) | Endereço retornado | Aprovado |
| TC07 | Geocoding vazio | Retornos com "-" | Retornos com "-" | Aprovado |
| TC08 | Geocoding com erro | Retornos com "-" | Retornos com "-" | Aprovado |
| TC09 | UserModel.fromJson mapeia id/cargo | id e cargo corretos | id e cargo corretos | Aprovado |
| TC10 | UserModel.fromJson mapeia senha_hash | senhaHash igual ao json | senhaHash correto | Aprovado |
| TC11 | ParadaModel (Criar) armazena dados | Campos com valores corretos | Valores corretos | Aprovado |
| TC12 | ParadaModel (Editar) mantém status e campos | Valores mantidos e status correto | Valores corretos | Aprovado |

## 6. Simulação de Falha
Não foi realizada simulação de falha neste conjunto de testes.

## 7. Análise dos Resultados
Os testes unitários validaram corretamente:
- Regras de validação da tela de login
- Controle de visibilidade de senha
- Comportamento do serviço de localização
- Conversão de dados do UserModel
- Estruturas de dados das paradas (criar/editar)

## 8. Benefícios Observados
- Uso de mocks garantiu previsibilidade e execução rápida
- Separação da lógica permitiu testar componentes isoladamente

## 9. Problemas Encontrados
Nenhuma falha funcional foi encontrada durante os testes.

## 10. Conclusão Final
Os testes executados demonstraram que o sistema atende aos requisitos funcionais definidos inicialmente, com cobertura das regras principais de login, localização e modelos de dados.

## 11. Estatísticas Finais
| Tipo | Quantidade |
|------|------------|
| Testes planejados | 12 |
| Testes executados | 12 |
| Testes aprovados | 12 |
| Testes reprovados | 0 |
| Falhas simuladas | 0 |
