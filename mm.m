%---------------------------------------------------------------------------%
% mm.m — multimodal Kripke structures with indexed accessibility relations.
%
% Classical modal logic has one accessibility relation R: "necessarily p"
% (box p) means p holds at every world R-reachable from the current one.
% Multimodal logic has *indexed* relations R_1, R_2, ..., R_n:
%   box_i p   means p holds at every R_i-reachable world
%   dia_i p   means p holds at some R_i-reachable world
%
% This is the standard framework for reasoning about multiple agents
% (epistemic logic), multiple dimensions of necessity (alethic + temporal),
% or any situation where "accessible from here" means different things
% under different relations.
%
% The modalities interact through *axiom schemas* on the relations:
%   K axiom  (distributivity): always holds — the basic modal frame
%   T  (reflexivity):  R_i is reflexive    -> box_i p -> p  (factive)
%   4  (transitivity): R_i is transitive   -> box_i p -> box_i box_i
%   5  (symmetry):     R_i is symmetric    -> p -> box_i dia_i p
%
% S5 = K + T + 4 + 5: R_i is an equivalence relation. Every S5 modality
% partitions the worlds into equivalence classes; box_i p holds exactly
% when p holds throughout the current class.
%
% The model checker sat(K, F) computes the set of worlds satisfying F,
% using recursive evaluation over modal depth. Since the Kripke
% structure is finite, this terminates.
%
% This module is *pure* multimodal — no weights, no probabilities.
% See mmb.m for the merge with probability distributions.
%---------------------------------------------------------------------------%

:- module mm.

:- interface.

:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module set.
:- import_module string.

    % A multimodal Kripke structure: worlds, labelling, and a map from
    % modality index to accessibility relation (list of successors per
    % world under that modality).
:- type kripke_m
    --->    kripke_m(
                states      :: set(string),
                labels      :: map(string, list(string)),
                rels        :: map(string, map(string, list(string)))
                %           ^ modality_id -> (world -> successors)
            ).

    % Multimodal formulas.
:- type mmf
    --->    prop(string)           % atomic proposition
    ;       neg(mmf)              % negation
    ;       conj(mmf, mmf)        % conjunction
    ;       disj(mmf, mmf)        % disjunction
    ;       imp(mmf, mmf)         % implication
    ;       box(string, mmf)      % box_i f  — necessarily f under modality i
    ;       dia(string, mmf).     % dia_i f  — possibly f under modality i

    % The set of worlds satisfying the formula.
:- func sat(kripke_m, mmf) = set(string).

    % Helpers to build a multimodal Kripke structure.
:- func mk_kripke(set(string), map(string, list(string)),
        list(pair(string, pair(string, list(string))))) = kripke_m.
    % mk_kripke(States, Labels, Rels)
    % Rels is a list of (modality_id, (world, successors)) pairs.

:- implementation.

%----- model checker -----%

sat(K, prop(P)) = states_in(K, (pred(S::in) is semidet :-
    list.member(P, label_of(K, S)))).

sat(K, neg(F)) = set.difference(K ^ states, sat(K, F)).

sat(K, conj(F1, F2)) = set.intersect(sat(K, F1), sat(K, F2)).

sat(K, disj(F1, F2)) = set.union(sat(K, F1), sat(K, F2)).

sat(K, imp(F1, F2)) = sat(K, disj(neg(F1), F2)).

sat(K, box(M, F)) = states_in(K, (pred(S::in) is semidet :-
    all_sat(K, F, reachable(K, M, S)))).

sat(K, dia(M, F)) = states_in(K, (pred(S::in) is semidet :-
    some_reachable_sat(K, F, reachable(K, M, S)))).

%----- helpers -----%

    % Worlds reachable from S under modality M.
:- func reachable(kripke_m, string, string) = list(string).
reachable(K, M, S) = R :-
    ( if map.search(K ^ rels, M, RelMap),
      map.search(RelMap, S, R0)
    then
        R = R0
    else
        R = []
    ).

    % All of Rels satisfy F.
:- pred all_sat(kripke_m::in, mmf::in, list(string)::in) is semidet.
all_sat(_, _, []).
all_sat(K, F, [W | Ws]) :-
    set.member(W, sat(K, F)),
    all_sat(K, F, Ws).

    % Some element of Rels satisfies F.
:- pred some_reachable_sat(kripke_m::in, mmf::in, list(string)::in) is semidet.
some_reachable_sat(K, F, [W | _]) :-
    set.member(W, sat(K, F)).
some_reachable_sat(K, F, [_ | Ws]) :-
    some_reachable_sat(K, F, Ws).

    % All states satisfying the condition.
:- func states_in(kripke_m, pred(string)) = set(string).
:- mode states_in(in, in(pred(in) is semidet)) = out is det.
states_in(K, Cond) = set.from_list(
    list.filter(Cond, set.to_sorted_list(K ^ states))).

:- func label_of(kripke_m, string) = list(string).
label_of(K, S) = ( if map.search(K ^ labels, S, L) then L else [] ).

%----- construction helper -----%

mk_kripke(States, Labels, RelPairs) = kripke_m(States, Labels, Rels) :-
    % Group (modality, (world, succs)) pairs into
    % map(modality, map(world, succs)).
    EmptyRels = (map.init : map(string, map(string, list(string)))),
    build_rels(RelPairs, EmptyRels, Rels).

:- pred build_rels(list(pair(string, pair(string, list(string))))::in,
    map(string, map(string, list(string)))::in,
    map(string, map(string, list(string)))::out) is det.
build_rels([], !Rels).
build_rels([Pair | Rest], !Rels) :-
    M = Pair ^ fst,
    WorldSuccs = Pair ^ snd,
    World = WorldSuccs ^ fst,
    Succs = WorldSuccs ^ snd,
    ( if map.search(!.Rels, M, InnerMap0) then
        InnerMap = map.set(InnerMap0, World, Succs)
      else
        InnerMap = map.singleton(World, Succs)
    ),
    !:Rels = map.set(!.Rels, M, InnerMap),
    build_rels(Rest, !Rels).

:- end_module mm.
