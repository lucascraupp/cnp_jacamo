# Contract Net Protocol em JaCaMo

Implementação do Contract Net Protocol (CNP) usando JaCaMo, simulando uma feira de artesãos. Visitantes percorrem a feira buscando orçamentos para peças customizadas de queijo, bebidas, madeira, ferragem e cerâmica, negociando com artesãos que competem pelo menor preço.

## Estrutura

- [`cnp.jcm`](cnp.jcm) — configuração do sistema multi-agente (agentes e crenças iniciais)
- [`initiator.asl`](src/agt/initiator.asl) — agente visitante (initiator do CNP)
- [`participant.asl`](src/agt/participant.asl) — agente artesão (participant do CNP)

## Funcionamento

### Initiator (visitante)

1. Busca no Directory Facilitator os artesãos que oferecem cada serviço que precisa
2. Envia um CFP (Call for Proposals) para os artesãos encontrados, executando múltiplos CNPs em paralelo
3. Aguarda propostas por um tempo limite (timeout)
4. Seleciona a proposta de menor preço e notifica o vencedor (accept) e os demais (reject)
5. Aguarda a conclusão da encomenda

### Participant (artesão)

1. Registra-se no Directory Facilitator com o tipo de artesanato que oferece
2. Ao receber um CFP, calcula o preço conforme sua estratégia e envia a proposta. Se estiver com capacidade máxima, recusa
3. Se for aceito, executa a encomenda e reporta a conclusão

### Estratégias de preço

| Estratégia | Comportamento |
|------------|---------------|
| `fixed`    | Preço fixo igual ao `base_price` |
| `random`   | Preço aleatório entre 50% e 150% do `base_price` |
| `load`     | Preço aumenta 50% por encomenda ativa |

## Configuração

Os agentes são definidos no `cnp.jcm`. Para adicionar visitantes ou artesãos, basta declarar novos agentes com suas crenças iniciais:

```
agent visitor1 : initiator.asl {
    beliefs: services_needed([queijo, madeira])
}

agent artisan1 : participant.asl {
    beliefs: services_offered(queijo)
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

## Inspeção dos agentes

Com o sistema em execução, é possível inspecionar o estado dos agentes pelo navegador:

- `http://localhost:3272` — Mind Inspector (crenças, planos e intenções de cada agente)
- `http://localhost:3273` — CArtAgO (artefatos do ambiente)
