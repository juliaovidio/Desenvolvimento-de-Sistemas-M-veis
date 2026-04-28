# 📋 Documentação dos Casos de Uso

---

## UC01 — Autenticar Usuário

**Ator(es):** Motorista, Gerente

**Descrição:** O usuário faz login no sistema com email e senha.

**Pré-condições:**
- Usuário possui conta criada

**Pós-condições:**
- Usuário está logado
- Tela Principal é exibido

**Fluxo Principal:**
1. Usuário abre app
2. Insere email e senha
3. Sistema valida credenciais
4. Sistema mostra tela principal

**Fluxos Alternativos / Exceções:**
- FA01 — Senha incorreta: Sistema exibe erro
- FA02 — Sem internet: não funciona

**Relacionamentos:**
- Include: Validar Credenciais

**Diagrama:**
<img width="267" height="337" alt="image" src="https://github.com/user-attachments/assets/9debc06f-1b28-412d-a837-933e09f05284" />


---

## UC02 — Cadastrar Motorista

**Ator(es):** Gerente

**Descrição:** Gerente adiciona um novo motorista ao sistema.

**Pré-condições:**
- Gerente está logado

**Pós-condições:**
- Motorista foi cadastrado

**Fluxo Principal:**
1. Gerente clica em "Novo Motorista"
2. Preenche dados (nome, CPF, telefone)
3. Insere dados da CNH
4. Clica em confirmar
5. Sistema salva motorista

**Fluxos Alternativos / Exceções:**
- FA01 — CPF duplicado: Sistema avisa
- FA02 — Campo vazio: Sistema mostra aviso

**Relacionamentos:**
- Include: Validar Dados

**Diagrama:**
<img width="242" height="337" alt="image" src="https://github.com/user-attachments/assets/ff7e42ea-e274-482a-a25f-788d2068b20c" />


---

## UC03 — Criar Rota de Entrega

**Ator(es):** Gerente

**Descrição:** Gerente cria uma nova rota de entrega.

**Pré-condições:**
- Gerente está logado
- Motorista cadastrado existe

**Pós-condições:**
- Rota foi criada
- Motorista foi notificado pela aba rotas

**Fluxo Principal:**
1. Gerente clica em "Nova Rota"
2. Seleciona status da rota
3. Escolhe o motorista
4. Adiciona pontos de entrega (endereço)
5. Clica em confirmar
6. Sistema cria a rota

**Fluxos Alternativos / Exceções:**
- FA01 — Motorista sem disponibilidade: Sistema sugere outro
- FA02 — Erro de salvar: Sistema tenta novamente

**Relacionamentos:**
- Include: Associar Motorista
- Extend: Otimizar Rota

**Diagrama:**
<img width="230" height="502" alt="image" src="https://github.com/user-attachments/assets/18ab9380-5421-4f07-beea-8181641d0afe" />


---

## UC04 — Acompanhar Rota em Tempo Real

**Ator(es):** Gerente, Motorista

**Descrição:** Gerente e motorista veem a localização em tempo real durante a rota.

**Pré-condições:**
- Rota foi criada
- Motorista iniciou a rota
- GPS ativado ao entrar no app

**Pós-condições:**
- Posição é atualizada
- Histórico da rota é salvo

**Fluxo Principal:**
1. Motorista inicia rota
2. GPS ativa ao entrar no app e envia posição
3. Gerente vê mapa com motorista
4. Motorista vê próximo ponto

**Fluxos Alternativos / Exceções:**
- FA01 — GPS desativado: Não funciona
- FA02 — Sem internet: Tenta reconectar

**Relacionamentos:**
- Include: Obter Localização GPS
- Extend: Alertar Desvio

**Diagrama:**
<img width="203" height="453" alt="image" src="https://github.com/user-attachments/assets/c171e6c8-adb0-4abb-9692-e2d31ed143fc" />


---

## UC05 — Registrar Entrega

**Ator(es):** Motorista

**Descrição:** Motorista confirma entrega no local, capturando assinatura.

**Pré-condições:**
- Motorista chegou no ponto
- Pacote está disponível

**Pós-condições:**
- Entrega registrada
- Cliente registrado a entrega

**Fluxo Principal:**
1. Motorista chega no endereço
2. Sistema mostra detalhes da entrega
3. Motorista verifica pacote
4. Solicita assinatura do cliente
5. Captura assinatura
6. Confirma entrega

**Fluxos Alternativos / Exceções:**
- FA01 — Cliente não encontrado: Registra falha
- FA02 — Pacote danificado: Fotografa e relata

**Relacionamentos:**
- Include: Capturar Assinatura
- Extend: Fotografar Evidência

**Diagrama:**
<img width="281" height="392" alt="image" src="https://github.com/user-attachments/assets/fbe77495-ece2-4e6a-8fa5-306c2315dead" />


---

## UC06 — Reporte de Problemas

**Ator(es):** Motorista

**Descrição:** Motorista reporta problemas durante a rota.

**Pré-condições:**
- Motorista em rota
- Problema identificado

**Pós-condições:**
- Problema registrado
- Gerente foi notificado

**Fluxo Principal:**
1. Motorista identifica problema
2. Clica em "Reportar Problema"
3. Descreve o problema
4. Confirma envio
5. Sistema mostra ao gerente na aba relatos

**Fluxos Alternativos / Exceções:**
- FA01 — Sem internet: Salva localmente


**Relacionamentos:**
- Include: Localizar Motorista
- Extend: Alertar Suporte

**Diagrama:**
<img width="188" height="303" alt="image" src="https://github.com/user-attachments/assets/11278e7b-5fa0-4ee5-89d8-e1914ea62cef" />


---

## UC07 — Gerar Relatório

**Ator(es):** Gerente

**Descrição:** Gerente gera relatório de rotas e entregas.

**Pré-condições:**
- Gerente está logado
- Há dados registrados

**Pós-condições:**
- Relatório foi gerado na aba vizualizar

**Fluxo Principal:**
1. Gerente clica em "Vizualizar"
2. Seleciona o status
3. Clica em filtrar
5. Sistema mostra os cards com as informações

**Fluxos Alternativos / Exceções:**
- FA01 — Sem dados: Sistema mostra mensagem

**Relacionamentos:**
- Include: Coletar Dados

**Diagrama:**
<img width="190" height="303" alt="image" src="https://github.com/user-attachments/assets/9e009b81-65ab-42df-8525-daf1a78fa8e5" />


---

## UC08 — Atualizar Localização

**Ator(es):** Motorista, Sistema

**Descrição:** Sistema atualiza localização do motorista continuamente.

**Pré-condições:**
- Rota iniciada
- GPS ativo ao entrar app
- Internet disponível

**Pós-condições:**
- Posição salva no servidor a ultima localização
- Gerente vê em tempo real

**Fluxo Principal:**
1. Motorista inicia rota
2. GPS captura coordenadas
3. Sistema envia para servidor a cada entrada no app
4. Servidor armazena
5. Mapa atualiza com nova posição

**Fluxos Alternativos / Exceções:**
- FA01 — GPS desativado: Não funciona

**Relacionamentos:**
- Include: Capturar GPS

**Diagrama:**
<img width="233" height="343" alt="image" src="https://github.com/user-attachments/assets/34449d37-ce8f-4472-82a2-d57b4f685510" />


---

## UC09 — Consultar Histórico

**Ator(es):** Motorista, Gerente

**Descrição:** Usuário consulta histórico de entregas passadas.

**Pré-condições:**
- Usuário está logado
- Há entregas registradas

**Pós-condições:**
- Histórico exibido
- Detalhes acessados

**Fluxo Principal:**
1. Usuário clica em "Finalizados"
2. Sistema lista entregas
3. Usuário seleciona uma entrega
4. Sistema mostra detalhes e assinatura
5. Usuário pode visualizar

**Fluxos Alternativos / Exceções:**
- FA01 — Sem entregas: Mensagem de vazio
- FA02 — Comprovante corrompido: Mostra aviso

**Relacionamentos:**
- Include: Filtrar Histórico

**Diagrama:**
<img width="147" height="358" alt="image" src="https://github.com/user-attachments/assets/d3183cd6-c9d3-4ab5-86ec-855d16a42221" />


---

## UC10 — Notificar Alertas

**Ator(es):** Sistema, Gerente

**Descrição:** Sistema envia notificações importantes ao gerente.

**Pré-condições:**
- Evento ocorreu (problema, atraso, etc)

**Pós-condições:**
- Evento salvo
- Gerente pode agir

**Fluxo Principal:**
1. Sistema detecta evento
2. Gerente recebe
3. Sistema abre contexto na aba falhas

**Fluxos Alternativos / Exceções:**
- FA01 — Erro de envio: Tenta novamente

**Relacionamentos:**
- Include: Detectar Evento

**Diagrama:**
<img width="266" height="367" alt="image" src="https://github.com/user-attachments/assets/bd736c81-935e-4af2-9794-c20021e32f91" />


---

## 📊 Resumo

| UC | Nome | Ator |
|---|---|---|
| UC01 | Autenticar | Motorista, Gerente |
| UC02 | Cadastrar Motorista | Gerente |
| UC03 | Criar Rota | Gerente |
| UC04 | Acompanhar Rota | Gerente, Motorista |
| UC05 | Registrar Entrega | Motorista |
| UC06 | Reporte | Motorista |
| UC07 | Relatório | Gerente |
| UC08 | Atualizar Localização | Motorista, Sistema |
| UC09 | Histórico | Motorista, Gerente |
| UC10 | Notificar | Sistema, Gerente |
