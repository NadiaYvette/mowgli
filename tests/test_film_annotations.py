import io
import unittest

from film_annotations import (
    generate_mercury_module,
    normalize_observation,
    read_annotations,
    read_jsonl,
)


class FilmAnnotationsTest(unittest.TestCase):
    def test_reads_and_normalizes_jsonl(self):
        observations = read_jsonl(io.StringIO(
            '# comment\n'
            '{"id":"v1","start_ms":1,"end_ms":2,"channel":"visual",'
            '"content":"a room","confidence":0.75,"provenance":"human"}\n'
        ))
        self.assertEqual(observations[0].to_dict()["id"], "v1")
        self.assertEqual(observations[0].to_dict()["confidence"], 0.75)

    def test_reads_relations_after_observations(self):
        observations, relations = read_annotations(io.StringIO(
            '{"kind":"observation","id":"v1","start_ms":0,"end_ms":2,'
            '"channel":"visual","content":"a room","confidence":0.75,'
            '"provenance":"human"}\n'
            '{"kind":"observation","id":"a1","start_ms":0,"end_ms":2,'
            '"channel":"audio","content":"a tone","confidence":0.8,'
            '"provenance":"human"}\n'
            '{"kind":"relation","source":"a1","relation":"synchronized_with",'
            '"target":"v1","confidence":0.9,"provenance":"human"}\n'
        ))
        self.assertEqual(len(observations), 2)
        self.assertEqual(relations[0].relation, "synchronized_with")
        self.assertEqual(relations[0].source_id, "a1")

    def test_accepts_semantically_valid_temporal_relations(self):
        observations, relations = read_annotations(io.StringIO(
            '{"id":"a","start_ms":0,"end_ms":4,"channel":"visual",'
            '"content":"a","confidence":1,"provenance":"test"}\n'
            '{"id":"b","start_ms":5,"end_ms":9,"channel":"visual",'
            '"content":"b","confidence":1,"provenance":"test"}\n'
            '{"id":"c","start_ms":2,"end_ms":7,"channel":"audio",'
            '"content":"c","confidence":1,"provenance":"test"}\n'
            '{"id":"d","start_ms":5,"end_ms":7,"channel":"music",'
            '"content":"d","confidence":1,"provenance":"test"}\n'
            '{"kind":"relation","source":"a","relation":"before",'
            '"target":"b","confidence":1,"provenance":"test"}\n'
            '{"kind":"relation","source":"a","relation":"overlaps",'
            '"target":"c","confidence":1,"provenance":"test"}\n'
            '{"kind":"relation","source":"d","relation":"during",'
            '"target":"b","confidence":1,"provenance":"test"}\n'
        ))
        self.assertEqual(len(observations), 4)
        self.assertEqual(len(relations), 3)

    def test_rejects_temporal_contradictions(self):
        with self.assertRaisesRegex(ValueError, "contradicts intervals"):
            read_annotations(io.StringIO(
                '{"id":"a","start_ms":0,"end_ms":4,"channel":"visual",'
                '"content":"a","confidence":1,"provenance":"test"}\n'
                '{"id":"b","start_ms":5,"end_ms":9,"channel":"visual",'
                '"content":"b","confidence":1,"provenance":"test"}\n'
                '{"kind":"relation","source":"a","relation":"overlaps",'
                '"target":"b","confidence":1,"provenance":"test"}\n'
            ))

    def test_rejects_duplicate_or_inverse_relations(self):
        records = (
            '{"id":"a","start_ms":0,"end_ms":1,"channel":"visual",'
            '"content":"a","confidence":1,"provenance":"test"}\n'
            '{"id":"b","start_ms":2,"end_ms":3,"channel":"visual",'
            '"content":"b","confidence":1,"provenance":"test"}\n'
            '{"kind":"relation","source":"a","relation":"before",'
            '"target":"b","confidence":1,"provenance":"test"}\n'
            '{"kind":"relation","source":"b","relation":"after",'
            '"target":"a","confidence":1,"provenance":"test"}\n'
        )
        with self.assertRaisesRegex(ValueError, "duplicate or inverse relation"):
            read_annotations(io.StringIO(records))

    def test_rejects_duplicate_ids(self):
        line = ('{"id":"x","start_ms":0,"end_ms":0,"channel":"audio",'
                '"content":"tone","confidence":1,"provenance":"test"}\n')
        with self.assertRaisesRegex(ValueError, "duplicate id"):
            read_jsonl(io.StringIO(line + line))

    def test_rejects_invalid_channel_and_interval(self):
        with self.assertRaisesRegex(ValueError, "channel"):
            normalize_observation({
                "id": "x", "start_ms": 0, "end_ms": 1,
                "channel": "camera", "content": "x",
                "confidence": 0.5, "provenance": "test",
            })
        with self.assertRaisesRegex(ValueError, "interval"):
            normalize_observation({
                "id": "x", "start_ms": 2, "end_ms": 1,
                "channel": "visual", "content": "x",
                "confidence": 0.5, "provenance": "test",
            })

    def test_rejects_relations_with_unknown_endpoints(self):
        with self.assertRaisesRegex(ValueError, "unknown observation IDs"):
            read_annotations(io.StringIO(
                '{"kind":"observation","id":"v1","start_ms":0,"end_ms":1,'
                '"channel":"visual","content":"x","confidence":0.5,'
                '"provenance":"test"}\n'
                '{"kind":"relation","source":"v1","relation":"before",'
                '"target":"missing","confidence":0.5,"provenance":"test"}\n'
            ))

    def test_generates_observation_and_relation_constructors(self):
        observations, relations = read_annotations(io.StringIO(
            '{"kind":"observation","id":"v1","start_ms":0,"end_ms":1,'
            '"channel":"visual","content":"x","confidence":0.5,'
            '"provenance":"test"}\n'
            '{"kind":"observation","id":"a1","start_ms":0,"end_ms":1,'
            '"channel":"audio","content":"y","confidence":0.6,'
            '"provenance":"test"}\n'
            '{"kind":"relation","source":"a1","relation":"synchronized_with",'
            '"target":"v1","confidence":0.7,"provenance":"test"}\n'
        ))
        source = generate_mercury_module(
            observations, module_name="fixture", relations=relations)
        self.assertIn("film_episode.observation(\"v1\"", source)
        self.assertIn("film_episode.observation_relation(\"a1\", synchronized_with", source)


if __name__ == "__main__":
    unittest.main()
