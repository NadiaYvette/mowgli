%---------------------------------------------------------------------------%
% plp.m — a tiny probabilistic logic programming core in Mercury.
%
% Semantics: Sato's distribution semantics. A program is a set of
% probabilistic facts (prob/2), always-true facts (det/1), and
% definite-clause rules. Each probabilistic fact is an independent
% boolean random variable; a *world* is a truth assignment to all of
% them. The query holds in a world iff it is in the minimal model of
% that world (the closure of the true facts under the rules). The
% marginal is the total probability mass of the worlds where the query
% holds.
%
% Two engines:
%
%   1. `marginal/2` — exact, by enumerating all 2^n worlds. This is the
%      gold standard; exponential, but unambiguous.
%
%   2. `explanations/3` + `combine_explanations/3` — the proof algebra.
%      Each minimal explanation is a set of probabilistic facts whose
%      closure entails the query; `combine_explanations` folds a semiring
%      (see semiring.m) over their weights:
%        float   — sum of weights. This is a *union bound*: it
%                  overcounts when explanations overlap, so it is an
%                  upper bound on the marginal. Exactness needs BDD-style
%                  disjoint-sum, which is the classic PLP hard part.
%        maxplus — most-likely explanation (Viterbi).
%        minplus — cheapest explanation.
%        bool    — plain logical entailment.
%---------------------------------------------------------------------------%

:- module plp.

:- interface.

:- import_module float.
:- import_module list.
:- import_module pair.
:- import_module semiring.
:- import_module set.
:- import_module string.

:- type fact
    --->    prob(string, float)          % atom, probability
    ;       det(string).                 % always-true atom

:- type clause
    --->    clause(string, list(string)).  % head :- body atoms

:- type program
    --->    program(list(fact), list(clause)).

:- func program_facts(program) = list(fact).
:- func program_rules(program) = list(clause).

    % The probabilistic facts as (atom, weight) pairs.
:- func prob_facts(program) = list(pair(string, float)).

    % The names of the always-true atoms.
:- func det_atoms(program) = set(string).

    % The names of the probabilistic atoms.
:- func prob_names(program) = list(string).

    % Minimal model of the program given a set of extra true atoms
    % (the selected probabilistic facts). Deterministic facts are
    % always included.
:- func closure(program, set(string)) = set(string).

    % Exact marginal: total probability mass of the worlds where the
    % query holds. Enumerates all 2^n worlds.
:- func marginal(program, string) = float.

    % All minimal sets of probabilistic facts that entail the query.
:- pred explanations(program::in, string::in, list(set(string))::out) is det.

    % Fold the semiring over the explanation weights.
:- pred combine_explanations(program::in, list(set(string))::in, T::out)
    is det <= semiring(T).

:- implementation.

:- import_module map.

program_facts(program(F, _)) = F.
program_rules(program(_, R)) = R.

:- pred prob_fact_opt(fact::in, pair(string, float)::out) is semidet.
prob_fact_opt(prob(A, P), A - P).

:- pred det_atom_opt(fact::in, string::out) is semidet.
det_atom_opt(det(A), A).

prob_facts(program(Facts, _)) = Pairs :-
    list.filter_map(prob_fact_opt, Facts, Pairs).

det_atoms(program(Facts, _)) = set.from_list(Det) :-
    list.filter_map(det_atom_opt, Facts, Det).

prob_names(program(Facts, _)) = Names :-
    list.filter_map(
        (pred(F::in, A::out) is semidet :- F = prob(A, _)),
        Facts, Names).

%----- minimal model -----%

closure(Prog, Extra) =
    close(program_rules(Prog), set.union(Extra, det_atoms(Prog))).

:- func close(list(clause), set(string)) = set(string).
close(Rules, True0) = True :-
    list.filter_map(
        (pred(C::in, H::out) is semidet :-
            C = clause(H, B),
            all_in(B, True0)
        ),
        Rules, New),
    True1 = list.foldl((func(Atom, S) = set.insert(S, Atom)), New, True0),
    ( if True1 = True0 then
        True = True0
      else
        True = close(Rules, True1)
    ).

:- pred all_in(list(string)::in, set(string)::in) is semidet.
all_in([], _).
all_in([A | As], S) :-
    set.member(A, S),
    all_in(As, S).

%----- exact marginal via possible worlds -----%

marginal(Prog, Query) = sum_worlds(prob_facts(Prog), Prog, Query, set.init).

:- func sum_worlds(list(pair(string, float)), program, string,
    set(string)) = float.
sum_worlds([], Prog, Query, True) =
    ( if set.member(Query, closure(Prog, True)) then 1.0 else 0.0 ).
sum_worlds([A - P | Rest], Prog, Query, True) =
    sum_worlds(Rest, Prog, Query, set.insert(True, A)) * P
    + sum_worlds(Rest, Prog, Query, True) * (1.0 - P).

%----- explanations -----%

explanations(Prog, Query, Exps) :-
    Subsets = entailing_subsets(prob_names(Prog), Prog, Query, set.init),
    Exps = minimize(Subsets).

:- func entailing_subsets(list(string), program, string, set(string))
    = list(set(string)).
entailing_subsets([], Prog, Query, Selected) =
    ( if set.member(Query, closure(Prog, Selected)) then
        [set.difference(Selected, det_atoms(Prog))]
      else
        []
    ).
entailing_subsets([Name | Names], Prog, Query, Selected) =
    entailing_subsets(Names, Prog, Query, set.insert(Selected, Name)) ++
    entailing_subsets(Names, Prog, Query, Selected).

:- func minimize(list(set(string))) = list(set(string)).
minimize(Subsets) = list.filter(
    (pred(S::in) is semidet :- not has_proper_subset(S, Subsets)),
    Subsets).

:- pred has_proper_subset(set(string)::in, list(set(string))::in) is semidet.
has_proper_subset(S, L) :-
    list.member(S2, L),
    S2 \= S,
    set.subset(S2, S).

%----- semiring fold over explanations -----%

combine_explanations(Prog, Exps, V) :-
    M = prob_map(Prog),
    Weights = list.map((func(E) = exp_weight(M, E)), Exps),
    V = list.foldl((func(A, B) = add(A, B)), Weights, zero).

:- func prob_map(program) = map(string, float).
prob_map(program(Facts, _)) = M :-
    list.foldl(add_pair, Facts, map.init, M).

:- pred add_pair(fact::in, map(string, float)::in, map(string, float)::out)
    is det.
add_pair(prob(A, P), !M) :-
    map.set(A, P, !.M, !:M).
add_pair(det(_), !M).

:- func exp_weight(map(string, float), set(string)) = T <= semiring(T).
exp_weight(M, Exp) = list.foldl(
    (func(Atom, Acc) = mul(Acc, atom_weight(M, Atom))),
    set.to_sorted_list(Exp),
    one).

:- func atom_weight(map(string, float), string) = T <= semiring(T).
atom_weight(M, Atom) =
    ( if map.search(M, Atom, P) then from_float(P) else one ).

:- end_module plp.
