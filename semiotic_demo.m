%---------------------------------------------------------------------------%
% semiotic_demo.m — Peircean semiotic modalities on a game-theory scenario.
%
% Two agents deciding to cooperate/defect. Each agent interprets the
% game through three semiotic lenses:
%
%   Ic_i (Iconic):   What agent i recognizes by RESEMBLANCE
%     "This situation looks like a prisoner's dilemma"
%     Axioms: B/D (serial, symmetric) — pure quality recognition
%
%   Ix_i (Indexical): What agent i infers by CAUSAL CONNECTION
%     "If I defect, the other agent will see this and defect too"
%     Axioms: T/D (factive, serial) — causal/existential link
%
%   Sy_i (Symbolic): What agent i understands by CONVENTION
%     "Cooperation is the socially optimal strategy"
%     Axioms: S4 (reflexive, transitive) — law/convention-based
%
% Interaction axioms (from Peirce's theory):
%   Ix -> Ic   (indexicality presupposes iconicity)
%   Sy -> Ix   (symbolism presupposes indexical grounding)
%   K -> Sy    (knowledge implies symbolic understanding)
%
% This is Strategy A from SEMIOTICS_RESEARCH.md: sign types as
% modality profiles on a shared Kripke structure.
%---------------------------------------------------------------------------%

:- module semiotic_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
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
        "wCC" - ["C1", "C2", "cooperative"],
        "wCD" - ["C1", "defecting2"],
        "wDC" - ["C2", "defecting1"],
        "wDD" - ["defecting1", "defecting2"]
    ]),

    % Ic1 (Iconic): Agent 1 recognizes situations by resemblance.
    %   "This looks like cooperation / defection / mutual destruction"
    Ic1 = list.map((func(P) = P),
        ["Ic1" - ("wCC" - ["wCC"]),            % looks like cooperation
         "Ic1" - ("wCD" - ["wCD"]),            % looks like 1-cooperate
         "Ic1" - ("wDC" - ["wDC"]),            % looks like 1-defect
         "Ic1" - ("wDD" - ["wDD"])]),          % looks like mutual defect

    % Ix1 (Indexical): Agent 1 infers by causal connection.
    %   "If I cooperate, I can cause cooperation (wCC) or get exploited (wCD)"
    %   "If I defect, I can exploit (wDC) or cause mutual defect (wDD)"
    % Serial: every state has at least one causal consequence.
    % Factive: the actual state is always among the consequences.
    Ix1 = list.map((func(P) = P),
        ["Ix1" - ("wCC" - ["wCC", "wCD"]),     % cooperate: see both outcomes
         "Ix1" - ("wCD" - ["wCD", "wCC"]),     % can infer cooperation was possible
         "Ix1" - ("wDC" - ["wDC", "wDD"]),     % defect: see both outcomes
         "Ix1" - ("wDD" - ["wDD", "wDC"])]),   % can infer defection happened

    % Sy1 (Symbolic): Agent 1 understands by convention/norm.
    %   "Cooperation is the convention; defection violates the norm"
    %   Reflexive + transitive: conventional understanding is stable.
    Sy1 = list.map((func(P) = P),
        ["Sy1" - ("wCC" - ["wCC"]),             % cooperative is the norm
         "Sy1" - ("wCD" - ["wCD", "wCC"]),     % can reason from norm
         "Sy1" - ("wDC" - ["wDC", "wCC"]),     % norm is always accessible
         "Sy1" - ("wDD" - ["wDD", "wCC"])]),   % even from defect, norm exists

    % Ic2 (Iconic): Agent 2 recognizes by resemblance.
    Ic2 = list.map((func(P) = P),
        ["Ic2" - ("wCC" - ["wCC"]),
         "Ic2" - ("wCD" - ["wCD"]),
         "Ic2" - ("wDC" - ["wDC"]),
         "Ic2" - ("wDD" - ["wDD"])]),

    % Ix2 (Indexical): Agent 2 infers by causal connection.
    Ix2 = list.map((func(P) = P),
        ["Ix2" - ("wCC" - ["wCC", "wDC"]),
         "Ix2" - ("wCD" - ["wCD", "wDD"]),
         "Ix2" - ("wDC" - ["wDC", "wCC"]),
         "Ix2" - ("wDD" - ["wDD", "wCD"])]),

    % Sy2 (Symbolic): Agent 2 understands by convention.
    Sy2 = list.map((func(P) = P),
        ["Sy2" - ("wCC" - ["wCC"]),
         "Sy2" - ("wCD" - ["wCD", "wCC"]),
         "Sy2" - ("wDC" - ["wDC", "wCC"]),
         "Sy2" - ("wDD" - ["wDD", "wCC"])]),

    AllRels = Ic1 ++ Ix1 ++ Sy1 ++ Ic2 ++ Ix2 ++ Sy2,
    K = mm.mk_kripke(States, Labels, AllRels),

    Profiles = [
        "Ic1" - modality_type("Ic1", yes, no, yes),   % Iconic: B/D
        "Ix1" - modality_type("Ix1", yes, no, no),   % Indexical: T/D
        "Sy1" - modality_type("Sy1", yes, yes, no),   % Symbolic: S4
        "Ic2" - modality_type("Ic2", yes, no, yes),   % Iconic: B/D
        "Ix2" - modality_type("Ix2", yes, no, no),   % Indexical: T/D
        "Sy2" - modality_type("Sy2", yes, yes, no)    % Symbolic: S4
    ],
    MP = mm_multi.mk_mm_profile(K, Profiles),

    io.write_string("== Semiotic Modal Logic Demo ==\n", !IO),
    io.write_string("Peircean icon/index/symbol modalities on a game.\n", !IO),
    io.write_string("Ic = iconic (resemblance), Ix = indexical (causal)\n", !IO),
    io.write_string("Sy = symbolic (convention)\n", !IO),
    io.nl(!IO),

    % Validate
    io.write_string("--- Structural Validation ---\n", !IO),
    Violations = mm_multi.validate(MP),
    ( if Violations = [] then
        io.write_string("  All relations satisfy their profiles. [ok]\n", !IO)
      else
        io.write_string("  VIOLATIONS:\n", !IO),
        print_violations(Violations, !IO)
    ),
    io.nl(!IO),

    % Iconic
    io.write_string("--- Iconic (Resemblance) ---\n", !IO),
    check(K, "Ic1(cooperative): 1 recognizes cooperation",
        mm.box("Ic1", mm.prop("cooperative")), !IO),
    check(K, "Ic2(cooperative): 2 recognizes cooperation",
        mm.box("Ic2", mm.prop("cooperative")), !IO),
    check(K, "dia(Ic1, cooperative): 1 sees cooperation as possible",
        mm.dia("Ic1", mm.prop("cooperative")), !IO),
    io.nl(!IO),

    % Indexical
    io.write_string("--- Indexical (Causal) ---\n", !IO),
    check(K, "Ix1(C1): 1's actions causally connect to their cooperation",
        mm.box("Ix1", mm.prop("C1")), !IO),
    check(K, "Ix2(C2): 2's actions causally connect to their cooperation",
        mm.box("Ix2", mm.prop("C2")), !IO),
    check(K, "Ix1(defecting1): 1 infers they defect (causal)",
        mm.box("Ix1", mm.prop("defecting1")), !IO),
    io.nl(!IO),

    % Symbolic
    io.write_string("--- Symbolic (Convention) ---\n", !IO),
    check(K, "Sy1(C1): 1 understands cooperation as the convention",
        mm.box("Sy1", mm.prop("C1")), !IO),
    check(K, "Sy2(C2): 2 understands cooperation as the convention",
        mm.box("Sy2", mm.prop("C2")), !IO),
    check(K, "Sy1(cooperative): 1 symbolically recognizes cooperation",
        mm.box("Sy1", mm.prop("cooperative")), !IO),
    io.nl(!IO),

    % Cross-semiotic: Iconic vs Indexical
    io.write_string("--- Iconic vs Indexical ---\n", !IO),
    check(K, "Ic1(C1) & Ix1(C1): recognizes and causally infers",
        mm.conj(mm.box("Ic1", mm.prop("C1")),
                mm.box("Ix1", mm.prop("C1"))), !IO),
    check(K, "Ic1(C1) & ~Ix1(C1): recognizes but doesn't causally infer",
        mm.conj(mm.box("Ic1", mm.prop("C1")),
                mm.neg(mm.box("Ix1", mm.prop("C1")))), !IO),
    io.nl(!IO),

    % Cross-semiotic: Symbolic vs Actual
    io.write_string("--- Symbolic vs Actual ---\n", !IO),
    check(K, "Sy1(C1) & Ix1(C1): conventionally understands and actually does",
        mm.conj(mm.box("Sy1", mm.prop("C1")),
                mm.box("Ix1", mm.prop("C1"))), !IO),
    check(K, "Sy1(C1) & ~Ix1(C1): conventionally understands but doesn't causally",
        mm.conj(mm.box("Sy1", mm.prop("C1")),
                mm.neg(mm.box("Ix1", mm.prop("C1")))), !IO),
    io.nl(!IO),

    % Nested semiotic
    io.write_string("--- Nested Semiotic ---\n", !IO),
    check(K, "Ic1(Ix1(C1)): iconic recognition of indexical inference",
        mm.box("Ic1", mm.box("Ix1", mm.prop("C1"))), !IO),
    check(K, "Sy1(Ic1(C1)): symbolic understanding of iconic recognition",
        mm.box("Sy1", mm.box("Ic1", mm.prop("C1"))), !IO),
    check(K, "Ix1(Sy1(C1)): indexical inference of symbolic convention",
        mm.box("Ix1", mm.box("Sy1", mm.prop("C1"))), !IO),
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
    io.format("  %-58s => %s\n",
        [s(Desc), s(set_to_string(S))], !IO).

:- func set_to_string(set(string)) = string.
set_to_string(S) =
    "{" ++ string.join_list(", ", set.to_sorted_list(S)) ++ "}".
