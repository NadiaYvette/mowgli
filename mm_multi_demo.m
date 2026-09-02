%---------------------------------------------------------------------------%
% mm_multi_demo.m — grand unified multimodal logic demo.
%
% Two agents decide whether to cooperate (C) or defect (D).
% Each agent has three modality types on the same worlds:
%   K_i (Epistemic, S5):  what agent i KNOWS
%   B_i (Doxastic, S4):   what agent i BELIEVES
%   O_i (Deontic, KD):    what agent i OUGHT to do
%---------------------------------------------------------------------------%

:- module mm_multi_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list.
:- import_module map.
:- import_module mm.
:- import_module mm_multi.
:- import_module pair.
:- import_module set.
:- import_module string.

main(!IO) :-
    States = set.from_list(["wCC", "wCD", "wDC", "wDD"]),

    Labels = map.from_assoc_list([
        "wCC" - ["C1", "C2"],
        "wCD" - ["C1"],
        "wDC" - ["C2"],
        "wDD" - []
    ]),

    % K1 (Epistemic S5): Agent 1 knows own choice, not other's.
    K1_K = list.map((func(P) = P),
        ["K1" - ("wCC" - ["wCC", "wCD"]),
         "K1" - ("wCD" - ["wCC", "wCD"]),
         "K1" - ("wDC" - ["wDC", "wDD"]),
         "K1" - ("wDD" - ["wDC", "wDD"])]),

    % B1 (Doxastic S4): Agent 1 believes they cooperate (even when wrong).
    B1_B = list.map((func(P) = P),
        ["B1" - ("wCC" - ["wCC"]),
         "B1" - ("wCD" - ["wCD"]),
         "B1" - ("wDC" - ["wCC"]),
         "B1" - ("wDD" - ["wCD"])]),

    % O1 (Deontic KD): Agent 1 ought to cooperate (ideal = wCC).
    O1_O = list.map((func(P) = P),
        ["O1" - ("wCC" - ["wCC"]),
         "O1" - ("wCD" - ["wCC"]),
         "O1" - ("wDC" - ["wCC"]),
         "O1" - ("wDD" - ["wCC"])]),

    % K2 (Epistemic S5): Agent 2 knows own choice, not other's.
    K2_K = list.map((func(P) = P),
        ["K2" - ("wCC" - ["wCC", "wDC"]),
         "K2" - ("wCD" - ["wCD", "wDD"]),
         "K2" - ("wDC" - ["wCC", "wDC"]),
         "K2" - ("wDD" - ["wCD", "wDD"])]),

    % B2 (Doxastic S4): Agent 2 believes they cooperate.
    B2_B = list.map((func(P) = P),
        ["B2" - ("wCC" - ["wCC"]),
         "B2" - ("wCD" - ["wDC"]),
         "B2" - ("wDC" - ["wDC"]),
         "B2" - ("wDD" - ["wCC"])]),

    % O2 (Deontic KD): Agent 2 ought to cooperate.
    O2_O = list.map((func(P) = P),
        ["O2" - ("wCC" - ["wCC"]),
         "O2" - ("wCD" - ["wCC"]),
         "O2" - ("wDC" - ["wCC"]),
         "O2" - ("wDD" - ["wCC"])]),

    AllRels = K1_K ++ B1_B ++ O1_O ++ K2_K ++ B2_B ++ O2_O,
    K = mm.mk_kripke(States, Labels, AllRels),

    Profiles = [
        "K1" - mm_multi.epistemic("K1"),
        "B1" - mm_multi.doxastic("B1"),
        "O1" - mm_multi.deontic("O1"),
        "K2" - mm_multi.epistemic("K2"),
        "B2" - mm_multi.doxastic("B2"),
        "O2" - mm_multi.deontic("O2")
    ],
    MP = mm_multi.mk_mm_profile(K, Profiles),

    io.write_string("== Grand Unified Multimodal Logic Demo ==\n", !IO),
    io.write_string("Two agents, cooperate/defect game.\n", !IO),
    io.write_string("K = epistemic (S5), B = doxastic (S4), O = deontic (KD)\n", !IO),
    io.nl(!IO),

    % Validate structural properties
    io.write_string("--- Structural Validation ---\n", !IO),
    Violations = mm_multi.validate(MP),
    ( if Violations = [] then
        io.write_string("  All relations satisfy their profiles. [ok]\n", !IO)
      else
        io.write_string("  VIOLATIONS:\n", !IO),
        print_violations(Violations, !IO)
    ),
    io.nl(!IO),

    % Epistemic
    io.write_string("--- Epistemic (Knowledge) ---\n", !IO),
    check(K, "K1(C1): Agent 1 knows they cooperate",
        mm.box("K1", mm.prop("C1")), !IO),
    check(K, "K1(C2): Agent 1 knows Agent 2 cooperates",
        mm.box("K1", mm.prop("C2")), !IO),
    check(K, "K2(C1): Agent 2 knows Agent 1 cooperates",
        mm.box("K2", mm.prop("C1")), !IO),
    check(K, "K2(C2): Agent 2 knows they cooperate",
        mm.box("K2", mm.prop("C2")), !IO),
    io.nl(!IO),

    % Doxastic
    io.write_string("--- Doxastic (Belief) ---\n", !IO),
    check(K, "B1(C1): Agent 1 BELIEVES they cooperate",
        mm.box("B1", mm.prop("C1")), !IO),
    check(K, "B2(C2): Agent 2 BELIEVES they cooperate",
        mm.box("B2", mm.prop("C2")), !IO),
    io.nl(!IO),

    % Deontic
    io.write_string("--- Deontic (Obligation) ---\n", !IO),
    check(K, "O1(C1): Agent 1 OUGHT to cooperate",
        mm.box("O1", mm.prop("C1")), !IO),
    check(K, "O2(C2): Agent 2 OUGHT to cooperate",
        mm.box("O2", mm.prop("C2")), !IO),
    io.nl(!IO),

    % Knowledge vs Belief
    io.write_string("--- Knowledge vs Belief ---\n", !IO),
    check(K, "K1(C1) & B1(C1): knows and believes",
        mm.conj(mm.box("K1", mm.prop("C1")),
                mm.box("B1", mm.prop("C1"))), !IO),
    check(K, "B1(C1) & ~K1(C1): believes but does NOT know",
        mm.conj(mm.box("B1", mm.prop("C1")),
                mm.neg(mm.box("K1", mm.prop("C1")))), !IO),
    check(K, "K1(C1) -> B1(C1): knowledge implies belief",
        mm.imp(mm.box("K1", mm.prop("C1")),
               mm.box("B1", mm.prop("C1"))), !IO),
    io.nl(!IO),

    % Obligation vs Reality
    io.write_string("--- Obligation vs Reality ---\n", !IO),
    check(K, "O1(C1) & K1(C1): ought to + actually does",
        mm.conj(mm.box("O1", mm.prop("C1")),
                mm.box("K1", mm.prop("C1"))), !IO),
    check(K, "O1(C1) & ~K1(C1): ought to but doesn't",
        mm.conj(mm.box("O1", mm.prop("C1")),
                mm.neg(mm.box("K1", mm.prop("C1")))), !IO),
    io.nl(!IO),

    % Belief vs Obligation
    io.write_string("--- Belief vs Obligation ---\n", !IO),
    check(K, "B1(C1) & O1(C1): believes + ought",
        mm.conj(mm.box("B1", mm.prop("C1")),
                mm.box("O1", mm.prop("C1"))), !IO),
    io.nl(!IO),

    % Nested cross-modalities
    io.write_string("--- Nested Cross-Modalities ---\n", !IO),
    check(K, "K1(B1(C1)): knows it believes it cooperates",
        mm.box("K1", mm.box("B1", mm.prop("C1"))), !IO),
    check(K, "B1(K1(C1)): believes it knows it cooperates",
        mm.box("B1", mm.box("K1", mm.prop("C1"))), !IO),
    check(K, "O1(B1(C1)): ought to believe it cooperates",
        mm.box("O1", mm.box("B1", mm.prop("C1"))), !IO),
    check(K, "K1(O1(C1)): knows it ought to cooperate",
        mm.box("K1", mm.box("O1", mm.prop("C1"))), !IO),
    io.nl(!IO),

    io.write_string("done.\n", !IO).

%----- output helpers -----%

:- pred print_violations(list(string)::in, io::di, io::uo) is det.
print_violations([], !IO).
print_violations([V | Vs], !IO) :-
    io.write_string("    ", !IO),
    io.write_string(V, !IO),
    io.nl(!IO),
    print_violations(Vs, !IO).

:- pred check(mm.kripke_m::in, string::in, mm.mmf::in,
    io::di, io::uo) is det.
check(K, Desc, F, !IO) :-
    S = mm.sat(K, F),
    io.format("  %-52s => %s\n",
        [s(Desc), s(set_to_string(S))], !IO).

:- func set_to_string(set(string)) = string.
set_to_string(S) =
    "{" ++ string.join_list(", ", set.to_sorted_list(S)) ++ "}".
