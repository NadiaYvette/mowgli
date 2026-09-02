%---------------------------------------------------------------------------%
% mmb.m — multimodal x probabilistic: probabilistic multi-agent reasoning.
%
% This merges mm.m (multimodal Kripke structures) with probability
% distributions, giving us:
%
%   1. P(F) — the prior probability that formula F holds, computed as
%      the total probability mass of worlds satisfying F.
%
%   2. belief_i(F, w) — the probability that agent i assigns to F,
%      given that the actual world is w. This is computed by restricting
%      agent i's attention to worlds accessible from w under relation
%      R_i, then summing the normalized prior mass of those accessible
%      worlds where F holds.
%
%      belief_i(F, w) = sum_{v in R_i(w) and v satisfies F} prior(v)
%                        -----------------------------------------
%                        sum_{v in R_i(w)} prior(v)
%
%      This is the standard Bayesian conditioning: agent i considers
%      only worlds compatible with their information (those accessible
%      from the actual world), renormalizes, and evaluates F.
%---------------------------------------------------------------------------%

:- module mmb.

:- interface.

:- import_module float.
:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module string.

:- import_module mm.

    % A probabilistic multimodal Kripke structure.
:- type pmkripke
    --->    pmkripke(
                base    :: mm.kripke_m,
                prior   :: map(string, float)
            ).

    % P(F) — prior probability that F holds.
:- func prob(pmkripke, mm.mmf) = float.

    % belief(AgentId, F, ActualWorld) — the probability that agent
    % AgentId assigns to F, given ActualWorld is the real world.
:- func belief(pmkripke, string, mm.mmf, string) = float.

    % Build a probabilistic multimodal Kripke structure.
:- func mk_pmkripke(mm.kripke_m, list(pair(string, float))) = pmkripke.

:- implementation.

:- import_module set.

prob(PK, F) = P :-
    SatSet = mm.sat(PK ^ base, F),
    prior_mass(PK, set.to_sorted_list(SatSet), 0.0, P).

belief(PK, Agent, F, ActualWorld) = B :-
    Accessible = get_accessible(PK ^ base, Agent, ActualWorld),
    prior_mass(PK, Accessible, 0.0, TotalMass),
    SatSet = mm.sat(PK ^ base, F),
    sat_mass(PK, Accessible, SatSet, 0.0, SatMass),
    ( if TotalMass > 0.0 then
        B = SatMass / TotalMass
      else
        B = 0.0
    ).

mk_pmkripke(Base, PriorPairs) = pmkripke(Base, map.from_assoc_list(PriorPairs)).

%----- helpers -----%

:- pred prior_mass(pmkripke::in, list(string)::in, float::in, float::out)
    is det.
prior_mass(_, [], Acc, Acc).
prior_mass(PK, [W | Ws], Acc, Result) :-
    ( if map.search(PK ^ prior, W, PW) then
        prior_mass(PK, Ws, Acc + PW, Result)
      else
        prior_mass(PK, Ws, Acc, Result)
    ).

:- pred sat_mass(pmkripke::in, list(string)::in, set(string)::in,
    float::in, float::out) is det.
sat_mass(_, [], _, Acc, Acc).
sat_mass(PK, [W | Ws], SatSet, Acc, Result) :-
    ( if set.member(W, SatSet),
      map.search(PK ^ prior, W, PW)
    then
        sat_mass(PK, Ws, SatSet, Acc + PW, Result)
      else
        sat_mass(PK, Ws, SatSet, Acc, Result)
    ).

:- func get_accessible(mm.kripke_m, string, string) = list(string).
get_accessible(K, M, S) = R :-
    ( if map.search(K ^ mm.rels, M, RelMap),
      map.search(RelMap, S, R0)
    then
        R = R0
    else
        R = []
    ).

:- end_module mmb.
