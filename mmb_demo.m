%---------------------------------------------------------------------------%
% mmb_demo.m — probabilistic multi-agent reasoning (multimodal x prob).
%
% Scenario: A die shows 1-4 with a SKEWED prior:
%   P(1) = 0.4, P(2) = 0.3, P(3) = 0.2, P(4) = 0.1
%
% Agent 1 sees the exact value (full information).
% Agent 2 sees only whether <=2 or >=3 (half information).
%
% We compute:
%   - Prior probability of each property (odd, even, lo, hi)
%   - Each agent's BELIEF in each property (conditioned on actual world)
%   - The epistemic asymmetry in probabilistic terms
%
% This demonstrates how multimodal logic + probability gives us
% quantitative epistemic reasoning: not just "does Agent 2 know odd?"
% (no, in boolean terms) but "how confident is Agent 2 in odd?"
% (depends on which half they observe).
%---------------------------------------------------------------------------%

:- module mmb_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module float.
:- import_module list.
:- import_module map.
:- import_module mmb.
:- import_module mm.
:- import_module pair.
:- import_module set.
:- import_module string.

main(!IO) :-
    States = set.from_list(["w1", "w2", "w3", "w4"]),

    Labels = map.from_assoc_list([
        "w1" - ["odd", "lo"],
        "w2" - ["even", "lo"],
        "w3" - ["odd", "hi"],
        "w4" - ["even", "hi"]
    ]),

    K1 = list.map(
        (func(P) = P),
        ["K1" - ("w1" - ["w1"]),
         "K1" - ("w2" - ["w2"]),
         "K1" - ("w3" - ["w3"]),
         "K1" - ("w4" - ["w4"])]),

    K2 = list.map(
        (func(P) = P),
        ["K2" - ("w1" - ["w1", "w2"]),
         "K2" - ("w2" - ["w1", "w2"]),
         "K2" - ("w3" - ["w3", "w4"]),
         "K2" - ("w4" - ["w3", "w4"])]),

    Base = mm.mk_kripke(States, Labels, K1 ++ K2),

    Prior = [
        "w1" - 0.4,
        "w2" - 0.3,
        "w3" - 0.2,
        "w4" - 0.1
    ],

    PK = mmb.mk_pmkripke(Base, Prior),

    io.write_string("== Probabilistic Multi-Agent Reasoning ==\n", !IO),
    io.write_string("Die 1-4, skewed prior: P(1)=0.4 P(2)=0.3 P(3)=0.2 P(4)=0.1\n", !IO),
    io.write_string("K1 = Agent 1 (sees exact), K2 = Agent 2 (sees half)\n", !IO),
    io.nl(!IO),

    io.write_string("--- Prior Probabilities ---\n", !IO),
    show_prob(PK, "P(odd)", mm.prop("odd"), !IO),
    show_prob(PK, "P(even)", mm.prop("even"), !IO),
    show_prob(PK, "P(lo)", mm.prop("lo"), !IO),
    show_prob(PK, "P(hi)", mm.prop("hi"), !IO),
    io.nl(!IO),

    io.write_string("--- Agent 1's Beliefs (sees exact) ---\n", !IO),
    show_belief(PK, "K1", "w1", "odd", !IO),
    show_belief(PK, "K1", "w1", "lo", !IO),
    show_belief(PK, "K1", "w3", "odd", !IO),
    show_belief(PK, "K1", "w3", "lo", !IO),
    io.nl(!IO),

    io.write_string("--- Agent 2's Beliefs (sees half only) ---\n", !IO),
    show_belief(PK, "K2", "w1", "odd", !IO),
    show_belief(PK, "K2", "w1", "lo", !IO),
    show_belief(PK, "K2", "w3", "odd", !IO),
    show_belief(PK, "K2", "w3", "lo", !IO),
    io.nl(!IO),

    io.write_string("--- Information Asymmetry (quantified) ---\n", !IO),
    io.write_string("When actual world is w1 (die=1, odd, lo):\n", !IO),
    show_both_beliefs(PK, "w1", "odd", !IO),
    show_both_beliefs(PK, "w1", "lo", !IO),
    io.nl(!IO),
    io.write_string("When actual world is w3 (die=3, odd, hi):\n", !IO),
    show_both_beliefs(PK, "w3", "odd", !IO),
    show_both_beliefs(PK, "w3", "lo", !IO),
    io.nl(!IO),

    io.write_string("--- Key Insight ---\n", !IO),
    io.write_string("Agent 2 is NEVER certain about parity (belief != 0 or 1)\n", !IO),
    io.write_string("but IS certain about half (belief = 1.0 for lo or hi).\n", !IO),
    io.write_string("Agent 1 is ALWAYS certain about everything they observe.\n", !IO),
    io.nl(!IO),

    io.write_string("done.\n", !IO).

%----- output helpers -----%

:- pred show_prob(mmb.pmkripke::in, string::in, mm.mmf::in,
    io::di, io::uo) is det.
show_prob(PK, Desc, F, !IO) :-
    P = mmb.prob(PK, F),
    io.format("  %-20s = %.4f\n", [s(Desc), f(P)], !IO).

:- pred show_belief(mmb.pmkripke::in, string::in, string::in,
    string::in, io::di, io::uo) is det.
show_belief(PK, Agent, World, PropName, !IO) :-
    B = mmb.belief(PK, Agent, mm.prop(PropName), World),
    io.format("  %s believes %s at %s = %.4f\n",
        [s(Agent), s(PropName), s(World), f(B)], !IO).

:- pred show_both_beliefs(mmb.pmkripke::in, string::in, string::in,
    io::di, io::uo) is det.
show_both_beliefs(PK, World, PropName, !IO) :-
    B1 = mmb.belief(PK, "K1", mm.prop(PropName), World),
    B2 = mmb.belief(PK, "K2", mm.prop(PropName), World),
    io.format("    %-10s: K1=%.4f  K2=%.4f\n",
        [s(PropName), f(B1), f(B2)], !IO).
