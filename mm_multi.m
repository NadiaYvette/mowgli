%---------------------------------------------------------------------------%
% mm_multi.m — multimodal logic with modality type profiles and validation.
%
% Each modality carries structural properties (reflexivity, transitivity,
% symmetry) that constrain its accessibility relation:
%
%   Epistemic (K): K T 4 5 — S5, equivalence relation
%   Doxastic (B):  K 4     — S4, preorder
%   Deontic (O):   K D     — KD, serial
%   Alethic (P):   K T 4 5 — S5, equivalence relation
%---------------------------------------------------------------------------%

:- module mm_multi.

:- interface.

:- import_module bool.
:- import_module list.
:- import_module map.
:- import_module pair.
:- import_module set.
:- import_module string.

:- import_module mm.

:- type modality_type
    --->    modality_type(
                name        :: string,
                reflexive   :: bool,
                transitive  :: bool,
                symmetric   :: bool
            ).

:- type mm_profile
    --->    mm_profile(
                kripke      :: mm.kripke_m,
                profiles    :: map(string, modality_type)
            ).

:- func mk_mm_profile(mm.kripke_m,
        list(pair(string, modality_type))) = mm_profile.

:- func validate(mm_profile) = list(string).

:- func epistemic(string) = modality_type.
:- func doxastic(string) = modality_type.
:- func deontic(string) = modality_type.
:- func alethic(string) = modality_type.

:- implementation.

mk_mm_profile(K, ProfilePairs) =
    mm_profile(K, map.from_assoc_list(ProfilePairs)).

epistemic(Name) = modality_type(Name, yes, yes, yes).
doxastic(Name) = modality_type(Name, yes, yes, no).
deontic(Name) = modality_type(Name, yes, no, no).
alethic(Name) = modality_type(Name, yes, yes, yes).

validate(MP) = AllViolations :-
    K = MP ^ kripke,
    Pairs = map.to_assoc_list(MP ^ profiles),
    validate_loop(K, Pairs, [], AllViolations).

:- pred validate_loop(mm.kripke_m::in,
    list(pair(string, modality_type))::in,
    list(string)::in, list(string)::out) is det.
validate_loop(_, [], Acc, Acc).
validate_loop(K, [Pair | Rest], Acc0, Acc) :-
    ModName = Pair ^ fst,
    Prof = Pair ^ snd,
    ( if map.search(K ^ mm.rels, ModName, RelMap) then
        States = set.to_sorted_list(K ^ mm.states),
        Violations = check_all(RelMap, Prof, States),
        ( if Violations \= [] then
            Acc1 = Acc0 ++ [ModName ++ ": " ++
                string.join_list("; ", Violations)]
          else
            Acc1 = Acc0
        )
      else
        Acc1 = Acc0 ++ [ModName ++ ": no relation defined"]
    ),
    validate_loop(K, Rest, Acc1, Acc).

:- func check_all(map(string, list(string)), modality_type,
    list(string)) = list(string).
check_all(RelMap, Prof, States) = V :-
    V0 = [],
    check_reflexivity(RelMap, States, [], NR),
    ( if Prof ^ reflexive = yes, NR \= [] then
        V1 = V0 ++ ["not reflexive at " ++ string.join_list(", ", NR)]
      else
        V1 = V0
    ),
    check_symmetry(RelMap, States, [], SB),
    ( if Prof ^ symmetric = yes then
        V2 = V1 ++ SB
      else
        V2 = V1
    ),
    check_transitivity(RelMap, States, [], TB),
    ( if Prof ^ transitive = yes then
        V = V2 ++ TB
      else
        V = V2
    ).

:- pred check_reflexivity(map(string, list(string))::in,
    list(string)::in, list(string)::in, list(string)::out) is det.
check_reflexivity(_, [], Acc, Acc).
check_reflexivity(RelMap, [S | Ss], Acc0, Acc) :-
    Succs = get_succs(RelMap, S),
    ( if list.member(S, Succs) then
        check_reflexivity(RelMap, Ss, Acc0, Acc)
      else
        check_reflexivity(RelMap, Ss, Acc0 ++ [S], Acc)
    ).

:- pred check_symmetry(map(string, list(string))::in,
    list(string)::in, list(string)::in, list(string)::out) is det.
check_symmetry(_, [], Acc, Acc).
check_symmetry(RelMap, [S | Ss], Acc0, Acc) :-
    Succs = get_succs(RelMap, S),
    check_sym_pairs(RelMap, S, Succs, Acc0, Acc1),
    check_symmetry(RelMap, Ss, Acc1, Acc).

:- pred check_sym_pairs(map(string, list(string))::in,
    string::in, list(string)::in,
    list(string)::in, list(string)::out) is det.
check_sym_pairs(_, _, [], Acc, Acc).
check_sym_pairs(RelMap, S, [T | Ts], Acc0, Acc) :-
    SuccsOfT = get_succs(RelMap, T),
    ( if list.member(S, SuccsOfT) then
        check_sym_pairs(RelMap, S, Ts, Acc0, Acc)
      else
        check_sym_pairs(RelMap, S, Ts,
            Acc0 ++ [S ++ "->" ++ T ++ " not " ++ T ++ "->" ++ S], Acc)
    ).

:- pred check_transitivity(map(string, list(string))::in,
    list(string)::in, list(string)::in, list(string)::out) is det.
check_transitivity(_, [], Acc, Acc).
check_transitivity(RelMap, [S | Ss], Acc0, Acc) :-
    Succs = get_succs(RelMap, S),
    check_trans_pairs(RelMap, S, Succs, Acc0, Acc1),
    check_transitivity(RelMap, Ss, Acc1, Acc).

:- pred check_trans_pairs(map(string, list(string))::in,
    string::in, list(string)::in,
    list(string)::in, list(string)::out) is det.
check_trans_pairs(_, _, [], Acc, Acc).
check_trans_pairs(RelMap, S, [T | Ts], Acc0, Acc) :-
    Succs = get_succs(RelMap, S),
    SuccsOfT = get_succs(RelMap, T),
    Missing = list.filter(
        (pred(U::in) is semidet :-
            not list.member(U, Succs)
        ), SuccsOfT),
    ( if Missing \= [] then
        check_trans_pairs(RelMap, S, Ts,
            Acc0 ++ [S ++ "->" ++ T ++ " misses " ++
                string.join_list(",", Missing)], Acc)
      else
        check_trans_pairs(RelMap, S, Ts, Acc0, Acc)
    ).

:- func get_succs(map(string, list(string)), string) = list(string).
get_succs(RelMap, S) = ( if map.search(RelMap, S, R) then R else [] ).

:- end_module mm_multi.
