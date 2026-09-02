%---------------------------------------------------------------------------%
% semiring.m — a semiring typeclass for logic-programming semantics.
%
% One interpreter (see plp.m) parameterized over a semiring gives you:
%   * float   — exact marginal probability (Sato's distribution semantics)
%   * maxplus — Viterbi / most-likely-explanation (max of sums)
%   * minplus — cheapest / shortest-path (min of sums)
%   * bool    — plain logical entailment
%
% This is the same trick used by semiring-based probabilistic logic
% programming systems: the *program* stays fixed, the *algebra* changes.
%
% The typeclass methods:
%   zero       — identity for add  (probability: 0, maxplus: -inf, minplus: +inf)
%   one        — identity for mul  (probability: 1, maxplus: 0, minplus: 0)
%   add(A, B)  — combine alternatives   (or  / disjoint sum)
%   mul(A, B)  — combine conjuncts      (and / joint)
%   from_float — lift a fact's weight into the algebra
%---------------------------------------------------------------------------%

:- module semiring.

:- interface.

:- import_module bool.
:- import_module float.

:- typeclass semiring(T) where [
    func zero = T,
    func one = T,
    func add(T, T) = T,
    func mul(T, T) = T,
    func from_float(float) = T
].

    % maxplus — Viterbi algebra. Weights are *log-probabilities* in
    % practice; here we keep them as plain floats so the demo stays readable.
    %   add = max, mul = +
    %   zero = -inf, one = 0
:- type maxplus
    --->    maxplus(float).

    % minplus — tropical / shortest-path algebra.
    %   add = min, mul = +
    %   zero = +inf, one = 0
:- type minplus
    --->    minplus(float).

:- instance semiring(float).
:- instance semiring(bool).
:- instance semiring(maxplus).
:- instance semiring(minplus).

:- implementation.

%----- probability: sum of products -----%
:- instance semiring(float) where [
    zero = 0.0,
    one = 1.0,
    add(A, B) = A + B,
    mul(A, B) = A * B,
    from_float(F) = F
].

%----- boolean: disjunction/conjunction -----%
:- instance semiring(bool) where [
    zero = no,
    one = yes,
    add(A, B) = bool.or(A, B),
    mul(A, B) = bool.and(A, B),
    from_float(_) = yes
].

%----- Viterbi: max of sums -----%
:- instance semiring(maxplus) where [
    zero = maxplus(-float.infinity),
    one = maxplus(0.0),
    add(maxplus(A), maxplus(B)) = maxplus(float.max(A, B)),
    mul(maxplus(A), maxplus(B)) = maxplus(A + B),
    from_float(F) = maxplus(F)
].

%----- tropical: min of sums -----%
:- instance semiring(minplus) where [
    zero = minplus(float.infinity),
    one = minplus(0.0),
    add(minplus(A), minplus(B)) = minplus(float.min(A, B)),
    mul(minplus(A), minplus(B)) = minplus(A + B),
    from_float(F) = minplus(F)
].

:- end_module semiring.
