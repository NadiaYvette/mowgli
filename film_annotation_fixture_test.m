:- module film_annotation_fixture_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module film_annotation_fixture.
:- import_module film_episode.
:- import_module list.
:- import_module require.

main(!IO) :-
    Observations = film_annotation_fixture.observations,
    Count = list.length(Observations),
    ( if Count = 3 then true else require.error("generated fixture should contain three observations") ),
    FirstId = film_episode.observation_id_of(list.det_head(Observations)),
    ( if FirstId = "o1" then true else require.error("generated fixture should preserve observation IDs") ),
    io.write_string("film_annotation_fixture_test: all checks passed\n", !IO).

:- end_module film_annotation_fixture_test.
