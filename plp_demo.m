% plp_demo.m — run the PLP core on two classic examples.

:- module plp_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module float.
:- import_module list.
:- import_module pair.
:- import_module semiring.
:- import_module set.
:- import_module string.

:- import_module plp.

main(!IO) :-
    io.write_string("== Probabilistic logic in Mercury (distribution semantics) ==\n", !IO),
    io.nl(!IO),

    %--- Example 1: rain / sprinkler / wet grass (ProbLog classic) ---%
    io.write_string("Example 1: rain / sprinkler / wet grass\n", !IO),
    io.write_string("  0.7 :: rain.\n  0.6 :: sprinkler.\n  wet :- rain.\n  wet :- sprinkler.\n", !IO),
    io.nl(!IO),
    Prog1 = program(
        [prob("rain", 0.7), prob("sprinkler", 0.6)],
        [clause("wet", ["rain"]), clause("wet", ["sprinkler"])]),
    P_wet = marginal(Prog1, "wet"),
    P_rain = marginal(Prog1, "rain"),
    io.format("  P(wet)  = %.4f   (exact: 1 - 0.3*0.4 = 0.8800)\n",
        [f(P_wet)], !IO),
    io.format("  P(rain) = %.4f\n", [f(P_rain)], !IO),
    explanations(Prog1, "wet", Exps1),
    io.write_string("  explanations(wet): ", !IO),
    write_exps(Exps1, !IO),
    io.nl(!IO),
    combine_explanations(Prog1, Exps1, BoundF : float),
    io.format("  semiring float  (sum of explanation weights) = %.4f\n",
        [f(BoundF)], !IO),
    io.write_string("    ^ upper bound: explanations overlap, so it overcounts the exact 0.88\n", !IO),
    combine_explanations(Prog1, Exps1, Best : maxplus),
    combine_explanations(Prog1, Exps1, Cheapest : minplus),
    combine_explanations(Prog1, Exps1, Entails : bool),
    io.format("  semiring maxplus (best explanation weight) = %.4f\n",
        [f(unwrap_maxplus(Best))], !IO),
    io.format("  semiring minplus (cheapest explanation)    = %.4f\n",
        [f(unwrap_minplus(Cheapest))], !IO),
    io.format("  semiring bool    (entailment)              = %s\n",
        [s(bool_to_string(Entails))], !IO),
    io.nl(!IO),

    %--- Example 2: uncertain edges, path reachability ---%
    io.write_string("Example 2: uncertain graph edges\n", !IO),
    io.write_string("  0.8 :: edge(a,b).  0.7 :: edge(b,c).  0.6 :: edge(a,c).\n", !IO),
    io.write_string("  path(X,Y) :- edge(X,Y).\n  path(X,Z) :- edge(X,Y), path(Y,Z).\n", !IO),
    io.write_string("  query: path(a,c)\n", !IO),
    io.nl(!IO),
    Prog2 = program(
        [prob("edge(a,b)", 0.8), prob("edge(b,c)", 0.7), prob("edge(a,c)", 0.6)],
        [ clause("path(a,c)", ["edge(a,c)"]),
          clause("path(a,c)", ["edge(a,b)", "path(b,c)"]),
          clause("path(b,c)", ["edge(b,c)"]) ]),
    P_path = marginal(Prog2, "path(a,c)"),
    io.format("  P(path(a,c)) = %.4f   (exact: 0.6 + 0.4*0.8*0.7 = 0.8240)\n",
        [f(P_path)], !IO),
    explanations(Prog2, "path(a,c)", Exps2),
    io.write_string("  explanations(path(a,c)): ", !IO),
    write_exps(Exps2, !IO),
    io.nl(!IO),
    combine_explanations(Prog2, Exps2, BoundG : float),
    io.format("  semiring float (sum of explanation weights) = %.4f\n",
        [f(BoundG)], !IO),
    io.write_string("    ^ 0.6 + 0.8*0.7 = 1.16 — again the overlap overcount (exact is 0.824)\n", !IO),
    combine_explanations(Prog2, Exps2, Best2 : maxplus),
    io.format("  semiring maxplus (best explanation weight) = %.4f\n",
        [f(unwrap_maxplus(Best2))], !IO),
    combine_explanations(Prog2, Exps2, Cheapest2 : minplus),
    io.format("  semiring minplus (cheapest explanation)    = %.4f\n",
        [f(unwrap_minplus(Cheapest2))], !IO),
    io.nl(!IO),

    io.write_string("done.\n", !IO).

%----- helpers -----%

:- func unwrap_maxplus(maxplus) = float.
unwrap_maxplus(maxplus(X)) = X.

:- func unwrap_minplus(minplus) = float.
unwrap_minplus(minplus(X)) = X.

:- func bool_to_string(bool) = string.
bool_to_string(no) = "no".
bool_to_string(yes) = "yes".

:- pred write_exps(list(set(string))::in, io::di, io::uo) is det.
write_exps(Exps, !IO) :-
    io.write_char('{', !IO),
    write_exps_1(Exps, !IO),
    io.write_char('}', !IO).

:- pred write_exps_1(list(set(string))::in, io::di, io::uo) is det.
write_exps_1([], !IO).
write_exps_1([E | Es], !IO) :-
    ( if set.is_empty(E) then
        io.write_string("{}", !IO)
      else
        write_set(E, !IO)
    ),
    ( if Es = [] then
        true
      else
        io.write_string(", ", !IO),
        write_exps_1(Es, !IO)
    ).

:- pred write_set(set(string)::in, io::di, io::uo) is det.
write_set(E, !IO) :-
    io.write_char('{', !IO),
    io.write_string(string.join_list(", ", set.to_sorted_list(E)), !IO),
    io.write_char('}', !IO).

:- end_module plp_demo.
