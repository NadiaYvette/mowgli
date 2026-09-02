% naf_demo.m — stratified negation-as-failure in the PLP core.

:- module naf_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module exception.
:- import_module float.
:- import_module list.
:- import_module set.
:- import_module string.

:- import_module plp.
:- import_module plp_naf.

main(!IO) :-
    io.write_string("== Negation-as-failure (stratified) in PLP ==\n", !IO),
    io.nl(!IO),

    %--- Example 1: rain / sprinkler / wet, plus dry :- not wet ---%
    io.write_string("Example 1: stratified\n", !IO),
    io.write_string("  0.7 :: rain.  0.6 :: sprinkler.\n", !IO),
    io.write_string("  wet :- rain.  wet :- sprinkler.\n", !IO),
    io.write_string("  dry :- not wet.\n", !IO),
    io.nl(!IO),
    N1 = naf_program(
        [prob("rain", 0.7), prob("sprinkler", 0.6)],
        [ naf_clause("wet", [pos("rain")]),
          naf_clause("wet", [pos("sprinkler")]),
          naf_clause("dry", [neg("wet")]) ]),
    Pw = plp_naf.marginal(N1, "wet"),
    io.format("  P(wet) = %.4f   (exact: 1 - 0.3*0.4 = 0.8800)\n", [f(Pw)], !IO),
    Pd = plp_naf.marginal(N1, "dry"),
    io.format("  P(dry) = %.4f   (exact: 1 - 0.88 = 0.1200)\n", [f(Pd)], !IO),
    io.write_string("  dry is true exactly when wet is false\n", !IO),
    io.nl(!IO),

    %--- Example 2: non-stratified program (must be rejected) ---%
    io.write_string("Example 2: negation cycle (must be rejected)\n", !IO),
    io.write_string("  p :- not q.   q :- not p.\n", !IO),
    io.nl(!IO),
    N2 = naf_program(
        [],
        [ naf_clause("p", [neg("q")]),
          naf_clause("q", [neg("p")]) ]),
    io.write_string("  ", !IO),
    io.flush_output(!IO),
    try_model(N2, Accepted, Msg),
    ( if Accepted = yes then
        io.write_string("(unexpectedly accepted)\n", !IO)
      else
        io.format("rejected as expected: %s\n", [s(Msg)], !IO)
    ),
    io.nl(!IO),
    io.write_string("done.\n", !IO).

    % Run `model' and report whether it threw a software error.
:- pred try_model(naf_program::in, bool::out, string::out) is det.
try_model(NP, Accepted, Msg) :-
    promise_equivalent_solutions [Result] (
        exception.try(
            (pred(Out::out) is cc_multi :-
                Out = model(NP, set.init)),
            Result)
    ),
    ( if Result = exception.succeeded(_) then
        Accepted = yes,
        Msg = ""
      else if Result = exception.failed then
        Accepted = no,
        Msg = "(failed without exception)"
      else if Result = exception.exception(Univ) then
        ( if exception.exc_univ_to_type(Univ, exception.software_error(M)) then
            Accepted = no,
            Msg = M
          else
            Accepted = no,
            Msg = "(non-software error)"
        )
      else
        Accepted = no,
        Msg = "(unknown)"
    ).

:- end_module naf_demo.
