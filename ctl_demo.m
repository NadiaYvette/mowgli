% ctl_demo.m — model-check a small Kripke structure.
%
%   States:  s0 (idle), s1 (in critical section), s2 (in critical section)
%   Labels:  s0: {}       s1: {crit}     s2: {crit}
%   Trans:   s0 -> s0 | s1 | s2
%            s1 -> s0
%            s2 -> s0
%
% Properties to check:
%   * crit              — which states are in the critical section.
%   * AG crit           — crit holds in every reachable state? (No: s0.)
%   * AG ~crit          — never enter crit? (No: s1, s2 are reachable.)
%   * EF crit           — crit is reachable? (Yes: from every state.)
%   * AF crit           — crit is inevitable on all paths? (No: s0 can
%                         loop on itself forever.)
%   * EG crit           — a path where crit holds forever? (No: s1, s2
%                         always return to s0.)
%   * AG (crit -> AF ~crit) — liveness: a state in crit always eventually
%                         leaves it.
%   * E[~crit U crit]   — stay out of crit until entering.

:- module ctl_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module set.
:- import_module string.

:- import_module ctl.

main(!IO) :-
    io.write_string("== CTL model checking in Mercury ==\n", !IO),
    io.nl(!IO),

    K = kripke(
        set.from_list(["s0", "s1", "s2"]),
        map.from_assoc_list([
            "s0" - [],
            "s1" - ["crit"],
            "s2" - ["crit"]
        ]),
        map.from_assoc_list([
            "s0" - ["s0", "s1", "s2"],
            "s1" - ["s0"],
            "s2" - ["s0"]
        ])
    ),

    check(K, "crit", prop("crit"), !IO),
    check(K, "AG crit (crit holds in every reachable state)",
        ag(prop("crit")), !IO),
    check(K, "AG ~crit (never in crit)",
        ag(neg(prop("crit"))), !IO),
    check(K, "EF crit (crit is reachable)",
        ef(prop("crit")), !IO),
    check(K, "AF crit (crit is inevitable on all paths)",
        af(prop("crit")), !IO),
    check(K, "EG crit (exists a path staying in crit forever)",
        eg(prop("crit")), !IO),
    check(K, "AG (crit -> AF ~crit) (liveness: always eventually leave)",
        ag(disj(neg(prop("crit")), af(neg(prop("crit"))))), !IO),
    check(K, "E[~crit U crit] (stay out of crit until entering)",
        eu(neg(prop("crit")), prop("crit")), !IO),
    io.nl(!IO),
    io.write_string("done.\n", !IO).

:- pred check(kripke::in, string::in, ctl::in, io::di, io::uo) is det.
check(K, Name, F, !IO) :-
    S = sat(K, F),
    io.format("  %-42s => %s\n", [s(Name), s(set_to_string(S))], !IO).

:- func set_to_string(set(string)) = string.
set_to_string(S) =
    "{" ++ string.join_list(", ", set.to_sorted_list(S)) ++ "}".

:- end_module ctl_demo.
