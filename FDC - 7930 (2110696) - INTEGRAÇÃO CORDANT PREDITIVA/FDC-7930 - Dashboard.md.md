# FDC-7930 - Integração Cordant Preditiva

## Status
🟡 Em análise

---

## Informações da demanda

| Item | Valor |
|---|---|
| Solicitante | George Bueno |
| Área | Manutenção Preditiva |
| Tipo | OT |
| Arquiteto | Claudio Dal Col |
| Tecnologia | Netscaler / Load Balance |
| Sistema | System 1 → Cordant Asset Health |

---

## Objetivo

Integrar o servidor Preditiva Online com a plataforma
Cordant Asset Health da Baker Hughes para análise
de vibração e variáveis de processo.

---

## Fluxo da comunicação

Origem:
172.19.44.151

Destino:
- auth-bnhost2.na.system1assethealth.bakerhughes.com TCP/443
- bnhost2.na.system1assethealth.bakerhughes.com TCP/443
- mq-bnhost2.na.system1assethealth.bakerhughes.com TCP/20009


Sentido:
OT Vale → Cloud Baker Hughes


---

## Pontos críticos

- [ ] Confirmar se a porta TCP 20009 é realmente necessária
- [ ] Validar se existe necessidade da TCP 5671
- [ ] Confirmar se a regra será por FQDN
- [ ] Validar necessidade de Proxy
- [ ] Confirmar servidor de origem


---

## HLD

Local:
05 - OUTROS DOCUMENTOS

Referência:
Online Predictive CKS - Carajás


---

## RFC

Número:
CHGxxxxx

Status:
Não aberta


---

## MOP

Status:
Não criado


---

## Testes de conectividade

```powershell
Test-NetConnection auth-bnhost2.na.system1assethealth.bakerhughes.com -Port 443

Test-NetConnection mq-bnhost2.na.system1assethealth.bakerhughes.com -Port 20009


## Evidências

- [ ]  Print dos testes
- [ ]  Aprovação da arquitetura
- [ ]  Aprovação do cliente
- [ ]  Logs da execução

---

## Lições aprendidas

### Problema

### Causa

### Solução

### Como evitar futuramente

---

## Histórico da demanda

20/06/2026:

- Criada análise inicial da FDC.
- HLD avaliado.
- Identificada divergência de porta 20009 x 5671.