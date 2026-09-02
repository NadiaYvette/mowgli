%---------------------------------------------------------------------------%
% ec.m — a discrete fluent_event calculus (Kowalski & Sergot 1986, miniature).
%
% Events initiate and terminate fluents at integer ticks. A fluent
% holds at time T iff the last fluent_event affecting it before-or-at T
% initiated it:
%
%     initiated_at(F, T) :- happens(E, T), initiates(E, F).
%     terminated_at(F, T) :- happens(E, T), terminates(E, F).
%     holds_at(F, T) :- initiated_at(F, T1), T1 =< T,
%                       not ( terminated_at(F, T2), T1 < T2, T2 =< T ).
%
% The fluent_event list is assumed to arrive in chronological order (as a
% sensor stream would). `holding/2` walks the stream once and answers
% holds_at for every fluent simultaneously — the standard linear-time
% EC query evaluation.
%
% This is the dynamic-ontology update rule from ONTOLOGY_RESEARCH.md:
% each sensor tick produces observations; observations grounded in
% physical causation initiate/terminate fluents; the set of holding
% fluents is what gets asserted into the Kripke model's label map.
% Ontology growth happens when an observation matches no existing
% vocabulary — see grounding_demo.m.
%---------------------------------------------------------------------------%

:- module ec.

:- interface.

:- import_module list.
:- import_module mm.
:- import_module set.

    % A primitive fluent_event: make fluent F start (or stop) being true.
:- type fluent_event
    --->    initiate(string)
    ;       terminate(string).

    % The set of fluents holding at tick T, given a chronological
    % fluent_event stream (all events at ticks =< T are in force; the demo
    % simply grows the list as time advances).
:- func holding(list(fluent_event)) = set(string).    % Apply a fluently-held commitment as a LABEL of one world in a
    % multimodal Kripke structure -- sensor-driven ontological facts
    % enter the model exactly where the model checker can query them.
:- func apply_label(mm.kripke_m, string, string) = mm.kripke_m.

    % Convenience: apply every fluent in the set as labels of one world.
:- func apply_labels(mm.kripke_m, string, set(string)) = mm.kripke_m.

:- implementation.

:- import_module bool.
:- import_module list.
:- import_module map.
:- import_module mm.
:- import_module pair.
:- import_module set.

holding(Stream) = Holding :-
    Final = walk(Stream, map.init : map(string, bool)),
    Holding = collect_true(map.to_assoc_list(Final), set.init).

:- func walk(list(fluent_event), map(string, bool)) = map(string, bool).
walk([], M) = M.
walk([E | Es], M0) = walk(Es, M1) :-
    M1 = affect(E, M0).

:- func affect(fluent_event, map(string, bool)) = map(string, bool).
affect(initiate(F), M) = map.set(M, F, yes).
affect(terminate(F), M) = map.set(M, F, no).

:- func collect_true(list(pair(string, bool)), set(string)) = set(string).
collect_true([], Acc) = Acc.
collect_true([F - yes | Rest], Acc0) =
    collect_true(Rest, set.insert(Acc0, F)).
collect_true([_ - no | Rest], Acc) =
    collect_true(Rest, Acc).

%----- label plumbing -----%

apply_label(K, World, Fluent) = K3 :-
    OldList = ( if map.search(K ^ labels, World, L0) then L0 else [] ),
    S = set.from_list(OldList),
    ( if set.member(Fluent, S) then
        NewList = OldList
      else
        NewList = OldList ++ [Fluent]
    ),
    NewLabels = map.set(K ^ labels, World, NewList),
    K3 = kripke_m(K ^ states, NewLabels, K ^ rels).

apply_labels(K, World, Fluents) =
    set.fold(add_label(World), Fluents, K).

:- func add_label(string, string, mm.kripke_m) = mm.kripke_m.
add_label(W, F, K) = apply_label(K, W, F).

:- end_module ec.
