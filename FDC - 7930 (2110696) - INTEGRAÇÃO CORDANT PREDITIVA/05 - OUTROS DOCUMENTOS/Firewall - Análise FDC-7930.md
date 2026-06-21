# Firewall - Análise Técnica FDC-7930

## 1. Informações da demanda

| Item | Informação |
|---|---|
| FDC | 7930 |
| Projeto | Integração Cordant Preditiva |
| ID | 2110696 |
| Tecnologia | System 1 / Cordant Asset Health |
| Tipo | OT |
| Fabricante Cloud | Baker Hughes |
| Ambiente | AWS / Cordant Asset Health |
| Data da análise | 21/06/2026 |
| Responsável | Jefferson |

---

# 2. Objetivo da alteração

Permitir a comunicação do servidor de Preditiva Online (System 1) localizado no ambiente OT da Vale com a plataforma Cordant Asset Health da Baker Hughes em nuvem.

O fluxo é necessário para envio de dados de monitoramento preditivo, vibração e variáveis de processo para análise centralizada no Cordant.

---

# 3. Arquitetura prevista

Conforme HLD Online Predictive CKS:

```
System 1 Server
172.19.44.151
        |
        v
OT Zone
        |
        v
IDMZ 2.0
        |
        v
Valenet
        |
        v
Internet DMZ
        |
        v
Cordant Asset Health (AWS)
```

Fluxo esperado:

```
Origem:
172.19.44.151

Destino:
auth-bnhost2.na.system1assethealth.bakerhughes.com TCP/443
bnhost2.na.system1assethealth.bakerhughes.com TCP/443
mq-bnhost2.na.system1assethealth.bakerhughes.com TCP/20009
```

---

# 4. Análise do Firewall Cisco ASA

## Equipamento analisado

Cisco ASA

Arquivo de evidência:

```
ANTES-running-config.172.19.79.162.2026-06-21-075521.533.txt
```

---

# 5. Objeto de origem identificado

Foi localizado no firewall o objeto referente ao servidor System 1:

```cisco
object network BENTELY-PREDITIVA_SRV
 host 172.19.44.151
```

Conclusão:

- Servidor já cadastrado no firewall.
- Não é necessário criar novo objeto de origem.

---

# 6. Análise de NAT

Foi realizada busca no running-config para identificar NAT associado ao IP 172.19.44.151.

Resultado:

- Não foi identificado NAT dedicado para o servidor.
- O objeto BENTELY-PREDITIVA_SRV possui apenas definição de host.
- Não existe linha `nat` associada ao objeto.

Exemplo esperado caso existisse:

```cisco
object network BENTELY-PREDITIVA_SRV
 host 172.19.44.151
 nat (inside,outside) static x.x.x.x
```

Conclusão:

⚠️ Necessário validar se existe PAT de saída compartilhado para a rede OT.

Comandos recomendados:

```cisco
show nat detail

show running-config nat | include 172.19.44.151
```

---

# 7. Objetos de destino necessários

Devem ser criados objetos FQDN para os serviços Cordant:

```cisco
object network FQDN_CORDANT_AUTH_BNHOST2
 fqdn v4 auth-bnhost2.na.system1assethealth.bakerhughes.com


object network FQDN_CORDANT_APP_BNHOST2
 fqdn v4 bnhost2.na.system1assethealth.bakerhughes.com


object network FQDN_CORDANT_MQ_BNHOST2
 fqdn v4 mq-bnhost2.na.system1assethealth.bakerhughes.com
```

---

# 8. Regras de Firewall previstas

ACL prevista:

```cisco
access-list IDMZ-TA-MINA-IN remark FDC-7930 - Cordant Asset Health BEGIN


access-list IDMZ-TA-MINA-IN extended permit tcp object BENTELY-PREDITIVA_SRV object FQDN_CORDANT_AUTH_BNHOST2 eq 443


access-list IDMZ-TA-MINA-IN extended permit tcp object BENTELY-PREDITIVA_SRV object FQDN_CORDANT_APP_BNHOST2 eq 443


access-list IDMZ-TA-MINA-IN extended permit tcp object BENTELY-PREDITIVA_SRV object FQDN_CORDANT_MQ_BNHOST2 eq 20009


access-list IDMZ-TA-MINA-IN remark FDC-7930 - Cordant Asset Health END
```

---

# 9. Validação da porta de mensageria

Ponto crítico identificado.

O HLD indica comunicação AMQPS utilizando:

```
TCP 5671
```

O guia Cordant informa:

- AWS utiliza RabbitMQ.
- AMQPS normalmente utiliza TCP 5671.
- Ambientes SaaS/BH Cloud podem utilizar porta customizada.

A FDC solicita:

```
mq-bnhost2.na.system1assethealth.bakerhughes.com TCP/20009
```

Conclusão:

⚠️ Necessário obter confirmação formal da Baker Hughes/DevOps de que a porta TCP 20009 é a porta correta para este ambiente.

---

# 10. Testes recomendados no ASA

## Verificar resolução DNS

```cisco
ping auth-bnhost2.na.system1assethealth.bakerhughes.com

ping bnhost2.na.system1assethealth.bakerhughes.com

ping mq-bnhost2.na.system1assethealth.bakerhughes.com
```

Verificar DNS configurado:

```cisco
show running-config dns

show dns
```

---

## Validar rota

Após obter IP dos FQDNs:

```cisco
show route <IP_DESTINO>
```

---

## Simular o tráfego

```cisco
packet-tracer input <INTERFACE_OT> tcp 172.19.44.151 50000 <IP_DESTINO> 443 detailed
```

Verificar principalmente:

- ACL
- NAT
- Roteamento
- Interface de saída

Resultado esperado:

```
Result: ALLOW
```

---

# 11. Testes no servidor System 1

Após aplicação da mudança:

```powershell
Test-NetConnection auth-bnhost2.na.system1assethealth.bakerhughes.com -Port 443

Test-NetConnection bnhost2.na.system1assethealth.bakerhughes.com -Port 443

Test-NetConnection mq-bnhost2.na.system1assethealth.bakerhughes.com -Port 20009
```

---

# 12. Checklist de implementação

## Antes da RFC

- [x] HLD analisado.
- [x] Servidor origem identificado.
- [x] Destinos identificados.
- [x] Portas levantadas.
- [x] Running-config coletado.
- [x] Regras de firewall modeladas.
- [ ] Identificar NAT/PAT de saída.
- [ ] Confirmar ACL correta aplicada na interface.
- [ ] Confirmar porta TCP 20009 com Baker Hughes.
- [ ] Executar packet-tracer.
- [ ] Validar DNS no ASA.

---

## Durante a mudança

- [ ] Criar objetos FQDN.
- [ ] Aplicar ACL.
- [ ] Validar hitcount da ACL.
- [ ] Monitorar conexões.

Comandos:

```cisco
show access-list IDMZ-TA-MINA-IN

show conn address 172.19.44.151
```

---

## Após a mudança

- [ ] Testar conectividade no System 1.
- [ ] Coletar evidências.
- [ ] Salvar running-config depois da alteração.
- [ ] Atualizar documentação.

---

# 13. Evidências que devem permanecer na FDC

Arquivos recomendados:

```
HLD Online Predictive CKS.pdf

Cordant AH Connector Guide.pdf

ANTES-running-config ASA.txt

DEPOIS-running-config ASA.txt

Firewall Rule.xlsx

MOP da mudança

Logs de execução

Resultados dos testes
```

---

# 14. Lições aprendidas

Preencher após conclusão da RFC.

---

# 15. Histórico

| Data | Alteração | Responsável |
|---|---|---|
| 21/06/2026 | Criação da análise inicial do firewall | Jefferson |