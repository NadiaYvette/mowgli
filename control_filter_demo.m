:- module control_filter_demo.

:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module control_filter.
:- import_module float.
:- import_module int.
:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module string.

main(!IO) :-
    io.write_string("== Filter + Control Demo ==\n", !IO),
    io.write_string("Finite Bayesian belief, actuator model, greedy policy\n\n", !IO),
    Initial = map.from_assoc_list([pair(control_filter.on, 0.5),
        pair(control_filter.off, 0.5)]),
    run(1, 8, Initial, !IO).

:- pred run(int::in, int::in, map(control_filter.state, float)::in, io::di, io::uo) is det.
run(T, Last, Belief0, !IO) :-
    ( if T > Last then
        true
      else
        Observation = observation(T),
        Predicted = predict(Belief0, wait),
        Posterior = normalise(update(Predicted, Observation)),
        Action = choose_action(Posterior, 0.70),
        io.format("t%d obs=%s P(on)=%.4f action=%s\n",
            [i(T), s(Observation), f(probability(Posterior, control_filter.on)),
             s(action_name(Action))], !IO),
        run(T + 1, Last, posterior_after_action(Posterior, Action), !IO)
    ).

:- func posterior_after_action(map(control_filter.state, float), action) = map(control_filter.state, float).
posterior_after_action(Belief, switch_on) = normalise(predict(Belief, switch_on)).
posterior_after_action(Belief, wait) = normalise(predict(Belief, wait)).

:- func observation(int) = string.
observation(T) =
    ( if T = 3 then "dark" else if T = 6 then "dark" else "bright" ).

:- end_module control_filter_demo.
