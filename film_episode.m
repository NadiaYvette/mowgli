%---------------------------------------------------------------------------%
% film_episode.m -- replayable audiovisual episode boundary.
%---------------------------------------------------------------------------%

:- module film_episode.

:- interface.

:- import_module bool.
:- import_module int.
:- import_module list.
:- import_module string.

:- type channel
    --->    visual
    ;       audio
    ;       dialogue
    ;       music
    ;       editing
    ;       context.

:- type sign_kind
    --->    icon
    ;       index
    ;       symbol.

:- type relation_kind
    --->    before
    ;       after
    ;       overlaps
    ;       during
    ;       synchronized_with
    ;       contrasts_with
    ;       recurs_after.

:- type observation
    --->    observation(
                observation_id :: string,
                observation_start_ms :: int,
                observation_end_ms :: int,
                observation_channel :: channel,
                observation_content :: string,
                observation_confidence :: float,
                observation_provenance :: string
            ).

:- type observation_relation
    --->    observation_relation(
                relation_source_id :: string,
                relation_kind :: relation_kind,
                relation_target_id :: string,
                relation_confidence :: float,
                relation_provenance :: string
            ).

:- type sign_candidate
    --->    sign_candidate(
                sign_observation_id :: string,
                sign_kind :: sign_kind,
                sign_interpretation :: string,
                sign_confidence :: float
            ).

:- type reading
    --->    reading(
                reading_claim :: string,
                reading_support :: list(string),
                reading_counterevidence :: list(string),
                reading_alternatives :: list(string),
                reading_confidence :: float
            ).

:- type episode
    --->    episode(
                episode_title :: string,
                episode_year :: int,
                episode_observations :: list(observation),
                episode_relations :: list(observation_relation),
                episode_signs :: list(sign_candidate),
                episode_readings :: list(reading)
            ).

:- func demo_episode = episode.
:- func observations_between(episode, int, int) = list(observation).
:- func observation_ids(list(observation)) = list(string).
:- func supported_by(reading, episode) = list(observation).
:- func contested_by(reading, episode) = list(observation).
:- func observation_id_of(observation) = string.
:- func observation_start_of(observation) = int.
:- func observation_end_of(observation) = int.
:- func observation_content_of(observation) = string.
:- func observation_confidence_of(observation) = float.
:- func observation_provenance_of(observation) = string.
:- func interval_is_valid(int, int) = bool.
:- func reading_support_ids(reading) = list(string).
:- func reading_counterevidence_ids(reading) = list(string).
:- func relation_source_id_of(observation_relation) = string.
:- func relation_kind_of(observation_relation) = relation_kind.
:- func relation_target_id_of(observation_relation) = string.
:- func relation_confidence_of(observation_relation) = float.
:- func relation_provenance_of(observation_relation) = string.
:- func relations_for_observation(episode, string) = list(observation_relation).
:- func related_observations(episode, string, relation_kind) = list(observation).
:- func cross_modal_relations(episode) = list(observation_relation).
:- func relation_kind_name(relation_kind) = string.

:- implementation.

 demo_episode = episode(
    "Eraserhead (replay scaffold)", 1977,
    [
        observation("o1", 0, 12000, visual,
            "confined industrial interior", 0.98, "annotator:fixture"),
        observation("o2", 0, 12000, audio,
            "continuous industrial drone", 0.96, "annotator:fixture"),
        observation("o3", 13000, 19000, visual,
            "small domestic room with bodily imagery", 0.91,
            "annotator:fixture"),
        observation("o4", 13000, 19000, audio,
            "industrial drone recurs beneath domestic scene", 0.89,
            "annotator:fixture"),
        observation("o5", 20000, 24000, editing,
            "abrupt transition with dreamlike continuity", 0.76,
            "annotator:fixture")
    ],
    [
        observation_relation("o1", before, "o3", 0.99, "derived:intervals"),
        observation_relation("o2", synchronized_with, "o1", 0.93,
            "annotator:fixture"),
        observation_relation("o2", recurs_after, "o4", 0.81,
            "annotator:fixture"),
        observation_relation("o1", contrasts_with, "o5", 0.65,
            "annotator:fixture")
    ],
    [
        sign_candidate("o1", index,
            "industrial environment frames the protagonist's situation", 0.72),
        sign_candidate("o2", index,
            "recurring sound may connect separate spaces", 0.81),
        sign_candidate("o3", icon,
            "bodily imagery resembles an embodied vulnerability", 0.61),
        sign_candidate("o5", symbol,
            "formal disruption invites a reality/dream distinction", 0.68)
    ],
    [
        reading(
            "The episode supports a reading involving industrial and social anxiety.",
            ["o1", "o2", "o4"], ["o5"],
            ["psychological reading", "surrealist reading"], 0.74),
        reading(
            "The episode destabilizes the boundary between ordinary and dreamlike experience.",
            ["o3", "o5"], ["o1"],
            ["industrial reading", "embodiment reading"], 0.69)
    ]
).

observations_between(Episode, Start, End) =
    ( if interval_is_valid(Start, End) = yes then
        filter_interval(Start, End, episode_observations(Episode))
      else
        []
    ).

interval_is_valid(Start, End) =
    ( if Start =< End then yes else no ).

:- func filter_interval(int, int, list(observation)) = list(observation).
filter_interval(_, _, []) = [].
filter_interval(Start, End, [O | Os]) =
    ( if observation_end(O) >= Start, observation_start(O) =< End then
        [O | filter_interval(Start, End, Os)]
      else
        filter_interval(Start, End, Os)
    ).

observation_ids(Observations) =
    list.map(observation_id_of, Observations).

observation_id_of(observation(Id, _, _, _, _, _, _)) = Id.

observation_start_of(O) = observation_start(O).

:- func observation_start(observation) = int.
observation_start(observation(_, Start, _, _, _, _, _)) = Start.

observation_end_of(O) = observation_end(O).

:- func observation_end(observation) = int.
observation_end(observation(_, _, End, _, _, _, _)) = End.

observation_content_of(observation(_, _, _, _, Content, _, _)) = Content.
observation_confidence_of(observation(_, _, _, _, _, Confidence, _)) = Confidence.
observation_provenance_of(observation(_, _, _, _, _, _, Provenance)) = Provenance.

reading_support_ids(R) = reading_support(R).
reading_counterevidence_ids(R) = reading_counterevidence(R).

supported_by(R, E) =
    find_ids(reading_support_ids(R), episode_observations(E)).

contested_by(R, E) =
    find_ids(reading_counterevidence_ids(R), episode_observations(E)).

relation_source_id_of(observation_relation(Source, _, _, _, _)) = Source.
relation_kind_of(observation_relation(_, Kind, _, _, _)) = Kind.
relation_target_id_of(observation_relation(_, _, Target, _, _)) = Target.
relation_confidence_of(observation_relation(_, _, _, Confidence, _)) = Confidence.
relation_provenance_of(observation_relation(_, _, _, _, Provenance)) = Provenance.

relations_for_observation(E, Id) =
    find_relations(Id, episode_relations(E)).

:- func find_relations(string, list(observation_relation)) = list(observation_relation).
find_relations(_, []) = [].
find_relations(Id, [R | Rs]) =
    ( if relation_source_id_of(R) = Id ; relation_target_id_of(R) = Id then
        [R | find_relations(Id, Rs)]
      else
        find_relations(Id, Rs)
    ).

related_observations(E, Id, Kind) =
    find_related_ids(Kind, episode_relations(E), Id,
        episode_observations(E)).

:- func find_related_ids(relation_kind, list(observation_relation), string,
    list(observation)) = list(observation).
find_related_ids(_, [], _, _) = [].
find_related_ids(Kind, [R | Rs], Id, Observations) =
    ( if relation_kind_of(R) = Kind, relation_source_id_of(R) = Id then
        find_by_id(relation_target_id_of(R), Observations) ++
            find_related_ids(Kind, Rs, Id, Observations)
      else
        find_related_ids(Kind, Rs, Id, Observations)
    ).

cross_modal_relations(E) =
    find_cross_modal(episode_relations(E), episode_observations(E)).

:- func find_cross_modal(list(observation_relation), list(observation)) = list(observation_relation).
find_cross_modal([], _) = [].
find_cross_modal([R | Rs], Observations) =
    ( if channels_differ(source_channel(R, Observations), target_channel(R, Observations)) = yes then
        [R | find_cross_modal(Rs, Observations)]
      else
        find_cross_modal(Rs, Observations)
    ).

:- func source_channel(observation_relation, list(observation)) = channel.
source_channel(R, Observations) = channel_for_id(relation_source_id_of(R), Observations).

:- func target_channel(observation_relation, list(observation)) = channel.
target_channel(R, Observations) = channel_for_id(relation_target_id_of(R), Observations).

:- func channel_for_id(string, list(observation)) = channel.
channel_for_id(Id, [O | Os]) =
    ( if observation_id_of(O) = Id then observation_channel(O)
      else channel_for_id(Id, Os)
    ).
channel_for_id(_, []) = context.

:- func channels_differ(channel, channel) = bool.
channels_differ(A, B) =
    ( if A = B then no else yes ).

relation_kind_name(before) = "before".
relation_kind_name(after) = "after".
relation_kind_name(overlaps) = "overlaps".
relation_kind_name(during) = "during".
relation_kind_name(synchronized_with) = "synchronized_with".
relation_kind_name(contrasts_with) = "contrasts_with".
relation_kind_name(recurs_after) = "recurs_after".

:- func find_ids(list(string), list(observation)) = list(observation).
find_ids([], _) = [].
find_ids([Id | Ids], Observations) =
    find_by_id(Id, Observations) ++ find_ids(Ids, Observations).

:- func find_by_id(string, list(observation)) = list(observation).
find_by_id(_, []) = [].
find_by_id(Id, [O | Os]) =
    ( if observation_id_of(O) = Id then [O] else find_by_id(Id, Os) ).

:- end_module film_episode.
