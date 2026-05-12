# Documento A — Base Conceitual de Teste  
Projeto: App Mobile (Gestão de Entregas)  
Tecnologia: Flutter  
Arquitetura: Pages + Services (Supabase)  
Norma aplicada: ISO/IEC/IEEE 29119-1  

## 1. Sistema sob teste  
Aplicativo de gestão de entregas com autenticação, rotas, veículos, motoristas, relatos e localização via Supabase.

## 2. Itens de teste  
- LoginPage  
- AuthRepository  
- MapaService  
- UserModel  
- ParadaModel (Criar Rota)  
- ParadaModel (Editar Rota)  
- Fluxos de validação local (login e serviços)

## 3. Escopo  
- Validação de login (campos e mensagens)  
- Localização (permissão, geocoding, resposta)  
- Conversão de dados de usuário  
- Estruturas de dados das paradas  
- Comportamentos básicos sem acesso real ao Supabase

## 4. Fora de escopo  
- Testes de integração com Supabase real  
- Testes de performance  
- Segurança e criptografia  
- Testes de UI completos das telas com chamadas reais

## 5. Requisitos de teste (RT)  
RT01 — Impedir login com e-mail inválido  
RT02 — Impedir login com senha vazia  
RT03 — Alternar visibilidade da senha  
RT04 — Retornar null se permissão de localização for negada  
RT05 — Retornar posição válida se permissão for concedida  
RT06 — Obter endereço pelo geocoding quando possível  
RT07 — Retornar valores padrão quando geocoding falhar  
RT08 — Retornar valores padrão quando geocoding retornar vazio  
RT09 — Converter corretamente JSON em UserModel  
RT10 — Garantir mapeamento da senha_hash no UserModel  
RT11 — ParadaModel (Criar) armazena dados corretamente  
RT12 — ParadaModel (Editar) mantém status e campos  
