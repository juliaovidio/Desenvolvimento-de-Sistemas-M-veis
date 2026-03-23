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
