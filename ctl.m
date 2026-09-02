%---------------------------------------------------------------------------%
% ctl.m — a CTL model checker in Mercury.
%
% Formulas are *data*; sat(K, F) computes the set of states of Kripke
% structure K that satisfy formula F. The temporal operators are
% evaluated as fixpoints over the lattice of state-sets:
%
%   EF f = lfp Z. f | EX Z          EG f = gfp Z. f & EX Z
%   AF f = lfp Z. f | AX Z          AG f = gfp Z. f & AX Z
%   E[f U g] = lfp Z. g | (f & EX Z)
%   A[f U g] = lfp Z. g | (f & AX Z)
%
% where EX Z = { s | some successor of s is in Z } and
%       AX Z = { s | all successors of s are in Z }.
%
% Because the Kripke structure is finite, the monotone iteration
% terminates: least fixpoints grow from the empty set, greatest
% fixpoints shrink from the full state set. This is the standard
% textbook CTL model-checking algorithm (Clarke–Emerson–Sistla).
%
% Mercury's determinism checker pays off here: `sat/2` is det, the
% one-step transformers are det functions, and the only "search" in
% the whole checker is the existential `some [T] (...)` inside EX —
% which Mercury forces you to make explicit.
%---------------------------------------------------------------------------%

:- module ctl.

:- interface.

:- import_module list.
:- import_module map.
:- import_module set.
:- import_module string.

    % A Kripke structure: states, a labelling (which atomic props hold
    % in each state), and a transition relation (successors of each
    % state). Strings stand for both states and atomic propositions —
    % a sketch, not a security boundary.
:- type kripke
    --->    kripke(
                states  :: set(string),
                labels  :: map(string, list(string)),
                succs   :: map(string, list(string))
            ).

    % CTL formulas.
:- type ctl
    --->    prop(string)
    ;       neg(ctl)
    ;       conj(ctl, ctl)
    ;       disj(ctl, ctl)
    ;       ex(ctl)
    ;       ax(ctl)
    ;       ef(ctl)
    ;       af(ctl)
    ;       eg(ctl)
    ;       ag(ctl)
    ;       eu(ctl, ctl)
    ;       au(ctl, ctl).

    % The set of states satisfying the formula.
:- func sat(kripke, ctl) = set(string).

:- implementation.

sat(K, prop(P)) = states_in(K, (pred(S::in) is semidet :-
    list.member(P, label_of(K, S)))).
sat(K, neg(F)) = set.difference(K ^ states, sat(K, F)).
sat(K, conj(F1, F2)) = set.intersect(sat(K, F1), sat(K, F2)).
sat(K, disj(F1, F2)) = set.union(sat(K, F1), sat(K, F2)).
sat(K, ex(F)) = ex_set(K, sat(K, F)).
sat(K, ax(F)) = ax_set(K, sat(K, F)).

sat(K, ef(F)) = least_fixpoint(K, (func(Z) = set.union(sat(K, F), ex_set(K, Z)))).
sat(K, af(F)) = least_fixpoint(K, (func(Z) = set.union(sat(K, F), ax_set(K, Z)))).
sat(K, eg(F)) = greatest_fixpoint(K, (func(Z) = set.intersect(sat(K, F), ex_set(K, Z)))).
sat(K, ag(F)) = greatest_fixpoint(K, (func(Z) = set.intersect(sat(K, F), ax_set(K, Z)))).

sat(K, eu(F1, F2)) = least_fixpoint(K,
    (func(Z) = set.union(sat(K, F2),
        set.intersect(sat(K, F1), ex_set(K, Z))))).
sat(K, au(F1, F2)) = least_fixpoint(K,
    (func(Z) = set.union(sat(K, F2),
        set.intersect(sat(K, F1), ax_set(K, Z))))).

%----- one-step transformers -----%

:- func ex_set(kripke, set(string)) = set(string).
ex_set(K, Z) = states_in(K, (pred(S::in) is semidet :-
    some [T] (list.member(T, succ_of(K, S)), set.member(T, Z)))).

:- func ax_set(kripke, set(string)) = set(string).
ax_set(K, Z) = states_in(K, (pred(S::in) is semidet :-
    all_in(succ_of(K, S), Z))).

    % All states of K satisfying the given condition.
:- func states_in(kripke, pred(string)) = set(string).
:- mode states_in(in, in(pred(in) is semidet)) = out is det.
states_in(K, Cond) = set.from_list(
    list.filter(Cond, set.to_sorted_list(K ^ states))).

:- func label_of(kripke, string) = list(string).
label_of(K, S) = ( if map.search(K ^ labels, S, L) then L else [] ).

:- func succ_of(kripke, string) = list(string).
succ_of(K, S) = ( if map.search(K ^ succs, S, L) then L else [] ).

:- pred all_in(list(string)::in, set(string)::in) is semidet.
all_in([], _).
all_in([A | As], Z) :-
    set.member(A, Z),
    all_in(As, Z).

%----- fixpoint iteration -----%

:- func least_fixpoint(kripke, func(set(string)) = set(string)) = set(string).
least_fixpoint(K, Step) = iterate(K, Step, set.init).

:- func greatest_fixpoint(kripke, func(set(string)) = set(string)) = set(string).
greatest_fixpoint(K, Step) = iterate(K, Step, K ^ states).

:- func iterate(kripke, func(set(string)) = set(string), set(string))
    = set(string).
iterate(K, Step, Z0) = Z :-
    Z1 = Step(Z0),
    ( if Z1 = Z0 then
        Z = Z0
      else
        Z = iterate(K, Step, Z1)
    ).

:- end_module ctl.
