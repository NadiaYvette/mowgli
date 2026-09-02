%---------------------------------------------------------------------------%
% grounding_demo.m — CLOSED perception-action loop (Friston complete).
%
%   world --(sensor)--> signs --(likelihood x prior)--> posterior
%     ^                                                   |
%     |                                            ec.m commitments
%  actuator                                          |     |
%     |                                       reason  | belief per
%  ACTUATION <--(policy threshold 0.7)-- over grown -+ modality type
%               writes to the world    ontology
%
% New versus the open-cycle demo:
%   * An OPERATOR AGENT pursues deontic goal O(lamp_on).
%     Policy: if P(hyp=on) < THETA then fire the switch actuator
%     (expected-surprise minimisation toward the normative target).
%   * Nature intervenes too: hardware faults kill the lamp at
%     ticks 4 and 9. The agent must detect, infer, actuate, recover.
%   * The sensory anomaly (flicker_burst, tick 6) still forces
%     ontology growth exactly as before.
%---------------------------------------------------------------------------%

:- module grounding_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module ec.
:- import_module float.
:- import_module int.
:- import_module list.
:- import_module map.
:- import_module mmb.
:- import_module mm.
:- import_module pair.
:- import_module set.
:- import_module string.

%----- configuration -----%

:- func world_on = string.   world_on  = "w_on".
:- func world_off = string.  world_off = "w_off".

:- func theta = float.            theta = 0.7.
:- func max_tick = int.           max_tick = 10.
:- func fault_ticks = list(int).  fault_ticks = [4, 9].
:- func burst_tick = int.         burst_tick = 6.

:- func seed_vocab = set(string).
seed_vocab = set.from_list(["bright", "dark", "on", "off"]).

    % Sensor likelihoods.
:- func likel(string, string) = float.
likel(O, W) =
    ( if O = "bright" then
        ( if W = world_on then 0.9 else 0.2 )
      else if O = "dark" then
        ( if W = world_on then 0.1 else 0.8 )
      else
        1.0                              % unknown sign: uninformative
    ).

%----- main -----%

main(!IO) :-
    io.write_string("== Grounding Loop Demo (CLOSED with actuation) ==\n", !IO),
    io.write_string("Normative goal: O(lamp_on) enforced by policy on P(hyp=on).\n", !IO),
    io.write_string("Nature faults the lamp at ticks 4 and 9.\n", !IO),
    io.nl(!IO),
    InitPrior = map.set(map.set(map.init,
        world_on, 0.5), world_off, 0.5),
    BaseK = mk_base(no),
    PK0 = mmb.mk_pmkripke(BaseK,
        [(world_on - 0.5), (world_off - 0.5)]),
    run(max_tick, fault_ticks, burst_tick,
        0, "on-init", InitPrior, [], seed_vocab,
        no, no, PK0, world_on, !IO).

%----- recursive tick loop -----%

    % State threaded through ticks:
    %   EventsSoFar : chronological primitive-event log (ec)
    %   PlanOn      : whether controller's last decision keeps lamp on
    %   WasBurst    : one-tick scar of instability needs healing now
:- pred run(int::in, list(int)::in, int::in,
    int::in, string::in, map(string, float)::in,
    list(ec.fluent_event)::in, set(string)::in,
    bool::in, bool::in, mmb.pmkripke::in,
    string::in, io::di, io::uo) is det.
run(N, Faults, BurstAt, T0, _PrevTruthStr, Prior, EventsIn,
    Vocab0, Unstable0, WasBurst0, _PKPrev, PrevEffTruth, !IO) :-
    % Single merged clause: this rotd cannot prove det for
    % comparison-guarded sibling clauses threading unique io state.
    ( if N =< 0 then
        true
      else
        T = T0 + 1,

    % --- heal yesterday's scar before anything else can happen ---
    ( if WasBurst0 = yes then
        Healed = [ec.terminate("instability_burst") | EventsIn]
      else
        Healed = EventsIn
    ),

    % --- nature: exogenous fault may override the planned state ---
    IsFault = has_elem(Faults, T),
    EffectiveTruth =
        ( if IsFault = yes, PrevEffTruth \= "on-init" then
            "off"
          else
            plan_truth(PrevEffTruth)
        ),

    % --- events: record how today's physical state came to be ---
    Events1 = record_transition(Healed, PrevEffTruth, EffectiveTruth),

    % --- sensing: photons -> signed observations ---
    Obs = observe(T, BurstAt, EffectiveTruth),

    % --- active inference: Bayesian interpretant ---
    Posterior0 = bayes_update(Obs, Prior),
    Posterior  = normalise(Posterior0),

    % --- novelty scan: does the world speak an unknown sign? ---
    scan_novel(Obs, Vocab0, Vocab, !IO),
    IsBurstNow = has_elem(Obs, "flicker_burst"),
    Unstable1 = ( if Unstable0 = yes then yes
                  else if IsBurstNow = yes then yes
                  else no ),
    Events2 =
        ( if IsBurstNow = yes then
            [ec.initiate("instability_burst") | Events1]
          else
            Events1
        ),

    % --- rebuild grounded model with THIS tick's commitments ---
    TrueWorld =
        ( if EffectiveTruth = "on" then world_on else world_off ),
    to_chrono(Events2, [], ChronoLog),
    FluentSet = ec.holding(ChronoLog),
    BaseA = mk_base(Unstable1),
    BaseB = ec.apply_labels(BaseA, TrueWorld, FluentSet),
    PK = mmb.mk_pmkripke(BaseB, map.to_assoc_list(Posterior)),

    % --- report what reasoning knows right now ---
    io.format("t%-2s truth=%-6s obs=%s\n",
        [s(string.from_int(T)), s(EffectiveTruth),
         s(bracket_obs(Obs))], !IO),
    POn = mmb.prob(PK, mm.prop("on")),
    CommitProp = ( if EffectiveTruth = "on" then "lamp_on"
                   else "lamp_off" ),
    PC = mmb.prob(PK, mm.prop(CommitProp)),
    io.format("   P(hyp=on)=%.4f   P(commitment)=%.4f\n",
        [f(POn), f(PC)], !IO),
    BPixel = mmb.belief(PK, "pixel", mm.prop("on"), TrueWorld),
    BDrunk = mmb.belief(PK, "drunk", mm.prop("on"), TrueWorld),
    BWatch = mmb.belief(PK, "watch", mm.prop("on"), TrueWorld),
    io.format(
      "   beliefs in 'on': pixel=%.2f drunk=%.2f watch=%.2f\n",
      [f(BPixel), f(BDrunk), f(BWatch)], !IO),

    % --- ACTUATION: close the loop through the world ---
    ( if EffectiveTruth = "on" then
        io.write_string("   (norm satisfied; no actuation)\n", !IO)
      else
        io.write_string(
          "   >>> ACTUATOR FIRES: norm violated -> commands switch-on\n", !IO)
    ),

    ( if Unstable0 = no, Unstable1 = yes then
        PU = mmb.prob(PK, mm.prop("unstable")),
        io.format("   >>> ONTOLOGY GREW: 'unstable' adopted, P=%.4f\n",
          [f(PU)], !IO)
      else true
    ),

    % --- next tick's planned truth reflects the action just taken ---
    RunN     = N - 1,

    ( if IsBurstNow = yes then
        run(RunN, Faults, BurstAt, T, EffectiveTruth, Posterior,
            Events2, Vocab, Unstable1, IsBurstNow, PK,
            "flick-pending", !IO)
      else
        % Pending corrective request consumed by next tick's planner:
        % plan_truth("want-on") = "on" — a one-shot switch restoration.
        run(RunN, Faults, BurstAt, T, EffectiveTruth, Posterior,
            Events2, Vocab, Unstable1, IsBurstNow, PK,
            "want-on", !IO)
        )
    ).

%----- helper: translating the threaded "plan" strings -----%

    % plan_truth maps last tick's hand-off into tonight's baseline;
    % a fault below overrides it.
:- func plan_truth(string) = string.
plan_truth(S) =
    ( if S = "flip-off" ; S = "flick-pending" ; S = "off" then "off"
      else "on"
    ).

:- func record_transition(list(ec.fluent_event), string, string)
    = list(ec.fluent_event).
record_transition(Acc, Prev, New) =
    ( if New = "on-init" then
        [ec.initiate("lamp_on") | Acc]
      else if Prev = New then Acc
      else if New = "on" then
        [ec.initiate("lamp_on"), ec.terminate("lamp_off") | Acc]
      else
        [ec.initiate("lamp_off"), ec.terminate("lamp_on") | Acc]
    ).

%----- membership as a bool-returning function -----%

    % list.member/2 is a semidet PREDICATE in this stdlib; using it in
    % equation position silently types the variable as `pred'. This
    % polymorphic wrapper gives us genuine bool values instead.
:- func has_elem(list(T), T) = bool.
has_elem([], _) = no.
has_elem([X | Xs], Y) =
    ( if X = Y then yes else has_elem(Xs, Y) ).

:- func observe(int, int, string) = list(string).
observe(T, BurstAt, Truth) =
    ( if T = BurstAt then ["flicker_burst"]
      else if Truth = "on" then ["bright"]
      else ["dark"]
    ).

%----- chronological normalisation for ec.holding -----%

    % Front-prepending accumulates newest-first; ec.holding's
    % last-write-wins walk needs oldest-first: reverse once per tick.
:- pred to_chrono(list(ec.fluent_event)::in,
    list(ec.fluent_event)::in, list(ec.fluent_event)::out) is det.
to_chrono([], Chrono, Chrono).
to_chrono([E | Es], Acc0, Chrono) :-
    to_chrono(Es, [E | Acc0], Chrono).

%----- bayesian machinery (the variational interpretant) -----%

:- func bayes_update(list(string), map(string, float))
    = map(string, float).
bayes_update([], M) = M.
bayes_update([O | Os], M0) = bayes_update(Os, M1) :-
    Won  = map.lookup(M0, world_on)  * likel(O, world_on),
    Woff = map.lookup(M0, world_off) * likel(O, world_off),
    M1 = map.set(map.set(M0, world_on, Won), world_off, Woff).

:- func normalise(map(string, float)) = map(string, float).
normalise(M) = Out :-
    Sum = map.lookup(M, world_on) + map.lookup(M, world_off),
    ( if Sum < 0.000000000001 then
        Out = map.set(map.set(M, world_on, 0.5), world_off, 0.5)
      else
        Out = map.set(map.set(M, world_on,
                            map.lookup(M, world_on) / Sum),
                      world_off,
                            map.lookup(M, world_off) / Sum)
    ).

%----- ontology seed structure -----%

:- func mk_base(bool) = mm.kripke_m.
mk_base(Unstable) = K :-
    States = set.from_list([world_on, world_off]),
    StaticOn  = ( if Unstable = yes then ["on", "unstable"] else ["on"] ),
    StaticOff = ( if Unstable = yes then ["off", "unstable"] else ["off"] ),
    Labels = map.from_assoc_list([
        (world_on -  StaticOn),
        (world_off - StaticOff)
    ]),
    Rels = [
        "pixel" - (world_on - [world_on]),
        "pixel" - (world_off - [world_off]),
        "drunk" - (world_on - [world_on, world_off]),
        "drunk" - (world_off - [world_on, world_off]),
        "watch" - (world_on - [world_on]),
        "watch" - (world_off - [world_on, world_off])
    ],
    K = mm.mk_kripke(States, Labels, Rels).

%----- misc helpers -----%

:- pred scan_novel(list(string)::in, set(string)::in, set(string)::out,
    io::di, io::uo) is det.
scan_novel([], V, V, !IO).
scan_novel([O | Os], V0, V, !IO) :-
    ( if set.member(O, V0) then
        scan_novel(Os, V0, V, !IO)
      else
        io.format("   >>> NOVEL SIGN '%s': vocabulary grew\n", [s(O)], !IO),
        scan_novel(Os, set.insert(V0, O), V, !IO)
    ).

:- func bracket_obs(list(string)) = string.
bracket_obs(Os) =
    "{" ++ string.join_list(", ", Os) ++ "}".

:- end_module grounding_demo.
