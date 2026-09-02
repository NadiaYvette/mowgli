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
    Relations = film_annotation_fixture.relations,
    Count = list.length(Observations),
    ( if Count = 3 then true
      else require.error("generated fixture should contain three observations") ),
    RelationCount = list.length(Relations),
    ( if RelationCount = 2 then true
      else require.error("generated fixture should contain two relations") ),
    FirstId = film_episode.observation_id_of(list.det_head(Observations)),
    ( if FirstId = "o1" then true
      else require.error("generated fixture should preserve observation IDs") ),
    Episode = film_episode.episode("fixture", 1977, Observations, Relations, [], []),
    O1Relations = film_episode.relations_for_observation(Episode, "o1"),
    ( if list.length(O1Relations) = 2 then true
      else require.error("relation lookup should include both endpoints") ),
    Before = film_episode.related_observations(Episode, "o1", before),
    ( if film_episode.observation_ids(Before) = ["o3"] then true
      else require.error("before relation should resolve target") ),
    CrossModal = film_episode.cross_modal_relations(Episode),
    ( if list.length(CrossModal) = 1 then true
      else require.error("cross-modal query should exclude same-channel relations") ),
    ( if film_episode.all_relations_are_valid(Episode) = yes then true
      else require.error("generated relations should be semantically valid") ),
    io.write_string("film_annotation_fixture_test: all checks passed\n", !IO).

:- end_module film_annotation_fixture_test.
