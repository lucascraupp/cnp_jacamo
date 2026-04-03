cnp_timeout(5000).

!start.

+!start : services_needed(S) <-
    .print("Preciso dos serviços: ", S);
    .wait(2000);
    for (.member(Service, S)) {
        !!run_cnp(Service);
    }.

+!run_cnp(Service) <-
    .my_name(Me);
    .print("Buscando oficinas para: ", Service);
    .df_search(Service, Participants);
    .print("Oficinas encontradas para ", Service, ": ", Participants);
    if (Participants == []) {
        .print("Nenhuma oficina para ", Service);
    } else {
        .send(Participants, tell, cfp(Service, Me));
        ?cnp_timeout(Timeout);
        .wait(Timeout);
        !evaluate_proposals(Service);
    }.

// === FASE 2: Receber propostas ===

+propose(Service, Price)[source(Sender)] <-
    .print("Proposta de ", Sender, ": R$", Price, " (", Service, ")").

+refuse(Service, Reason)[source(Sender)] <-
    .print("Recusa de ", Sender, " para ", Service, ": ", Reason).

// === FASE 3: Avaliar propostas ===

+!evaluate_proposals(Service) <-
    .findall(prop(P, S), propose(Service, P)[source(S)], Props);
    if (Props == []) {
        .print("Nenhuma proposta para ", Service);
    } else {
        .sort(Props, Sorted);
        .nth(0, Sorted, prop(BestPrice, BestSender));
        .print("Vencedor para ", Service, ": ", BestSender, " com R$", BestPrice);
        .send(BestSender, tell, accept_proposal(Service));
        !reject_others(Service, Sorted, BestSender);
    }.

// === REJEITAR PERDEDORES ===

+!reject_others(_, [], _).

+!reject_others(Service, [prop(_, Sender) | Rest], Winner) : Sender \== Winner <-
    .send(Sender, tell, reject_proposal(Service));
    !reject_others(Service, Rest, Winner).

+!reject_others(Service, [prop(_, Winner) | Rest], Winner) <-
    !reject_others(Service, Rest, Winner).

// === FASE 5: Resultado ===

+done(Service, Result)[source(Sender)] <-
    .print("Servico ", Service, " concluido por ", Sender, ": ", Result).

+failure(Service, Reason)[source(Sender)] <-
    .print("Falha em ", Service, " por ", Sender, ": ", Reason).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
