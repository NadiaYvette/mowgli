% dtmc_demo.m — run the DTMC/PCTL core on a small machine-reliability
% model, and cross-check it against the boolean CTL checker.
%
% The model — a machine that can fail, be repaired, or die outright:
%
%     idle    --0.90--> idle      --0.10--> active
%     active  --0.80--> idle      --0.15--> failed    --0.05--> dead
%     failed  --0.60--> active    --0.40--> failed
%     dead    --1.00--> dead                    (absorbing)
%
% Hand-computed answers (the demo checks them):
%
%   P=? [ F failed ]
%       idle = active = 0.75    failed = 1    dead = 0
%       (0.75 before dying; 0.25 of runs die first)
%
%   P=? [ F dead ]   = 1.0 from every state  (dying is almost sure)
%
%   P=? [ F<=k failed ] from idle:  0, 0.015, 0.0285, ...  ->  0.75
%
% The CTL cross-check: on the same graph with probabilities erased,
% ctl.sat(K, EF failed) must be exactly the set of states whose
% reachability probability is > 0. Same structure, two readings — the
% boolean one and the probabilistic one agree.

:- module dtmc_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module ctl.
:- import_module dtmc.
:- import_module float.
:- import_module int.
:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module set.
:- import_module string.

main(!IO) :-
    io.write_string("== DTMC / PCTL in Mercury (the PLP + CTL merge) ==\n", !IO),
    io.nl(!IO),

    M = machine,

    %--- P=? [ F failed ] ---%
    io.write_string("P=? [ F failed ]  (eventually fail, before dying)\n", !IO),
    P_failed = reach_prob(M, set.from_list(["failed"]), 1e-9),
    print_probs("idle", P_failed, 0.75, !IO),
    print_probs("active", P_failed, 0.75, !IO),
    print_probs("failed", P_failed, 1.0, !IO),
    print_probs("dead", P_failed, 0.0, !IO),
    io.nl(!IO),

    %--- P=? [ F dead ] ---%
    io.write_string("P=? [ F dead ]  (eventually die — almost sure)\n", !IO),
    P_dead = reach_prob(M, set.from_list(["dead"]), 1e-9),
    print_probs("idle", P_dead, 1.0, !IO),
    print_probs("active", P_dead, 1.0, !IO),
    print_probs("failed", P_dead, 1.0, !IO),
    print_probs("dead", P_dead, 1.0, !IO),
    io.nl(!IO),

    %--- P=? [ F<=k failed ] — bounded horizon, converging ---%
    io.write_string("P=? [ F<=k failed ] from idle — bounded reachability\n", !IO),
    bounded_loop(M, set.from_list(["failed"]), "idle", 1, 12, !IO),
    io.format("  k=inf (value iteration): %.6f\n",
        [f(map.lookup(P_failed, "idle"))], !IO),
    io.nl(!IO),

    %--- the CTL cross-check ---%
    io.write_string("Cross-check vs the boolean CTL checker:\n", !IO),
    K = kripke(
        set.from_list(["idle", "active", "failed", "dead"]),
        map.from_assoc_list([
            "idle" - [],
            "active" - [],
            "failed" - ["failed"],
            "dead" - []
        ]),
        map.from_assoc_list([
            "idle" - ["idle", "active"],
            "active" - ["idle", "failed", "dead"],
            "failed" - ["active", "failed"],
            "dead" - ["dead"]
        ])
    ),
    EF_failed = sat(K, ef(prop("failed"))),
    io.format("  CTL  EF failed  => %s\n", [s(set_to_string(EF_failed))], !IO),
    Positive = positive_states(P_failed),
    io.format("  DTMC P>0 states => %s\n", [s(set_to_string(Positive))], !IO),
    io.format("  agreement: %s\n",
        [s(if set.equal(EF_failed, Positive) then "yes" else "NO")], !IO),
    io.nl(!IO),

    io.write_string("done.\n", !IO).

%----- the machine model -----%

:- func machine = dtmc.
machine = dtmc(
    set.from_list(["idle", "active", "failed", "dead"]),
    map.from_assoc_list([
        "idle" - ["idle" - 0.9, "active" - 0.1],
        "active" - ["idle" - 0.8, "failed" - 0.15, "dead" - 0.05],
        "failed" - ["active" - 0.6, "failed" - 0.4],
        "dead" - ["dead" - 1.0]
    ])).

%----- output helpers -----%

    % Print one state's probability, with the hand-computed expected
    % value for a yes/no agreement check.
:- pred print_probs(string::in, map(string, float)::in, float::in,
    io::di, io::uo) is det.
print_probs(State, P, Expected, !IO) :-
    V = map.lookup(P, State),
    Ok = ( if float.abs(V - Expected) < 1e-6 then "ok" else "MISMATCH" ),
    io.format("  %-8s: %.6f   (expected %.4f) [%s]\n",
        [s(State), f(V), f(Expected), s(Ok)], !IO).

    % Print P=? [ F<=k target ] at one state for k = 1..KMax.
:- pred bounded_loop(dtmc::in, set(string)::in, string::in, int::in,
    int::in, io::di, io::uo) is det.
bounded_loop(D, Target, State, K, KMax, !IO) :-
    ( if K > KMax then
        true
      else
        P = bounded_reach_prob(D, Target, K),
        io.format("  k=%2d: %.6f\n", [i(K), f(map.lookup(P, State))], !IO),
        bounded_loop(D, Target, State, K + 1, KMax, !IO)
    ).

    % States whose reachability probability is strictly positive.
:- func positive_states(map(string, float)) = set(string).
positive_states(P) = set.from_list(States) :-
    list.filter_map(
        (pred(S::in, S::out) is semidet :- map.lookup(P, S) > 0.0),
        map.keys(P), States).

:- func set_to_string(set(string)) = string.
set_to_string(S) =
    "{" ++ string.join_list(", ", set.to_sorted_list(S)) ++ "}".

:- end_module dtmc_demo.
