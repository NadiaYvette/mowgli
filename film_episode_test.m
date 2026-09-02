:- module film_episode_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module film_episode.
:- import_module list.
:- import_module require.

main(!IO) :-
    E = demo_episode,
    Opening = length(observations_between(E, 0, 12000)),
    ( if Opening = 2 then true else require.error("opening interval should contain two observations") ),
    Boundary = length(observations_between(E, 12000, 13000)),
    ( if Boundary = 4 then true else require.error("touching interval boundaries should overlap") ),
    Gap = observations_between(E, 19001, 19999),
    ( if Gap = [] then true else require.error("gap interval should contain no observations") ),
    Reversed = observations_between(E, 13000, 12000),
    ( if Reversed = [] then true else require.error("reversed interval should be rejected") ),
    Valid = interval_is_valid(0, 0),
    ( if Valid = yes then true else require.error("zero-length interval should be valid") ),
    Invalid = interval_is_valid(2, 1),
    ( if Invalid = no then true else require.error("reversed interval should be invalid") ),
    R = list.det_head(episode_readings(E)),
    SupportIds = observation_ids(supported_by(R, E)),
    ( if SupportIds = ["o1", "o2", "o4"] then true else require.error("support IDs should resolve in reading order") ),
    CounterIds = observation_ids(contested_by(R, E)),
    ( if CounterIds = ["o5"] then true else require.error("counterevidence IDs should resolve") ),
    io.write_string("film_episode_test: all checks passed\n", !IO).

:- end_module film_episode_test.
