active_tasks(0).

+!start : services_offered(S) <-
    .df_register(S);
    .print("Estande aberto! Artesanato oferecido: ", S).

// Pode atender ao serviço e ainda tem capacidade para mais encomendas
+cfp(Service, Initiator)[source(Initiator)] :
    services_offered(Service) & capacity(Max) & active_tasks(N) & N < Max
<-
    !calculate_price(Service, Price);
    .send(Initiator, tell, propose(Service, Price));
    .print("Proposta enviada para ", Initiator, " com preço R$: ", Price).

// Não é o tipo de artesanato ofertado
+cfp(Service, Initiator)[source(Initiator)] :
    services_offered(S) & Service \== S
<-
    .print("Solicitação ignorada, não trabalho com: ", Service).

// Já atingiu a capacidade máxima de encomendas
+cfp(Service, Initiator)[source(Initiator)] :
    services_offered(Service) & capacity(Max) & active_tasks(N) & N >= Max
<-
    .send(Initiator, tell, refuse(Service, "Capacidade máxima atingida"));
    .print("Recusa enviada para ", Initiator, " devido à capacidade máxima atingida.").

// Preço fixo
+!calculate_price(Service, Price) : strategy(fixed) & base_price(P) <-
    Price = P;
    .print("Preço calculado para ", Service, ", R$: ", Price).

// Preço baseado em quantas encomendas ativas o artesão tem (quanto mais encomendas, mais caro)
+!calculate_price(Service, Price) : strategy(load) & base_price(P) & active_tasks(N) <-
    Price = P * (1 + N * 0.5);
    .print("Preço calculado para ", Service, ", R$: ", Price).

// Preço aleatório dentro de um intervalo baseado no preço base (entre 50% e 150% do preço base)
+!calculate_price(Service, Price) : strategy(random) & base_price(P) <-
    .random(R);
    Price = P * (0.5 + R);
    .print("Preço calculado para ", Service, ", R$: ", Price).

+accept_proposal(Service)[source(Initiator)] <-
    .print("Fui escolhido por ", Initiator, " para ", Service);
    !inc_tasks;
    .wait(2000);
    .send(Initiator, tell, done(Service, "Encomenda concluída"));
    !dec_tasks;
    .print("Encomenda de ", Service, " concluída para ", Initiator).

@inc[atomic]
+!inc_tasks <-
    ?active_tasks(N);
    -active_tasks(N);
    +active_tasks(N + 1).

@dec[atomic]
+!dec_tasks <-
    ?active_tasks(N);
    -active_tasks(N);
    +active_tasks(N - 1).

+reject_proposal(Service)[source(Initiator)] <-
    .print("Proposta rejeitada para ", Service, " por ", Initiator).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
