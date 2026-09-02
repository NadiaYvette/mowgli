import io
import unittest

from film_annotations import normalize_observation, read_jsonl


class FilmAnnotationsTest(unittest.TestCase):
    def test_reads_and_normalizes_jsonl(self):
        observations = read_jsonl(io.StringIO(
            '# comment\n'
            '{"id":"v1","start_ms":1,"end_ms":2,"channel":"visual",'
            '"content":"a room","confidence":0.75,"provenance":"human"}\n'
        ))
        self.assertEqual(observations[0].to_dict()["id"], "v1")
        self.assertEqual(observations[0].to_dict()["confidence"], 0.75)

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


if __name__ == "__main__":
    unittest.main()
