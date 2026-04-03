# Contract Net Protocol em JaCaMo

Implementação do Contract Net Protocol (CNP) usando JaCaMo, simulando clientes que precisam de serviços automotivos e oficinas mecânicas que oferecem orçamentos.

## Estrutura

- [`cnp.jcm`](cnp.jcm) — configuração do sistema multi-agente (agentes e crenças iniciais)
- [`initiator.asl`](src/agt/initiator.asl) — agente cliente (initiator do CNP)
- [`participant.asl`](src/agt/participant.asl) — agente oficina (participant do CNP)

## Funcionamento

### Initiator (cliente)

1. Busca no Directory Facilitator as oficinas que oferecem cada serviço que precisa
2. Envia um CFP (Call for Proposals) para as oficinas encontradas, executando múltiplos CNPs em paralelo
3. Aguarda propostas por um tempo limite (timeout)
4. Seleciona a proposta de menor preço e notifica o vencedor (accept) e os demais (reject)
5. Aguarda a conclusão do serviço

### Participant (oficina)

1. Registra-se no Directory Facilitator com o tipo de serviço que oferece
2. Ao receber um CFP, calcula o preço conforme sua estratégia e envia a proposta. Se estiver com capacidade máxima, recusa
3. Se for aceito, executa o serviço e reporta a conclusão

### Estratégias de preço

| Estratégia | Comportamento |
|------------|---------------|
| `fixed`    | Preço fixo igual ao `base_price` |
| `random`   | Preço aleatório entre 50% e 150% do `base_price` |
| `load`     | Preço aumenta 50% por tarefa ativa |

## Configuração

Os agentes são definidos no `cnp.jcm`. Para adicionar clientes ou oficinas, basta declarar novos agentes com suas crenças iniciais:

```
agent name : initiator.asl {
    beliefs: services_needed([servico1, servico2])
}

agent name : participant.asl {
    beliefs: services_offered(servico)
             strategy(fixed)
             base_price(100)
             capacity(3)
}
```

## Execução

Requer Java 17+ instalado.

```
./gradlew
```
