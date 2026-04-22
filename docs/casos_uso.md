# Casos de Uso do Sistema de Gestão de Entregas

# Caso de Uso 01 – Atualizar localização da rota

**Ator:** Motorista  

**Objetivo:** Informar ao gerente a localização atual durante a entrega.

## Pré-condições

- O motorista deve estar logado no aplicativo.
- O motorista deve ter permitido o acesso à localização no dispositivo.
- A rota deve estar atribuída ao motorista.

## Pós-condições

- A localização atual do motorista é enviada ao sistema.
- O gerente consegue visualizar a atualização da rota.

## Fluxo Principal

1. O motorista acessa o aplicativo.
2. O sistema verifica se a permissão de localização está ativa.
3. O motorista pressiona o botão de atualizar localização.
4. O sistema coleta a localização atual do motorista.
5. O sistema envia a localização para o gerente.
6. O sistema registra a atualização no histórico de atividades.

## Fluxos Alternativos

### A1 – Permissão de localização negada

1. O sistema solicita novamente a permissão de localização ao motorista.
2. Caso o motorista não autorize, a atualização não poderá ser realizada.

### A2 – Falha na conexão

1. O sistema tenta reenviar a localização automaticamente quando a conexão for restabelecida.

## Regras de Negócio Relacionadas

- RN02 – Atualização de Status

## Requisitos Relacionados

- RF01 – Permissão de localidade  
- RF02 – Compartilhamento de Conteúdo  
- RNF02 – Desempenho  

---

# Caso de Uso 02 – Iniciar rota de entrega

**Ator:** Motorista  

**Objetivo:** Iniciar uma rota previamente atribuída para realizar entregas.

## Pré-condições

- O motorista deve estar autenticado no sistema.
- A rota deve estar vinculada ao motorista e ao veículo.
- A rota deve estar disponível para início.

## Pós-condições

- A rota passa para o status **"Em andamento"**.
- O gerente consegue acompanhar o progresso da rota.

## Fluxo Principal

1. O motorista acessa o aplicativo.
2. O motorista visualiza a rota atribuída.
3. O motorista seleciona a opção **"Iniciar rota"**.
4. O sistema altera o status da rota para **"Em andamento"**.
5. O sistema registra o início da rota no histórico de atividades.

## Fluxos Alternativos

### A1 – Rota não atribuída ao motorista

1. O sistema impede o início da rota.
2. O sistema exibe uma mensagem informando que a rota não está vinculada ao motorista.

### A2 – Veículo não ativo

1. O sistema bloqueia o início da rota.
2. O sistema informa o problema ao motorista.

## Regras de Negócio Relacionadas

- RN01 – Vinculação de Rotas  
- RN02 – Atualização de Status  

## Requisitos Relacionados

- RF03 – Histórico de Atividades  
- RNF01 – Segurança da Informação  
- RNF03 – Disponibilidade  

---

# Caso de Uso 03 – Confirmar entrega de produto

**Ator:** Motorista  

**Objetivo:** Registrar que um produto foi entregue ao destinatário.

## Pré-condições

- A rota deve estar **em andamento**.
- O motorista deve estar autenticado no aplicativo.
- O produto deve estar vinculado à rota.

## Pós-condições

- A entrega do produto é registrada no sistema.
- O gerente consegue visualizar que a entrega foi concluída.

## Fluxo Principal

1. O motorista acessa a lista de entregas da rota.
2. O motorista seleciona o produto entregue.
3. O motorista confirma a entrega no aplicativo.
4. O sistema registra a confirmação da entrega.
5. O sistema atualiza o histórico da rota.

## Fluxos Alternativos

### A1 – Problema na entrega

1. O motorista registra um problema no sistema.
2. O sistema registra automaticamente a **data, horário e localização do ocorrido**.

### A2 – Falha na atualização

1. O sistema salva temporariamente a informação.
2. O sistema sincroniza quando houver conexão.

## Regras de Negócio Relacionadas

- RN02 – Atualização de Status  
- RN03 – Registro de Problemas  

## Requisitos Relacionados

- RF03 – Histórico de Atividades  
- RNF01 – Segurança da Informação  
- RNF02 – Desempenho

---

# Caso de Uso 04 – Visualizar rota

**Ator:** Gerente  

**Objetivo:** Acompanhar o status e progresso de uma rota em execução.

## Pré-condições

- O gerente deve estar autenticado no sistema.
- Deve existir pelo menos uma rota cadastrada.

## Pós-condições

- O gerente visualiza os dados atualizados da rota.

## Fluxo Principal

1. O gerente acessa o sistema.
2. O gerente seleciona uma rota.
3. O sistema exibe o status da rota.
4. O sistema apresenta a localização atual do motorista.
5. O sistema mostra o histórico da rota.

## Fluxos Alternativos

### A1 – Rota inexistente

1. O sistema exibe mensagem informando que não há rotas disponíveis.

## Regras de Negócio Relacionadas

- RN12 – Monitoramento pelo Gerente

## Requisitos Relacionados

- RF10 – Visualização de Rotas pelo Gerente  

---

# Caso de Uso 05 – Registrar problema na entrega

**Ator:** Motorista  

**Objetivo:** Registrar um problema ocorrido durante uma entrega.

## Pré-condições

- O motorista deve estar autenticado.
- A rota deve estar em andamento.

## Pós-condições

- O problema é registrado no sistema.

## Fluxo Principal

1. O motorista acessa a entrega.
2. O motorista seleciona a opção “Registrar problema”.
3. O motorista descreve o problema.
4. O sistema coleta data, hora e localização automaticamente.
5. O sistema registra o problema.

## Fluxos Alternativos

### A1 – Falha na conexão

1. O sistema armazena o problema localmente.
2. O sistema sincroniza quando houver conexão.

## Regras de Negócio Relacionadas

- RN03 – Registro de Problemas  
- RN10 – Problema Vinculado à Entrega  

## Requisitos Relacionados

- RF13 – Registro de Histórico  

---

# Caso de Uso 06 – Finalizar rota

**Ator:** Motorista  

**Objetivo:** Encerrar uma rota após a conclusão das entregas.

## Pré-condições

- A rota deve estar em andamento.

## Pós-condições

- A rota é marcada como finalizada.

## Fluxo Principal

1. O motorista acessa a rota.
2. O motorista seleciona “Finalizar rota”.
3. O sistema valida as entregas.
4. O sistema altera o status para “Finalizada”.
5. O sistema registra o término no histórico.

## Fluxos Alternativos

### A1 – Entregas pendentes

1. O sistema impede a finalização.
2. O sistema informa as entregas não concluídas.

## Regras de Negócio Relacionadas

- RN07 – Finalização de Rota  
- RN13 – Encerramento Automático  

## Requisitos Relacionados

- RF08 – Início de Rota  
- RF13 – Registro de Histórico  

---

# Caso de Uso 07 – Cadastrar veículo

**Ator:** Gerente  

**Objetivo:** Registrar um novo veículo no sistema.

## Pré-condições

- O gerente deve estar autenticado.

## Pós-condições

- O veículo é cadastrado no sistema.

## Fluxo Principal

1. O gerente acessa o sistema.
2. O gerente seleciona “Cadastrar veículo”.
3. O gerente informa os dados do veículo.
4. O sistema salva o veículo.

## Fluxos Alternativos

### A1 – Dados inválidos

1. O sistema exibe mensagem de erro.

## Regras de Negócio Relacionadas

- RN05 – Veículo Ativo  

## Requisitos Relacionados

- RF05 – Cadastro de Veículo  

---

# Caso de Uso 08 – Cadastrar motorista

**Ator:** Gerente  

**Objetivo:** Registrar um novo motorista no sistema.

## Pré-condições

- O gerente deve estar autenticado.

## Pós-condições

- O motorista é cadastrado no sistema.

## Fluxo Principal

1. O gerente acessa o sistema.
2. O gerente seleciona “Cadastrar motorista”.
3. O gerente informa os dados.
4. O sistema salva o motorista.

## Fluxos Alternativos

### A1 – Dados incompletos

1. O sistema solicita correção.

## Regras de Negócio Relacionadas

- RN04 – Exclusividade de Rota Ativa  

## Requisitos Relacionados

- RF04 – Cadastro de Motorista  

---

# Caso de Uso 09 – Vincular veículo ao motorista

**Ator:** Gerente  

**Objetivo:** Associar um veículo a um motorista.

## Pré-condições

- O motorista e o veículo devem estar cadastrados.

## Pós-condições

- O vínculo é registrado no sistema.

## Fluxo Principal

1. O gerente seleciona o motorista.
2. O gerente seleciona o veículo.
3. O sistema valida a disponibilidade.
4. O sistema registra o vínculo.

## Fluxos Alternativos

### A1 – Veículo inativo

1. O sistema impede a vinculação.

## Regras de Negócio Relacionadas

- RN05 – Veículo Ativo  

## Requisitos Relacionados

- RF06 – Associação de Veículo ao Motorista  

---

# Caso de Uso 10 – Criar rota

**Ator:** Gerente  

**Objetivo:** Criar uma nova rota de entregas.

## Pré-condições

- O gerente deve estar autenticado.

## Pós-condições

- A rota é cadastrada no sistema.

## Fluxo Principal

1. O gerente acessa o sistema.
2. O gerente seleciona “Criar rota”.
3. O gerente informa os dados da rota.
4. O sistema salva a rota.

## Fluxos Alternativos

### A1 – Dados inválidos

1. O sistema solicita correção.

## Regras de Negócio Relacionadas

- RN01 – Vinculação de Rotas  

## Requisitos Relacionados

- RF07 – Criação de Rotas  

---

# Caso de Uso 11 – Atribuir rota ao motorista

**Ator:** Gerente  

**Objetivo:** Vincular uma rota a um motorista.

## Pré-condições

- A rota e o motorista devem existir.

## Pós-condições

- A rota fica disponível para execução.

## Fluxo Principal

1. O gerente seleciona a rota.
2. O gerente seleciona o motorista.
3. O sistema realiza a vinculação.

## Fluxos Alternativos

### A1 – Motorista indisponível

1. O sistema impede a atribuição.

## Regras de Negócio Relacionadas

- RN01 – Vinculação de Rotas  

## Requisitos Relacionados

- RF08 – Início de Rota  

---

# Caso de Uso 12 – Visualizar histórico

**Ator:** Motorista / Gerente  

**Objetivo:** Consultar o histórico de atividades de uma rota.

## Pré-condições

- Deve existir histórico registrado.

## Pós-condições

- O histórico é exibido ao usuário.

## Fluxo Principal

1. O usuário acessa o sistema.
2. O usuário seleciona uma rota.
3. O sistema exibe o histórico.

## Fluxos Alternativos

### A1 – Sem histórico

1. O sistema informa que não há registros.

## Regras de Negócio Relacionadas

- RN09 – Imutabilidade do Histórico  

## Requisitos Relacionados

- RF03 – Histórico de Atividades  

---

# Caso de Uso 13 – Atualizar status da rota

**Ator:** Motorista  

**Objetivo:** Atualizar o status da rota durante sua execução.

## Pré-condições

- A rota deve estar iniciada.

## Pós-condições

- O status da rota é atualizado.

## Fluxo Principal

1. O motorista acessa a rota.
2. O motorista seleciona um novo status.
3. O sistema atualiza o status.
4. O sistema registra a alteração no histórico.

## Fluxos Alternativos

### A1 – Status inválido

1. O sistema bloqueia a alteração.

## Regras de Negócio Relacionadas

- RN02 – Atualização de Status  

## Requisitos Relacionados

- RF13 – Registro de Histórico  

---
