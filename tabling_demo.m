% tabling_demo.m — show tabling sharing subcomputations.

:- module tabling_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int.
:- import_module list.
:- import_module pair.
:- import_module string.
:- import_module time.

:- import_module tabling.

main(!IO) :-
    io.write_string("== Tabling in Mercury (pragma memo) ==\n", !IO),
    io.nl(!IO),

    N = 16,
    io.format("Diamond DAG: s -> n1 -> n2 -> ... -> t with %d layers,\n",
        [i(N)], !IO),
    io.write_string("  2^n distinct paths but only O(n) distinct nodes\n", !IO),
    io.nl(!IO),

    G = diamond_dag(N),
    Cn = count_naive("s0", "t", G),
    io.format("  naive  count of s0 -> t paths = %d\n", [i(Cn)], !IO),
    Ct = count_tabled("s0", "t", G),
    io.format("  tabled count of s0 -> t paths = %d\n", [i(Ct)], !IO),
    ( if Cn = Ct then
        io.write_string("  ✓ both agree — same answer, different work\n", !IO)
      else
        io.write_string("  ✗ MISMATCH!\n", !IO)
    ),
    io.nl(!IO),

    % Time Runs recomputations of each. The naive one re-explores the
    % same sub-paths on every call; the tabled one answers from the memo
    % table after the first.
    time_naive(200, "s0", "t", G, Tnaive, !IO),
    io.format("  naive  count x200 = %d ms\n", [i(Tnaive)], !IO),
    time_tabled(200, "s0", "t", G, Ttabled, !IO),
    io.format("  tabled count x200 = %d ms\n", [i(Ttabled)], !IO),
    ( if Ttabled < Tnaive then
        io.format("  ✓ tabled %d ms faster (sub-paths shared, not re-explored)\n",
            [i(Tnaive - Ttabled)], !IO)
      else
        io.write_string("  (timings too coarse at this size — answers agree)\n", !IO)
    ),
    io.nl(!IO),
    io.write_string("done.\n", !IO).

:- pred time_naive(int::in, string::in, string::in,
    list(pair(string, string))::in, int::out, io::di, io::uo) is det.
time_naive(Runs, From, To, G, Ms, !IO) :-
    time.clock(T0, !IO),
    repeat_naive(Runs, From, To, G),
    time.clock(T1, !IO),
    Ms = (time.clock_t_to_int(T1) - time.clock_t_to_int(T0)) * 1000 // time.clocks_per_sec.

:- pred repeat_naive(int::in, string::in, string::in,
    list(pair(string, string))::in) is det.
repeat_naive(0, _, _, _).
repeat_naive(N, From, To, G) :-
    _ = count_naive(From, To, G),
    repeat_naive(N - 1, From, To, G).

:- pred time_tabled(int::in, string::in, string::in,
    list(pair(string, string))::in, int::out, io::di, io::uo) is det.
time_tabled(Runs, From, To, G, Ms, !IO) :-
    time.clock(T0, !IO),
    repeat_tabled(Runs, From, To, G),
    time.clock(T1, !IO),
    Ms = (time.clock_t_to_int(T1) - time.clock_t_to_int(T0)) * 1000 // time.clocks_per_sec.

:- pred repeat_tabled(int::in, string::in, string::in,
    list(pair(string, string))::in) is det.
repeat_tabled(0, _, _, _).
repeat_tabled(N, From, To, G) :-
    _ = count_tabled(From, To, G),
    repeat_tabled(N - 1, From, To, G).

:- end_module tabling_demo.
