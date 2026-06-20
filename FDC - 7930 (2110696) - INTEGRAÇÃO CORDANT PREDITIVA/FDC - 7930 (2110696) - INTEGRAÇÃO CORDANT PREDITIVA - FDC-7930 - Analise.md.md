# FDC-7930 - Integração Cordant Preditiva

## 1. Resumo executivo

A FDC-7930 trata da integração dos dados do servidor **Preditiva Online / System 1** da Automação de Mina para o **Cordant Asset Health**, solução em nuvem da Baker Hughes usada para concentração, análise e visualização de dados de vibração e variáveis de processo.

A demanda é classificada como **OT** e envolve comunicação entre ambiente industrial/local e serviços externos em nuvem, exigindo validação criteriosa de arquitetura, portas, URLs, sentido do tráfego, segurança, rastreabilidade e aderência aos padrões Vale/ISO.

Fontes analisadas:
- Formulário da FDC-7930 informado pelo solicitante.
- HLD “Online Predictive CKS - Carajás”.
- Guia “Cordant Asset Health Connector Guide”. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

---

## 2. Dados principais da demanda

| Campo | Informação |
|---|---|
| ID FDC | 7930 |
| Solicitante | George Bueno de Souza |
| E-mail | george.souza@vale.com |
| Gerente do Projeto | george.souza@vale.com |
| Área | COORD OPER MANUT PREDITIVA |
| Departamento | PREDITIVA |
| Arquiteto | claudio.dalcol@vale.com |
| Coletor de Custo | 1020770 |
| Entidade pagadora | 1001 - Vale S/A |
| Classificação | OT |
| Tipo Network | Netscaler & Load Balance |
| Requisito especial | Nenhum requisito especial |

---

## 3. Objetivo técnico

Integrar dados do ambiente **Preditiva Online / System 1** para o **Cordant Asset Health**, permitindo que a plataforma Cordant faça a centralização, análise e visualização dos dados de monitoramento preditivo.

O guia da Baker Hughes informa que o Cordant Asset Health coleta dados de fontes como **System 1**, **SAP** e **PI**, exibindo-os em uma plataforma única de dashboard. Para System 1, o conector consulta os servidores System 1 e envia os dados atualizados ao Cordant Asset Health. :contentReference[oaicite:2]{index=2}

---

## 4. Arquitetura observada no HLD

O HLD mostra a solução **Online Predictive CKS - Carajás**, com fluxo entre ambiente OT local, IDMZ 2.0, Valenet, DMZ/Internet e cloud. O diagrama contém elementos como:

- System 1 TX Server
- System 1 RX Server
- System 1 Client
- OSIsoft PI / PI System
- Informatica Managed File Transfer
- Citrix ADC 13.1
- Azure Red Hat OpenShift ARO
- Azure Entra ID
- AWS / Cordant Asset Health
- Jump Server
- Kepware / OPC UA / OPC DA
- PLCs, sensores e VBOnline Pro

O HLD também explicita portas como **TCP 443**, **TCP 5671 AMQPS**, **TCP 22 SFTP**, **TCP 3389 RDP**, **TCP 636 LDAPS**, além de portas específicas industriais como **5450, 7550, 7551, 7560, 60005, 60006 e 60007**. :contentReference[oaicite:3]{index=3}

---

## 5. Escopo de rede informado na FDC

Origem informada:

```text
172.19.44.151

Destinos informados:

```
mq-bnhost2.na.system1assethealth.bakerhughes.com:20009auth-bnhost2.na.system1assethealth.bakerhughes.com:443bnhost2.na.system1assethealth.bakerhughes.com:443
```

Interpretação:

- `auth-bnhost2...:443` provavelmente é endpoint de autenticação/OAuth.
- `bnhost2...:443` provavelmente é endpoint HTTPS da aplicação/API.
- `mq-bnhost2...:20009` provavelmente é endpoint de mensageria/broker específico do ambiente Baker Hughes.
- A origem `172.19.44.151` deve ser confirmada como servidor System 1 / Connector / componente autorizado no HLD.

---

## 6. Pontos de atenção técnica

### 6.1 Divergência de porta de mensageria

O guia da Baker Hughes informa como padrão a necessidade de liberar:

```
HTTPS 443AMQPS 5671
```

para comunicação do conector com o Cordant Asset Health.

Porém, a FDC solicita:

```
mq-bnhost2.na.system1assethealth.bakerhughes.com:20009
```

Essa diferença precisa ser validada com Baker Hughes / DevOps / arquitetura, pois pode indicar porta customizada do ambiente SaaS/BH Cloud. O próprio guia menciona que, para SaaS/BH Cloud em AWS, RabbitMQ pode usar porta customizada.

**Ação recomendada:** registrar evidência formal confirmando que a porta `20009` é correta para o broker do ambiente Cordant utilizado.

---

### 6.2 Sentido do fluxo

A demanda parece requerer fluxo **de saída** do ambiente Vale/OT para Cordant/Baker Hughes.

Não há indicação de necessidade de conexão iniciada da internet para dentro da Vale.

**Recomendação:** escrever a regra como outbound controlado:

```
Origem: 172.19.44.151Destino: FQDNs Baker Hughes / CordantPortas: TCP 443 e TCP 20009Sentido: Vale OT → Internet/Baker Hughes
```

---

### 6.3 Uso de FQDN em vez de IP fixo

Os destinos são URLs/FQDNs, não IPs. Isso sugere que a regra deve suportar resolução dinâmica de DNS, ou que a equipe de firewall/proxy deve confirmar como tratar FQDNs externos.

**Risco:** IPs de serviços cloud/SaaS podem mudar.

**Ação recomendada:** evitar regra por IP fixo, salvo se Baker Hughes fornecer range oficial e estável.

---

### 6.4 Proxy corporativo

O guia informa que, em ambiente corporativo com proxy, pode ser necessário configurar proxy para Azure Service Bus, e que conexão AmazonMQ via proxy pode não ser suportada.

**Ação recomendada:** confirmar se o servidor `172.19.44.151` sai diretamente via firewall/NAT ou se precisa passar por proxy corporativo.

---

### 6.5 Segurança

O guia informa uso de **TLS 1.2**, SSL authentication e configuração de certificados para RabbitMQ/conector.

**Ação recomendada:** garantir que:

- inspeção SSL não quebre a comunicação;
- certificados necessários estejam válidos;
- autenticação OAuth esteja funcionando;
- credenciais e secrets não sejam armazenados em planilhas abertas.

---

## 7. Checklist para RFC / MOP

- [ ]  Confirmar se `172.19.44.151` é o servidor correto do conector/System 1.
- [ ]  Confirmar se a comunicação é somente outbound.
- [ ]  Validar porta `20009` com Baker Hughes/DevOps.
- [ ]  Validar se também será necessária porta `5671`.
- [ ]  Confirmar necessidade ou não de proxy.
- [ ]  Confirmar se firewall aceita regra por FQDN.
- [ ]  Confirmar se haverá SSL inspection.
- [ ]  Executar teste de conectividade após liberação.
- [ ]  Registrar evidências de teste.
- [ ]  Anexar HLD, guia do conector e evidências na pasta da FDC.

---

## 8. Testes recomendados após liberação

No servidor de origem:

```
Test-NetConnection auth-bnhost2.na.system1assethealth.bakerhughes.com -Port 443Test-NetConnection bnhost2.na.system1assethealth.bakerhughes.com -Port 443Test-NetConnection mq-bnhost2.na.system1assethealth.bakerhughes.com -Port 20009
```

Se for necessário validar a porta padrão documentada:

```
Test-NetConnection mq-bnhost2.na.system1assethealth.bakerhughes.com -Port 5671
```

---

## 9. Riscos identificados

|Risco|Impacto|Mitigação|
|---|---|---|
|Porta 20009 não validada formalmente|Falha na RFC ou conectividade|Solicitar confirmação Baker Hughes/DevOps|
|FQDN com IP dinâmico|Regra pode parar após mudança de IP|Usar regra por FQDN ou range oficial|
|Proxy incompatível|Conector pode não comunicar com broker|Validar arquitetura de saída|
|SSL inspection|Pode quebrar TLS/certificado|Avaliar bypass controlado|
|Origem incorreta|Regra não funcionará|Confirmar IP do servidor conector|
|Falta de evidência|Problema em auditoria ISO|Guardar testes, prints e aprovações|

---

## 10. Conclusão

A FDC-7930 é tecnicamente coerente com uma integração OT → Cloud para envio de dados preditivos do System 1/Preditiva Online ao Cordant Asset Health.

O principal ponto crítico é a validação da porta de mensageria `20009`, pois o guia oficial cita `443` e `5671` como portas usuais, mas também admite porta customizada em cenários SaaS/BH Cloud. Antes da RFC, essa porta deve ser formalmente confirmada.

A estrutura da FDC deve manter anexados:

- HLD do projeto;
- guia do Cordant Connector;
- evidência da validação da porta;
- evidência de teste de conectividade;
- MOP;
- carta de risco;
- logs da execução.

```
Essa nota pode virar o arquivo:```textFDC - 7930 (2110696) - INTEGRAÇÃO CORDANT PREDITIVA\FDC-7930 - Analise.md
```