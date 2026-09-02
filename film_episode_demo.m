:- module film_episode_demo.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module film_episode.
:- import_module float.
:- import_module int.
:- import_module list.
:- import_module string.

main(!IO) :-
    E = film_episode.demo_episode,
    io.format("== Film episode replay: %s (%d) ==\n",
        [s(episode_title(E)), i(episode_year(E))], !IO),
    io.write_string("\nObservations in the opening interval:\n", !IO),
    Opening = film_episode.observations_between(E, 0, 12000),
    print_observations(Opening, !IO),
    io.write_string("\nTemporal and cross-modal relations:\n", !IO),
    print_relations(episode_relations(E), !IO),
    io.format("  cross-modal relation count: %d\n",
        [i(list.length(film_episode.cross_modal_relations(E)))], !IO),
    io.write_string("\nCompeting evidence-grounded readings:\n", !IO),
    print_readings(episode_readings(E), E, !IO).

:- pred print_observations(list(film_episode.observation)::in,
    io::di, io::uo) is det.
print_observations([], !IO).
print_observations([O | Os], !IO) :-
    io.format("  %s [%d-%dms] %s (confidence %.2f; %s)\n",
        [s(observation_id_of(O)), i(observation_start_of(O)),
         i(observation_end_of(O)), s(observation_content_of(O)),
         f(observation_confidence_of(O)), s(observation_provenance_of(O))], !IO),
    print_observations(Os, !IO).

:- pred print_readings(list(film_episode.reading)::in,
    film_episode.episode::in, io::di, io::uo) is det.
print_readings([], _, !IO).
print_readings([R | Rs], E, !IO) :-
    Support = film_episode.supported_by(R, E),
    Counter = film_episode.contested_by(R, E),
    io.format("  %s\n", [s(reading_claim(R))], !IO),
    io.format("    support: %s\n", [s(join_ids(Support))], !IO),
    io.format("    counterevidence: %s\n", [s(join_ids(Counter))], !IO),
    io.format("    alternatives: %s\n", [s(string.join_list(", ", reading_alternatives(R)))], !IO),
    io.format("    confidence: %.2f\n", [f(reading_confidence(R))], !IO),
    print_readings(Rs, E, !IO).

:- pred print_relations(list(film_episode.observation_relation)::in,
    io::di, io::uo) is det.
print_relations([], !IO).
print_relations([R | Rs], !IO) :-
    io.format("  %s -%s-> %s (confidence %.2f; %s)\n",
        [s(film_episode.relation_source_id_of(R)),
         s(film_episode.relation_kind_name(film_episode.relation_kind_of(R))),
         s(film_episode.relation_target_id_of(R)),
         f(film_episode.relation_confidence_of(R)),
         s(film_episode.relation_provenance_of(R))], !IO),
    print_relations(Rs, !IO).

:- func join_ids(list(film_episode.observation)) = string.
join_ids(Os) = string.join_list(", ", film_episode.observation_ids(Os)).

:- end_module film_episode_demo.
