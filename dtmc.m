%---------------------------------------------------------------------------%
% dtmc.m — the PLP + CTL merge: PCTL's P=? [ F target ] on a DTMC.
%
% This is the bridge between the two earlier sketches:
%
%   ctl.m  :  EF target  — "can we reach target?"  — a BOOLEAN least
%            fixpoint over sets of states.
%   dtmc.m :  P=? [ F target ] — "with what probability?" — the SAME
%            least fixpoint, lifted from booleans (sets) to probability
%            vectors (map state -> float).
%
% On a DTMC (each state's outgoing edges carry probabilities summing to
% 1), the reachability probability satisfies the fixpoint equation
%
%     P(s) = 1                          if s in target
%     P(s) = 0                          if s is a dead end, s not in target
%     P(s) = sum_t Pr(s -> t) * P(t)    otherwise
%
% and the least fixpoint of this monotone operator is the exact
% probability of eventually hitting target. Value iteration computes it:
% start from the vector with 1 on the target and 0 everywhere else, apply
% the one-step operator, and stop when the largest change drops below a
% tolerance. On a finite DTMC this converges from below — exactly like
% CTL's least fixpoint grows from the empty set, only the lattice is
% richer.
%
% Also included: the time-bounded variant P=? [ F<=k target ], which is
% CTL's EF^k (reach within at most k steps). It needs no iteration — it
% is a single exact backward pass of k steps.
%
% The demo (dtmc_demo.m) runs both on one small machine model and
% cross-checks the answer against ctl.sat: a state satisfies EF(target)
% (boolean) iff its reachability probability is > 0. Same structure, two
% readings — the union of the two sketches in one file.
%---------------------------------------------------------------------------%

:- module dtmc.

:- interface.

:- import_module float.
:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module set.
:- import_module string.

    % A discrete-time Markov chain: states plus a transition function
    % (state -> list of (state, probability)). The probabilities out of
    % each state are assumed to sum to 1.
:- type dtmc
    --->    dtmc(
                states  :: set(string),
                trans   :: map(string, list(pair(string, float)))
            ).

    % P=? [ F target ] — the probability of eventually reaching a target
    % state, by value iteration. Eps is the convergence tolerance
    % (max change per iteration). Returns a map from every state to its
    % reachability probability.
:- func reach_prob(dtmc, set(string), float) = map(string, float).

    % P=? [ F<=k target ] — probability of reaching the target within
    % at most k steps. Exact, one backward pass.
:- func bounded_reach_prob(dtmc, set(string), int) = map(string, float).

:- implementation.

:- import_module int.
:- import_module require.

%----- value iteration -----%

reach_prob(D, Target, Eps) = P :-
    P = vi(D, Target, init_vec(D, Target), Eps).

    % Start vector: 1 on the target, 0 elsewhere.
:- func init_vec(dtmc, set(string)) = map(string, float).
init_vec(D, Target) = map.from_assoc_list(
    list.map((func(S) = S - ( if set.member(S, Target) then 1.0 else 0.0 )),
        set.to_sorted_list(D ^ states))).

:- func vi(dtmc, set(string), map(string, float), float) = map(string, float).
vi(D, Target, P0, Eps) = P :-
    P1 = one_step(D, Target, P0),
    ( if max_gap(P0, P1) < Eps then
        P = P1
      else
        P = vi(D, Target, P1, Eps)
    ).

%----- the one-step operator -----%

:- func one_step(dtmc, set(string), map(string, float)) = map(string, float).
one_step(D, Target, P) = map.from_assoc_list(
    list.map((func(S) = S - step_val(D, Target, P, S)),
        set.to_sorted_list(D ^ states))).

:- func step_val(dtmc, set(string), map(string, float), string) = float.
step_val(D, Target, P, S) = V :-
    ( if set.member(S, Target) then
        V = 1.0
      else if succs_of(D, S) = [] then
        V = 0.0
      else
        V = sum_succ(P, succs_of(D, S))
    ).

:- func sum_succ(map(string, float), list(pair(string, float))) = float.
sum_succ(_, []) = 0.0.
sum_succ(P, [T - Pr | Rest]) = Pr * map.lookup(P, T) + sum_succ(P, Rest).

%----- convergence check -----%

    % Largest change in any state between two successive vectors.
:- func max_gap(map(string, float), map(string, float)) = float.
max_gap(P0, P1) = list.foldl(float.max,
    list.map((func(S) = float.abs(map.lookup(P1, S) - map.lookup(P0, S))),
        map.keys(P0)),
    0.0).

%----- time-bounded reachability (exact, no iteration) -----%

bounded_reach_prob(D, Target, K) = bounded(D, Target, K, init_vec(D, Target)).

:- func bounded(dtmc, set(string), int, map(string, float)) = map(string, float).
bounded(D, Target, K, P0) = P :-
    ( if K = 0 then
        P = P0
      else
        P1 = one_step(D, Target, P0),
        P = bounded(D, Target, K - 1, P1)
    ).

%----- helpers -----%

:- func succs_of(dtmc, string) = list(pair(string, float)).
succs_of(D, S) = ( if map.search(D ^ trans, S, L) then L else [] ).

:- end_module dtmc.
