import json
import unittest

from audio_observation import make_observation
from llada_interface import propose


class AudioLLaDATest(unittest.TestCase):
    def test_observation_preserves_sidebands_and_provenance(self):
        observation = make_observation(
            "u1", "alice", "Give it to Bob", 1.0, 2.0, "rising-final",
            0.8, 0.7, 0.9, 0.1, ("Bob",), 0.88, ("mic:1-2",),
        )
        payload = observation.to_dict()
        self.assertEqual(payload["text"], "Give it to Bob")
        self.assertEqual(payload["prosody"]["focus"], ["Bob"])
        self.assertEqual(payload["provenance"], ["mic:1-2"])

    def test_proposal_uses_prosody_without_promoting_it_to_truth(self):
        observation = make_observation(
            "u2", "alice", "Deliver it", 0.0, 1.0, "rising-final",
            None, None, 0.9, 0.0, (), 0.8, ("mic:0-1",),
        ).to_dict()
        candidates = propose(observation)
        self.assertEqual(candidates[0].speech_act, "directive")
        self.assertEqual(candidates[0].probability, 0.5)
        self.assertIn("u2", candidates[0].evidence)
        self.assertNotIn("holds_at", json.dumps(candidates[0].to_dict()))

    def test_invalid_interval_is_rejected(self):
        with self.assertRaises(ValueError):
            make_observation("u3", "a", "x", 2.0, 1.0, "unknown", None,
                             None, 0.0, 0.0, (), 0.0, ())


if __name__ == "__main__":
    unittest.main()
