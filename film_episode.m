%---------------------------------------------------------------------------%
% film_episode.m -- small replayable audiovisual episode boundary.
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

:- func find_ids(list(string), list(observation)) = list(observation).
find_ids([], _) = [].
find_ids([Id | Ids], Observations) =
    find_by_id(Id, Observations) ++ find_ids(Ids, Observations).

:- func find_by_id(string, list(observation)) = list(observation).
find_by_id(_, []) = [].
find_by_id(Id, [O | Os]) =
    ( if observation_id_of(O) = Id then [O] else find_by_id(Id, Os) ).

:- end_module film_episode.
