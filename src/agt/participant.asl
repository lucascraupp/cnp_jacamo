active_tasks(0).

!start.

+!start : services_offered(S) <-
    .df_register(S);
    .print("Oficina aberta! Serviços oferecidos: ", S).

// Pode atender ao serviço e ainda tem capacidade para mais tarefas
+cfp(Service, Initiator)[source(Initiator)] :
    services_offered(Service) & capacity(Max) & active_tasks(N) & N < Max
<-
    !calculate_price(Service, Price);
    .send(Initiator, tell, propose(Service, Price));
    .print("Proposta enviada para ", Initiator, " com preço R$: ", Price).

// Não é o tipo de serviço ofertado
+cfp(Service, Initiator)[source(Initiator)] :
    services_offered(S) & Service \== S
<-
    .print("Solicitação ignorada, não trabalho com: ", Service).

// Já atingiu a capacidade máxima de tarefas
+cfp(Service, Initiator)[source(Initiator)] :
    services_offered(Service) & capacity(Max) & active_tasks(N) & N >= Max
<-
    .send(Initiator, tell, refuse(Service, "Capacidade máxima atingida"));
    .print("Recusa enviada para ", Initiator, " devido à capacidade máxima atingida.").

// Preço fixo
+!calculate_price(Service, Price) : strategy(fixed) & base_price(P) <-
    Price = P;
    .print("Preço calculado para ", Service, ", R$: ", Price).

// Preço baseado em quantos trabalhos ativos o agente tem (quanto mais trabalhos, mais caro)
+!calculate_price(Service, Price) : strategy(load) & base_price(P) & active_tasks(N) <-
    Price = P * (1 + N * 0.5);
    .print("Preço calculado para ", Service, ", R$: ", Price).

// Preço aleatório dentro de um intervalo baseado no preço base (entre 50% e 150% do preço base)
+!calculate_price(Service, Price) : strategy(random) & base_price(P) <-
    .random(R);
    Price = P * (0.5 + R);
    .print("Preço calculado para ", Service, ", R$: ", Price).

+accept_proposal(Service)[source(Initiator)] <-
    .print("Fui escolhido por ", Initiator, " para o serviço ", Service);
    ?active_tasks(N);
    -active_tasks(N);
    +active_tasks(N + 1);
    .wait(2000);
    .send(Initiator, tell, done(Service, "Serviço concluído"));
    ?active_tasks(N1);
    -active_tasks(N1);
    +active_tasks(N1 - 1);
    .print("Serviço ", Service, " concluído para ", Initiator).

+reject_proposal(Service)[source(Initiator)] <-
    .print("Proposta rejeitada para ", Service, " por ", Initiator).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
