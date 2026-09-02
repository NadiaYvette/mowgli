%---------------------------------------------------------------------------%
% tabling.m — Mercury's tabling (`:- pragma memo`) applied to logic-program
% recursion, the exact machinery PRISM-style PLP systems use.
%
% The point: naive recursive *path counting* on a layered DAG recomputes
% the same sub-paths over and over — exponential. With `:- pragma memo`
% (fast_loose), each (from, to) pair is solved once, so the same program
% becomes polynomial. This is the "shared subcomputations between
% explanations" trick that makes distribution-semantics inference
% tractable: in plp.m the marginal enumerates 2^n worlds; tabling the
% reachability/counting predicate inside each world shares the repeated
% sub-derivations.
%
% (Full minimal-model tabling — `:- pragma minimal_model` — which handles
% *cyclic* graphs and coinductive/greatest-fixpoint derivations, needs a
% grade built with minimal-model support, which is not installed here.
% The DAG case below works in any grade and demonstrates the sharing.)
%---------------------------------------------------------------------------%

:- module tabling.

:- interface.

:- import_module int.
:- import_module list.
:- import_module pair.

    % Count the number of paths from From to To, naive recursion.
:- func count_naive(string, string, list(pair(string, string))) = int.

    % The same, with tabling.
:- func count_tabled(string, string, list(pair(string, string))) = int.

    % A layered "diamond" DAG with 2^n paths: s -> n1 -> n2 -> ... -> t,
    % where each ni fans out to two copies of ni+1 (2^n paths total, but
    % only n distinct nodes). Naive counting visits 2^n sub-paths;
    % tabled counting visits n distinct pairs.
:- func diamond_dag(int) = list(pair(string, string)).

:- implementation.

:- import_module solutions.
:- import_module string.

%----- naive recursion -----%

count_naive(X, T, Es) = C :-
    ( if X = T then
        C = 1
      else
        Succ = successors(X, Es),
        C = list.foldl((func(Y, A) = A + count_naive(Y, T, Es)), Succ, 0)
    ).

%----- tabled version -----%

count_tabled(X, T, Es) = C :-
    ( if X = T then
        C = 1
      else
        Succ = successors(X, Es),
        C = list.foldl((func(Y, A) = A + count_tabled(Y, T, Es)), Succ, 0)
    ).
:- pragma memo(count_tabled/3, [fast_loose]).

    % All successors of X in the edge list.
:- func successors(string, list(pair(string, string))) = list(string).
successors(X, Es) = Ys :-
    list.filter_map(
        (pred(E::in, Y::out) is semidet :-
            E = X - Y
        ),
        Es, Ys).

%----- diamond DAG -----%

diamond_dag(N) = Edges :-
    list.foldl(add_layer, 0 .. N - 1, [], E1),
    Edges = E1 ++ [snode(N) - "t", pnode(N) - "t"].

    % One layer: both current nodes fan out to both next nodes.
:- pred add_layer(int::in, list(pair(string, string))::in,
    list(pair(string, string))::out) is det.
add_layer(I, Acc, Acc ++ [snode(I) - snode(I + 1), snode(I) - pnode(I + 1),
    pnode(I) - snode(I + 1), pnode(I) - pnode(I + 1)]).

:- func snode(int) = string.
snode(I) = "s" ++ from_int(I).

:- func pnode(int) = string.
pnode(I) = "p" ++ from_int(I).

:- end_module tabling.
