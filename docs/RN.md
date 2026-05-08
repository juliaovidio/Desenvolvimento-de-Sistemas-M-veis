## Regras de negócio do sistema

### RN01 – Vinculação de Rotas:
Uma rota só poderá ser iniciada se estiver previamente atribuída a um motorista cadastrado e a um veículo ativo no sistema.

### RN02 – Atualização de Status:
O motorista deve obrigatoriamente atualizar o status da rota (Em andamento ou Finalizada) para que o gerente consiga acompanhar o progresso do trajeto.  

### RN03 – Registro de Problemas: 
Sempre que o motorista relatar um problema ou falha durante a rota, o sistema deve registrar automaticamente a data, horário e localização do ocorrido, não permitindo alterações posteriores nessas informações.

### RN04 – Exclusividade de Rota Ativa:
Um motorista não pode possuir mais de uma rota em andamento simultaneamente.

### RN05 – Veículo Ativo:
Apenas veículos com status ativo podem ser utilizados em rotas.

### RN06 – Início com Data:
Toda rota iniciada deve registrar automaticamente a data e hora de início.

### RN07 – Finalização de Rota:
Uma rota só pode ser finalizada após todas as entregas vinculadas serem concluídas ou justificadas.

### RN08 – Registro de Localização Temporal:
Toda localização enviada deve conter data e hora obrigatórias.

### RN09 – Imutabilidade do Histórico:
Os registros de histórico não podem ser editados ou excluídos após sua criação.

### RN10 – Problema Vinculado à Entrega:
Todo problema registrado deve estar obrigatoriamente vinculado a uma entrega.

### RN11 – Confirmação de Entrega Única:
Uma entrega só pode ser confirmada uma única vez.

### RN12 – Monitoramento pelo Gerente:
O gerente só pode monitorar rotas que estejam ativas ou em andamento.

### RN13 – Encerramento Automático:
Ao finalizar uma rota, o sistema deve automaticamente registrar a data e hora de término.
