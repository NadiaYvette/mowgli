%---------------------------------------------------------------------------%
% social_mm.m — situated social multimodal observations.
%
% This is intentionally a boundary layer: raw vision/audio systems can
% serialize their outputs as observations, while the logical core consumes
% typed facts and produces a Kripke snapshot later.
%---------------------------------------------------------------------------%

:- module social_mm.

:- interface.

:- import_module bool.
:- import_module list.
:- import_module map.
:- import_module set.
:- import_module string.

:- type social_context
    ---> social_context(
        agents       :: set(string),
        groups       :: set(string),
        memberships  :: map(string, set(string)),
        roles        :: map(string, set(string)),
        common_ground :: set(string),
        observations :: list(observation)
    ).

:- type observation
    ---> speech(string, string, string, prosodic_force)
    ;    point(string, string, string)
    ;    gaze(string, string)
    ;    visible(string, string)
    ;    role_observation(string, string, string).

:- type prosodic_force
    ---> neutral
    ;    urgent
    ;    uncertain
    ;    private_tone.

:- func empty_context = social_context.
:- func add_agent(social_context, string) = social_context.
:- func add_group(social_context, string) = social_context.
:- func add_member(social_context, string, string) = social_context.
:- func add_role(social_context, string, string) = social_context.
:- func observe(social_context, observation) = social_context.
:- func accommodate(social_context, string) = social_context.
:- func known_by_all(social_context, set(string), string) = bool.
:- func visible_to(social_context, string, string) = bool.
:- func referent(social_context, string, string) = string.

:- implementation.

:- import_module bool.

empty_context = social_context(set.init, set.init, map.init, map.init,
    set.init, []).

add_agent(C, A) = C ^ agents := set.insert(C ^ agents, A).
add_group(C, G) = C ^ groups := set.insert(C ^ groups, G).

add_member(C, A, G) = C ^ memberships :=
    map.set(C ^ memberships, A,
        set.insert((if map.search(C ^ memberships, A, S) then S else set.init), G)).

add_role(C, A, R) = C ^ roles :=
    map.set(C ^ roles, A,
        set.insert((if map.search(C ^ roles, A, S) then S else set.init), R)).

observe(C, O) = C ^ observations := [O | C ^ observations].
accommodate(C, P) = C ^ common_ground := set.insert(C ^ common_ground, P).

known_by_all(C, Group, P) =
    ( if set.is_empty(Group) then no
      else all_known(set.to_sorted_list(Group), C, P)
    ).

:- func all_known(list(string), social_context, string) = bool.
all_known([], _, _) = yes.
all_known([A | As], C, P) =
    ( if set.member(P, C ^ common_ground) then all_known(As, C, P)
      else has_assertion(C ^ observations, A, P)
    ).

:- func has_assertion(list(observation), string, string) = bool.
has_assertion(Observations, Agent, Proposition) =
    ( if Observations = [] then no
      else if Observations = [speech(A, _, P, _) | _],
              A = Agent, P = Proposition then yes
      else if Observations = [_ | Rest] then
          has_assertion(Rest, Agent, Proposition)
      else no
    ).

visible_to(C, Object, Agent) = has_visibility(C ^ observations, Object, Agent).

:- func has_visibility(list(observation), string, string) = bool.
has_visibility(Observations, Object, Agent) =
    ( if Observations = [] then no
      else if Observations = [visible(O, A) | _],
              O = Object, A = Agent then yes
      else if Observations = [_ | Rest] then
          has_visibility(Rest, Object, Agent)
      else no
    ).

referent(C, Speaker, Hint) =
    ( if has_point(C ^ observations, Speaker, Hint) = yes then Hint
      else "unresolved"
    ).

:- func has_point(list(observation), string, string) = bool.
has_point(Observations, Agent, Hint) =
    ( if Observations = [] then no
      else if Observations = [point(A, O, H) | _], A = Agent,
              (O = Hint ; H = Hint) then yes
      else if Observations = [_ | Rest] then
          has_point(Rest, Agent, Hint)
      else no
    ).

:- end_module social_mm.
