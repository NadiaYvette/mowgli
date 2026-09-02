%---------------------------------------------------------------------------%
% mm_demo.m — multimodal epistemic logic: two agents, partial information.
%
% Scenario: A die shows a value 1-4. Agent 1 sees the EXACT value.
% Agent 2 can only tell whether the value is <=2 or >=3 (half the
% die).
%
% This creates a clean information asymmetry:
%   - K1(exact)  : Agent 1 knows the exact value
%   - K2(<=2)    : Agent 2 knows the half
%   - K1(<=2)    : Agent 1 also knows the half (can derive it)
%   - K2(K1(<=2)): Agent 2 knows Agent 1 knows the half
%   - K1(K2(<=2)): Agent 1 knows Agent 2 knows the half
%
% But Agent 2 cannot know odd/even (finer than their partition),
% and cannot know what Agent 1 knows about odd/even.
%
% Worlds:  w1(=1)  w2(=2)  w3(=3)  w4(=4)
% Props:   odd,lo  even,lo odd,hi  even,hi
%
% K1: exact observation → each world alone (full information)
% K2: half-observation → {w1,w2} (lo), {w3,w4} (hi)
%
% This is the standard Hintikka semantics for two agents in S5.
%---------------------------------------------------------------------------%

:- module mm_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list.
:- import_module map.
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

    % K1 (Agent 1): sees exact value. Each world is its own class.
    K1 = list.map(
        (func(P) = P),
        ["K1" - ("w1" - ["w1"]),
         "K1" - ("w2" - ["w2"]),
         "K1" - ("w3" - ["w3"]),
         "K1" - ("w4" - ["w4"])]),

    % K2 (Agent 2): sees half (<=2 or >=3).
    %   w1, w2: lo-half -> {w1, w2}
    %   w3, w4: hi-half -> {w3, w4}
    K2 = list.map(
        (func(P) = P),
        ["K2" - ("w1" - ["w1", "w2"]),
         "K2" - ("w2" - ["w1", "w2"]),
         "K2" - ("w3" - ["w3", "w4"]),
         "K2" - ("w4" - ["w3", "w4"])]),

    RelPairs = K1 ++ K2,
    K = mm.mk_kripke(States, Labels, RelPairs),

    io.write_string("== Multimodal Epistemic Logic Demo ==\n", !IO),
    io.write_string("Die value 1-4. Agent 1 sees exact, Agent 2 sees half.\n", !IO),
    io.write_string("K1 = Agent 1 (exact), K2 = Agent 2 (half: <=2 or >=3)\n", !IO),
    io.nl(!IO),

    io.write_string("--- What Each Agent Knows ---\n", !IO),
    check(K, "K1(odd): Agent 1 knows odd",
        mm.box("K1", mm.prop("odd")), !IO),
    check(K, "K1(even): Agent 1 knows even",
        mm.box("K1", mm.prop("even")), !IO),
    check(K, "K1(lo): Agent 1 knows lo",
        mm.box("K1", mm.prop("lo")), !IO),
    check(K, "K2(lo): Agent 2 knows lo",
        mm.box("K2", mm.prop("lo")), !IO),
    check(K, "K2(odd): Agent 2 knows odd?",
        mm.box("K2", mm.prop("odd")), !IO),
    io.nl(!IO),

    io.write_string("--- Second-Order Knowledge ---\n", !IO),
    check(K, "K2(K1(lo)): Agent 2 knows Agent 1 knows lo",
        mm.box("K2", mm.box("K1", mm.prop("lo"))), !IO),
    check(K, "K1(K2(lo)): Agent 1 knows Agent 2 knows lo",
        mm.box("K1", mm.box("K2", mm.prop("lo"))), !IO),
    check(K, "K2(K1(odd)): Agent 2 knows Agent 1 knows odd",
        mm.box("K2", mm.box("K1", mm.prop("odd"))), !IO),
    check(K, "K2(~K2(odd)): Agent 2 knows it doesn't know odd",
        mm.box("K2", mm.neg(mm.box("K2", mm.prop("odd")))), !IO),
    io.nl(!IO),

    io.write_string("--- Ignorance and Possibility ---\n", !IO),
    check(K, "dia(K2,odd): Agent 2 considers odd possible",
        mm.dia("K2", mm.prop("odd")), !IO),
    check(K, "dia(K2,even): Agent 2 considers even possible",
        mm.dia("K2", mm.prop("even")), !IO),
    check(K, "~K2(odd) & ~K2(even): Agent 2 is ignorant of parity",
        mm.conj(
            mm.neg(mm.box("K2", mm.prop("odd"))),
            mm.neg(mm.box("K2", mm.prop("even")))), !IO),
    io.nl(!IO),

    io.write_string("--- Information Asymmetry ---\n", !IO),
    check(K, "K1(lo) & K2(lo): both know lo (shared info)",
        mm.conj(mm.box("K1", mm.prop("lo")),
                mm.box("K2", mm.prop("lo"))), !IO),
    check(K, "K1(odd) & ~K2(odd): Agent 1 knows, Agent 2 doesn't",
        mm.conj(mm.box("K1", mm.prop("odd")),
                mm.neg(mm.box("K2", mm.prop("odd")))), !IO),
    check(K, "K1(odd) & K2(K1(odd)): Agent 1 knows odd and Agent 2 knows that",
        mm.conj(mm.box("K1", mm.prop("odd")),
                mm.box("K2", mm.box("K1", mm.prop("odd")))), !IO),
    io.nl(!IO),

    io.write_string("--- Negative Knowledge ---\n", !IO),
    check(K, "~K2(odd): Agent 2 does NOT know odd",
        mm.neg(mm.box("K2", mm.prop("odd"))), !IO),
    check(K, "K1(lo) -> K2(K1(lo)): knowledge transfer",
        mm.imp(mm.box("K1", mm.prop("lo")),
               mm.box("K2", mm.box("K1", mm.prop("lo")))), !IO),
    io.nl(!IO),

    io.write_string("--- Nested Modalities ---\n", !IO),
    check(K, "K1(K1(odd)): Agent 1 knows that it knows odd",
        mm.box("K1", mm.box("K1", mm.prop("odd"))), !IO),
    check(K, "K1(K2(lo)): Agent 1 knows Agent 2 knows lo",
        mm.box("K1", mm.box("K2", mm.prop("lo"))), !IO),
    check(K, "dia(K1,dia(K2,odd)): Agent 1 can reach world where Agent 2 considers odd",
        mm.dia("K1", mm.dia("K2", mm.prop("odd"))), !IO),
    io.nl(!IO),

    io.write_string("--- Structure ---\n", !IO),
    io.write_string("States: w1(=1)  w2(=2)  w3(=3)  w4(=4)\n", !IO),
    show_rel(K, "K1", ["w1", "w2", "w3", "w4"], !IO),
    show_rel(K, "K2", ["w1", "w2", "w3", "w4"], !IO),
    io.nl(!IO),

    io.write_string("done.\n", !IO).

:- pred check(mm.kripke_m::in, string::in, mm.mmf::in,
    io::di, io::uo) is det.
check(K, Desc, F, !IO) :-
    S = mm.sat(K, F),
    io.format("  %-48s => %s\n",
        [s(Desc), s(set_to_string(S))], !IO).

:- pred show_rel(mm.kripke_m::in, string::in, list(string)::in,
    io::di, io::uo) is det.
show_rel(_, _, [], !IO).
show_rel(K, M, [S | Ss], !IO) :-
    io.format("  %s --%s--> %s\n",
        [s(S), s(M), s(set_to_string_rel(K, M, S))], !IO),
    show_rel(K, M, Ss, !IO).

:- func set_to_string_rel(mm.kripke_m, string, string) = string.
set_to_string_rel(K, M, S) = Result :-
    ( if map.search(K ^ mm.rels, M, RelMap),
      map.search(RelMap, S, R)
    then
        Result = "{" ++ string.join_list(", ", R) ++ "}"
    else
        Result = "{}"
    ).

:- func set_to_string(set(string)) = string.
set_to_string(S) =
    "{" ++ string.join_list(", ", set.to_sorted_list(S)) ++ "}".
