cnp_timeout(5000).

!start.

+!start : desired_initiators(N) & desired_participants(M) <-
    .print(N, " initiators and ", M, " participants are needed");

    !start_initiators(N);
    .print("All initiators started, now starting participants...");

    !start_participants(M);
    .print("All participants started, the market is open!");
    .broadcast(achieve, start).

// Starts all initiators with random needed services
+!start_initiators(IN) : IN > 0 <-
    !start_initiators(IN-1);

    // Create a unique name for the initiator & create the agent
    .concat("visitor", IN, Name);
    .create_agent(Name, "initiator.asl");

    // Get a random subset of services needed & send it to the agent
    !gen_needed_services(S);
    .send(Name, tell, services_needed(S));

    .print("Initiator visitor", IN, " created with: ", S).

+!start_initiators(0).


// Starts all participants with random offered services, strategies, base prices and capacities
+!start_participants(IM) : IM > 0 <-
    !start_participants(IM-1);

    // Create a unique name for the initiator & create the agent
    .concat("artesan", IM, Name);
    .create_agent(Name, "participant.asl");

    // Get random strategy & send it to the agent
    !pick_one([load,fixed,random], Strategy);
    .send(Name, tell, strategy(Strategy));

    // Get a random service to offer & send it to the agent
    ?services(Catalog);
    !pick_one(Catalog, Service);
    .send(Name, tell, services_offered(Service));

    // Get a random base price & send it to the agent
    BasePrice = 100 + math.floor(math.random(401));
    .send(Name, tell, base_price(BasePrice));

    // Get a random capacity & send it to the agent
    Capacity = 1 + math.floor(math.random(10));
    .send(Name, tell, capacity(Capacity));
    
    .print("Participant artesan", IM, " created with: \n Service ", Service, ", \n Strategy ", Strategy, ", \n BasePrice ", BasePrice, ", \n Capacity ", Capacity).

+!start_participants(0).


// Utility: Pick a list of services from catalog
+!gen_needed_services(Result) <-
    // From the cataloged services
    ?services(Catalog);
    // Pick a random subset of them (could be empty, but that's ok)
    !pick_subset(Catalog, [], Temp);
    .length(Temp, Size);
    // If the subset is empty
    if (Size > 0) {
        Result = Temp
    } else {
        // Pick one random service to ensure the initiator needs at least one service
        !pick_one(Catalog, One);
        Result = [One]
    }.


// Utility: Pick a random subset of a list
+!pick_subset([H|T], Acc, Result) <-
    .random(R);
    if (R > 0.5) {
        !pick_subset(T, [H|Acc], Result)
    } else {
        !pick_subset(T, Acc, Result)
    }.

// Utility: If list is empty, return the accumulated result
+!pick_subset([], Acc, Acc).


// Utility: Pick a random element from a list
+!pick_one(List, Elem) <-
    .length(List, N);
    Index = math.floor(math.random(N));
    // Get element at Index
    !nth0(Index, List, Elem).

// Utility: If the Index is 0, return the first element
+!nth0(0, [Head|_], Head).

// Utility: If the first element is not the one we want, keep looking in the tail
+!nth0(Index, [_|Tail], Elem) : Index > 0 <-
    !nth0(Index-1, Tail, Elem).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }