:- module meshes_gold_scene_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module bool.
:- import_module film_episode.
:- import_module list.
:- import_module meshes_gold_scene_fixture.
:- import_module string.

main(!IO) :-
    Observations = meshes_gold_scene_fixture.observations,
    Relations = meshes_gold_scene_fixture.relations,
    Episode = film_episode.episode("Meshes of the Afternoon", 1943,
        Observations, Relations, [], []),
    io.write_string("== Meshes of the Afternoon: candidate gold scene ==\n", !IO),
    io.format("observations: %d; relations: %d; semantically valid: %s\n",
        [i(list.length(Observations)), i(list.length(Relations)),
         s(bool_to_string(film_episode.all_relations_are_valid(Episode)))], !IO),
    io.write_string("\nCross-modal links:\n", !IO),
    print_relations(film_episode.cross_modal_relations(Episode), !IO),
    io.write_string("\nEvents after the flower event (m02):\n", !IO),
    print_observations(
        film_episode.related_observations(Episode, "m02", film_episode.before), !IO).

:- func bool_to_string(bool) = string.
bool_to_string(yes) = "yes".
bool_to_string(no) = "no".

:- pred print_relations(list(film_episode.observation_relation)::in,
    io::di, io::uo) is det.
print_relations([], !IO).
print_relations([R | Rs], !IO) :-
    io.format("  %s -%s-> %s (%.2f; %s)\n",
        [s(film_episode.relation_source_id_of(R)),
         s(film_episode.relation_kind_name(film_episode.relation_kind_of(R))),
         s(film_episode.relation_target_id_of(R)),
         f(film_episode.relation_confidence_of(R)),
         s(film_episode.relation_provenance_of(R))], !IO),
    print_relations(Rs, !IO).

:- pred print_observations(list(film_episode.observation)::in,
    io::di, io::uo) is det.
print_observations([], !IO).
print_observations([O | Os], !IO) :-
    io.format("  %s [%d-%dms] %s\n",
        [s(film_episode.observation_id_of(O)),
         i(film_episode.observation_start_of(O)),
         i(film_episode.observation_end_of(O)),
         s(film_episode.observation_content_of(O))], !IO),
    print_observations(Os, !IO).

:- end_module meshes_gold_scene_demo.
