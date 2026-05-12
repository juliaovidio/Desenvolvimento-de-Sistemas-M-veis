# Documento B — Processo de Teste  
Projeto: App Mobile (Gestão de Entregas)  
Tecnologia: Flutter  
Norma aplicada: ISO/IEC/IEEE 29119-2  

## 1. Estratégia de Teste  
- Testes de unidade e widget  
- Mock de serviços de localização  
- Sem uso de Supabase real

## 2. Ambiente de Teste  
- Flutter SDK  
- Dart SDK  
- flutter_test  
- geolocator_platform_interface  
- geocoding (method channel mock)

## 3. Critérios de Entrada  
- Projeto compilando  
- Arquivos reais do app disponíveis  
- Documentos A e C definidos  

## 4. Critérios de Saída  
- 12 casos executados  
- Resultado registrado  
- Erros analisados  

## 5. Ordem de Execução  
1. LoginPage (validações e visibilidade)  
2. MapaService (permissão e geocoding)  
3. UserModel (fromJson)  
4. ParadaModel (Criar/Editar)

## 6. Implementação (arquivos)  
test/  
- login_page_test.dart  
- mapa_service_test.dart  
- user_model_test.dart  
- parada_model_criar_rota_test.dart  
- parada_model_editar_rota_test.dart  

## 7. Execução  
flutter test  

## 8. Conclusão  
Encerrar após execução completa e análise dos resultados.
