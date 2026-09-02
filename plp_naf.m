%---------------------------------------------------------------------------%
% plp_naf.m — negation-as-failure (NAF) for the PLP core, via *stratified*
% evaluation.
%
% Why stratified, and why it matters:
%
%   The naive way to add NAF — "a clause fires if its negated body atoms
%   are not currently true; iterate to a fixpoint" — is WRONG. Example:
%
%       wet :- rain.   wet :- sprinkler.   dry :- not wet.
%
%   Start with {rain, sprinkler} true. Round 1 fires wet (good) but ALSO
%   fires dry (wet not yet in the set). Once wet enters, dry should be
%   retracted — but fixpoint iteration from below can't retract. You get
%   {wet, dry}, which is wrong: wet is true, so dry must be false.
%
%   The fix is stratification: order the atoms so that every negated atom
%   is decided in a *strictly lower* stratum before the stratum that uses
%   it. Then within a stratum the operator is monotone and the least
%   fixpoint is correct.
%
%       stratum 0: rain, sprinkler, wet     (no negation)
%       stratum 1: dry                      (uses not wet — stratum 0)
%
%   Evaluate bottom-up. This computes the perfect model for stratified
%   programs, which is what PRISM/ProbLog-style PLP systems assume.
%   Programs that cannot be stratified (a negation cycle, e.g.
%   `p :- not q. q :- not p.`) are rejected with an error.
%
% Semantics for marginals: same distribution semantics as plp.m — each
% world picks truth values for the probabilistic facts, and the query
% holds iff it is in the perfect model of that world.
%---------------------------------------------------------------------------%

:- module plp_naf.

:- interface.

:- import_module float.
:- import_module list.
:- import_module set.
:- import_module string.

:- import_module plp.

    % A body literal: pos(A) or neg(A).
:- type literal
    --->    pos(string)
    ;       neg(string).

:- type naf_clause
    --->    naf_clause(string, list(literal)).

:- type naf_program
    --->    naf_program(list(fact), list(naf_clause)).

    % The perfect model of the program given the atoms in Extra are true
    % (the selected probabilistic facts of the current world).
    % Throws `error` if the program is not stratified.
:- func model(naf_program, set(string)) = set(string).

    % Marginal probability of the query, over all possible worlds.
:- func marginal(naf_program, string) = float.

:- implementation.

:- import_module map.
:- import_module maybe.
:- import_module pair.
:- import_module require.

%----- model: stratified evaluation -----%

model(naf_program(Facts, Clauses), Extra) = M :-
    True0 = set.union(det_atoms(program(Facts, [])), Extra),
    M = eval_strata(ordered_strata(Clauses), Clauses, True0).

%----- stratification -----%

    % All atoms mentioned anywhere in the program.
:- func all_atoms(list(naf_clause)) = list(string).
all_atoms(Clauses) = set.to_sorted_list(set.from_list(list.condense(
    list.map(clause_atoms, Clauses)))).

:- func clause_atoms(naf_clause) = list(string).
clause_atoms(naf_clause(H, Body)) = [H | As] :-
    list.filter_map(
        (pred(L::in, A::out) is semidet :-
            ( L = pos(A) ; L = neg(A) )
        ),
        Body, As).

    % Positive dependencies: clause head -> each pos body atom.
:- func pos_deps(list(naf_clause)) = map(string, set(string)).
pos_deps(Clauses) = M :-
    list.foldl(add_pos_deps, Clauses, map.init, M).

:- pred add_pos_deps(naf_clause::in, map(string, set(string))::in,
    map(string, set(string))::out) is det.
add_pos_deps(naf_clause(H, Body), !M) :-
    list.filter_map(
        (pred(L::in, A::out) is semidet :- L = pos(A)), Body, Pos),
    ( if map.search(!.M, H, Old) then
        map.set(H, set.union(Old, set.from_list(Pos)), !M)
      else
        map.set(H, set.from_list(Pos), !M)
    ).

    % Negation constraints: (After, Before) — After's stratum must be
    % strictly above Before's. One per neg body atom.
:- func neg_constraints(list(naf_clause), list(string),
    map(string, set(string))) = list(pair(set(string), set(string))).
neg_constraints(Clauses, Atoms, Deps) = list.condense(
    list.map(constraints_of_clause(Atoms, Deps), Clauses)).

:- func constraints_of_clause(list(string), map(string, set(string)),
    naf_clause) = list(pair(set(string), set(string))).
constraints_of_clause(Atoms, Deps, naf_clause(H, Body)) = Cons :-
    list.filter_map(
        (pred(L::in, A::out) is semidet :- L = neg(A)), Body, Negs),
    Cons = list.map(
        (func(B) = scc_of(H, Atoms, Deps) - scc_of(B, Atoms, Deps)),
        Negs).

    % SCCs of the positive-dependency graph, in dependency order
    % (each SCC after the ones it positively depends on — approximated by
    % a topological order that also respects the negation constraints).
:- func ordered_strata(list(naf_clause)) = list(set(string)).
ordered_strata(Clauses) = Order :-
    Atoms = all_atoms(Clauses),
    Deps = pos_deps(Clauses),
    Sccs = collect_sccs(Atoms, Atoms, Deps, []),
    Constraints = neg_constraints(Clauses, Atoms, Deps),
    Order = topo_order(Sccs, Constraints).

%----- SCCs (positive dependencies) -----%

    % Everything reachable from A via positive edges, including A.
:- func reachable(string, map(string, set(string))) = set(string).
reachable(A, Deps) = reach_fix(A, Deps, set.make_singleton_set(A)).

:- func reach_fix(string, map(string, set(string)), set(string)) = set(string).
reach_fix(A, Deps, Acc0) = R :-
    Succ = ( if map.search(Deps, A, S) then S else set.init ),
    New = set.difference(Succ, Acc0),
    Acc1 = set.union(Acc0, Succ),
    ( if set.is_empty(New) then
        R = Acc1
      else
        R = set.fold((func(N, A2) = reach_fix(N, Deps, A2)), New, Acc1)
    ).

    % The SCC of A: atoms mutually reachable with A.
:- func scc_of(string, list(string), map(string, set(string))) = set(string).
scc_of(A, Atoms, Deps) = set.from_list(Ys) :-
    list.filter_map(
        (pred(B::in, B::out) is semidet :-
            set.member(A, reachable(B, Deps)),
            set.member(B, reachable(A, Deps))
        ), Atoms, Ys).

:- func collect_sccs(list(string), list(string), map(string, set(string)),
    list(set(string))) = list(set(string)).
collect_sccs([], _, _, Acc) = list.reverse(Acc).
collect_sccs([A | As], Atoms, Deps, Acc) = Result :-
    S = scc_of(A, Atoms, Deps),
    ( if list.member(S, Acc) then
        Result = collect_sccs(As, Atoms, Deps, Acc)
      else
        Result = collect_sccs(As, Atoms, Deps, [S | Acc])
    ).

%----- topological order (respecting negation constraints) -----%

:- func topo_order(list(set(string)), list(pair(set(string), set(string))))
    = list(set(string)).
topo_order(Items, Constraints) = Order :-
    ( if topo_loop(Items, Constraints, set.init, [], Order0) then
        Order = Order0
      else
        require.error("plp_naf: program is not stratified (negation cycle)")
    ).

    % Fails if no SCC is ready (a negation cycle).
:- pred topo_loop(list(set(string))::in,
    list(pair(set(string), set(string)))::in, set(set(string))::in,
    list(set(string))::in, list(set(string))::out) is semidet.
topo_loop([], _, _, Acc, Order) :-
    Order = list.reverse(Acc).
topo_loop([I | Is], Constraints, Emitted, Acc, Order) :-
    Items = [I | Is],
    pick_ready(Items, Constraints, Emitted) = yes(R),
    topo_loop(list.delete_all(Items, R), Constraints,
        set.insert(Emitted, R), [R | Acc], Order).

    % The first SCC with all its prerequisites already emitted, if any.
:- func pick_ready(list(set(string)), list(pair(set(string), set(string))),
    set(set(string))) = maybe(set(string)).
pick_ready([], _, _) = no.
pick_ready([I | Is], Constraints, Emitted) =
    ( if ready(I, Constraints, Emitted) then
        yes(I)
      else
        pick_ready(Is, Constraints, Emitted)
    ).

    % I is ready iff every SCC it must come after is already emitted.
:- pred ready(set(string)::in, list(pair(set(string), set(string)))::in,
    set(set(string))::in) is semidet.
ready(I, Constraints, Emitted) :-
    list.all_true((pred(C::in) is semidet :-
        ( if C = I - Before then
            set.member(Before, Emitted)
          else
            true
        )), Constraints).

%----- evaluation -----%

:- func eval_strata(list(set(string)), list(naf_clause), set(string))
    = set(string).
eval_strata([], _, True) = True.
eval_strata([S | Ss], Clauses, True0) = True :-
    True1 = eval_scc(S, Clauses, True0),
    True = eval_strata(Ss, Clauses, True1).

    % Within one stratum, iterate firing to the least fixpoint. All neg
    % body atoms refer to strictly lower strata (already fixed), so this
    % is monotone and correct.
:- func eval_scc(set(string), list(naf_clause), set(string)) = set(string).
eval_scc(SCC, Clauses, True0) = True :-
    NewHeads = fired_in_scc(SCC, Clauses, True0),
    True1 = set.union(True0, set.from_list(NewHeads)),
    ( if True1 = True0 then
        True = True0
      else
        True = eval_scc(SCC, Clauses, True1)
    ).

:- func fired_in_scc(set(string), list(naf_clause), set(string))
    = list(string).
fired_in_scc(SCC, Clauses, True) = Heads :-
    list.filter_map(
        (pred(C::in, H::out) is semidet :-
            C = naf_clause(H, Body),
            set.member(H, SCC),
            satisfied(Body, True)
        ),
        Clauses, Heads).

:- pred satisfied(list(literal)::in, set(string)::in) is semidet.
satisfied([], _).
satisfied([pos(A) | Ls], True) :-
    set.member(A, True),
    satisfied(Ls, True).
satisfied([neg(A) | Ls], True) :-
    not set.member(A, True),
    satisfied(Ls, True).

%----- marginal over possible worlds -----%

marginal(naf_program(Facts, Clauses), Query) = P :-
    NP = naf_program(Facts, Clauses),
    P = sum_worlds(prob_facts(program(Facts, [])), NP, Query, set.init).

:- func sum_worlds(list(pair(string, float)), naf_program, string,
    set(string)) = float.
sum_worlds([], NP, Query, True) =
    ( if set.member(Query, model(NP, True)) then 1.0 else 0.0 ).
sum_worlds([A - P | Rest], NP, Query, True) =
    sum_worlds(Rest, NP, Query, set.insert(True, A)) * P
    + sum_worlds(Rest, NP, Query, True) * (1.0 - P).

:- end_module plp_naf.
