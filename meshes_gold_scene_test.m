:- module meshes_gold_scene_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module film_episode.
:- import_module list.
:- import_module meshes_gold_scene_fixture.
:- import_module require.

main(!IO) :-
    Observations = meshes_gold_scene_fixture.observations,
    Relations = meshes_gold_scene_fixture.relations,
    ( if list.length(Observations) = 8 then true
      else require.error("Meshes fixture should contain eight observations") ),
    ( if list.length(Relations) = 8 then true
      else require.error("Meshes fixture should contain eight relations") ),
    Episode = film_episode.episode("Meshes of the Afternoon", 1943,
        Observations, Relations, [], []),
    ( if film_episode.all_relations_are_valid(Episode) = yes then true
      else require.error("Meshes fixture relations should be semantically valid") ),
    Before = film_episode.related_observations(Episode, "m02", before),
    ( if film_episode.observation_ids(Before) = ["m03"] then true
      else require.error("before query should resolve the key event") ),
    During = film_episode.related_observations(Episode, "m03", during),
    ( if film_episode.observation_ids(During) = ["m08"] then true
      else require.error("during query should resolve the scene context") ),
    Synced = film_episode.related_observations(Episode, "m05", synchronized_with),
    ( if film_episode.observation_ids(Synced) = ["m06"] then true
      else require.error("synchronization query should resolve the score") ),
    CrossModal = film_episode.cross_modal_relations(Episode),
    ( if list.length(CrossModal) = 4 then true
      else require.error("cross-modal query should find all four cross-modal links") ),
    io.write_string("meshes_gold_scene_test: all checks passed\n", !IO).

:- end_module meshes_gold_scene_test.
