# Filtering and control in the logic → semiotics → ontology → sensor onion

## Summary

Filtering and control should be an intermediate computational layer, not a
replacement for the logical model:

```text
sensors -> observations/signs -> filter/belief state -> ontology/world model
                                             |
                                             v
                                  planner/controller -> actions
```

A filter estimates a latent state from noisy observations and prior dynamics.
A controller chooses an action using the estimated state, uncertainty, and
constraints. The Mercury logic layer should consume a finite, typed belief
state and expose predicates such as `lamp_on`, `visible(agent, object)`, or
`obligation(group, action)`.

## Candidate layers

### 1. Bayesian filtering

For the existing finite lamp model, the natural first implementation is a
finite-state Bayesian filter:

```text
predict:  b'(s') = sum_s P(s' | s, a) b(s)
update:   b(s) = likelihood(o | s) b'(s) / normalizer
```

This generalizes the current `bayes_update` from independent observations to
a controlled hidden Markov model. It is exact for a small discrete state space
and easy to inspect in a demo.

### 2. Kalman and particle filters

Continuous linear-Gaussian state models motivate Kalman filtering. Nonlinear,
non-Gaussian, or multimodal models motivate particle filtering. These should
initially live in a numeric/perception adapter, because Mercury's current
finite Kripke structures are not a suitable numerical tensor runtime.

### 3. Model-predictive control

MPC repeatedly predicts a finite action horizon, scores candidate trajectories,
and executes only the first action before replanning. This fits the onion when
candidate actions are projected into event-calculus events and rejected when
they violate deontic, visibility, or safety constraints.

### 4. Active inference / control as inference

Active inference treats preferences and observations in a generative model and
selects policies by expected free energy. This is conceptually compatible with
the existing posterior and semiotic-interpretant story, but the demo should not
claim equivalence: a posterior update alone is not a full active-inference
agent.

## Logical integration

A useful contract is:

- the filter owns numeric probabilities and transition/observation models;
- the ontology adapter converts high-probability or thresholded hypotheses into
  typed fluents, retaining confidence and provenance;
- the Kripke layer reasons over explicitly represented possible worlds;
- the controller proposes actions from belief state and logical constraints;
- event calculus records the selected action and its observed consequences.

For safety, never collapse uncertainty merely because one hypothesis is above a
threshold. Keep `belief(state)` separate from `holds_at(fluent)`, and require
an explicit policy threshold or robust constraint before acting.

## Minimal next demo

`control_filter_demo` uses two discrete lamp states, an action (`switch_on` or
`wait`), a transition model with occasional actuator failure, and noisy bright/
dark observations. It demonstrates predict-update-control order and emits
an event-calculus-compatible action trace. It is deliberately not a claim of
continuous optimal control.

## References

- Kalman, R. E. (1960), “A New Approach to Linear Filtering and Prediction
  Problems,” *Transactions of the ASME—Journal of Basic Engineering*.
- Kaelbling, L. P., Littman, M. L., and Cassandra, A. R. (1998), “Planning and
  Acting in Partially Observable Stochastic Domains,” *Artificial
  Intelligence* 101(1–2), 99–134. doi:10.1016/S0004-3702(98)00023-X.
- Rawlings, J. B., Mayne, D. Q., and Diehl, M. (2017), *Model Predictive
  Control: Theory, Computation, and Design*.
- Friston, K. (2010), “The free-energy principle: a unified brain theory?”
  *Nature Reviews Neuroscience* 11, 127–138. doi:10.1038/nrn2787.
- Friston, K. et al. (2017), “Active Inference and Learning,” *Neuroscience
  & Biobehavioral Reviews* 68, 862–879.
- Kayalibay, B. et al. (2023), “Filter-Aware Model-Predictive Control,”
  *Proceedings of Machine Learning Research* 211.

## BibTeX

```bibtex
@article{kalman1960,
  author = {Kalman, Rudolph E.},
  title = {A New Approach to Linear Filtering and Prediction Problems},
  journal = {Journal of Basic Engineering}, year = {1960}
}
@article{kaelbling1998,
  author = {Kaelbling, Leslie Pack and Littman, Michael L. and Cassandra, Anthony R.},
  title = {Planning and Acting in Partially Observable Stochastic Domains},
  journal = {Artificial Intelligence}, volume = {101}, pages = {99--134}, year = {1998},
  doi = {10.1016/S0004-3702(98)00023-X}
}
@article{friston2010,
  author = {Friston, Karl}, title = {The free-energy principle: a unified brain theory?},
  journal = {Nature Reviews Neuroscience}, volume = {11}, pages = {127--138}, year = {2010},
  doi = {10.1038/nrn2787}
}
```
