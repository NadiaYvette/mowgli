:- module control_filter.

:- interface.

:- import_module map.

:- type state ---> on ; off.
:- type action ---> switch_on ; wait.

:- func state_name(state) = string.
:- func action_name(action) = string.
:- func predict(map(state, float), action) = map(state, float).
:- func update(map(state, float), string) = map(state, float).
:- func normalise(map(state, float)) = map(state, float).
:- func choose_action(map(state, float), float) = action.
:- func probability(map(state, float), state) = float.

:- implementation.

:- import_module float.

state_name(on) = "on".
state_name(off) = "off".

action_name(switch_on) = "switch_on".
action_name(wait) = "wait".

predict(Belief, switch_on) =
    map.set(map.set(Belief, on, 0.90), off, 0.10).
predict(Belief, wait) =
    map.set(map.set(Belief, on, map.lookup(Belief, on) * 0.98),
        off, map.lookup(Belief, off) * 1.02).

update(Belief, Observation) =
    map.set(map.set(Belief, on,
        map.lookup(Belief, on) * likelihood(Observation, on)),
        off, map.lookup(Belief, off) * likelihood(Observation, off)).

:- func likelihood(string, state) = float.
likelihood(Observation, State) =
    ( if Observation = "bright" then
        ( if State = on then 0.90 else 0.20 )
      else if Observation = "dark" then
        ( if State = on then 0.10 else 0.80 )
      else
        1.0
    ).

normalise(Belief) = Out :-
    Total = map.lookup(Belief, on) + map.lookup(Belief, off),
    ( if Total < 0.000000000001 then
        Out = map.set(map.set(Belief, on, 0.5), off, 0.5)
      else
        Out = map.set(map.set(Belief, on, map.lookup(Belief, on) / Total),
            off, map.lookup(Belief, off) / Total)
    ).

choose_action(Belief, Threshold) =
    ( if map.lookup(Belief, on) < Threshold then switch_on else wait ).

probability(Belief, State) = map.lookup(Belief, State).

:- end_module control_filter.
