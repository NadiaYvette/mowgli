# Local diffusion/speech prototype setup

The prototype uses local source checkouts when available:

```text
~/src/LLaDA
~/src/transformers
~/src/speechbrain
~/src/faster-whisper
~/src/librosa
~/src/datasets
~/src/soundfile
```

The checkouts are kept independent. Do not add them as submodules or copy their
source into this project.

## Current boundary

```text
WAV -> audio_frontend.py -> audio_observation.py
                         -> llada_interface.py -> Mercury/social_mm
```

`audio_frontend.py` is intentionally a baseline acoustic measurement tool. It
does not claim to perform ASR, diarization, or robust prosody classification.
Use Faster-Whisper for transcript/timestamps, SpeechBrain for speaker or
paralinguistic experiments, and librosa/SoundFile for richer signal features.

LLaDA remains an optional downstream hypothesis generator. The official
repository's `generate.py` performs masked diffusion sampling and requires the
LLaDA model checkpoint, CUDA-capable PyTorch, and the repository's documented
Transformers compatibility (`transformers==4.38.2` for the original setup).
The installed local Transformers checkout should not silently replace the
system package: create a dedicated virtual environment for this experiment.

## Suggested isolated environment

From a shell where `uv` is available:

```bash
cd ~/src/logic
uv venv .venv-diffusion --python 3.12
source .venv-diffusion/bin/activate
uv pip install 'transformers==4.38.2' torch torchaudio faster-whisper speechbrain librosa soundfile datasets
```

This command is intentionally not run by the prototype automatically. It may
download large wheels and could conflict with the locally provisioned PyTorch
build. For source-checkout development, use editable installs only after the
isolated environment's dependency versions are confirmed.

## Explicit LLaDA smoke test

After installing the isolated environment and obtaining model access/weights:

```bash
cd ~/src/LLaDA
python chat.py
```

The model is approximately 8B parameters and should be treated as a GPU
experiment. Start with a short generation length and a single prompt. Do not
pipe untrusted generated prose directly into Mercury; validate a structured
candidate record first.

## SoundFile provenance

SoundFile was cloned from:

```text
https://github.com/bastibe/python-soundfile
```

It is a Python binding around libsndfile and is useful for reading/writing audio
alongside librosa and SpeechBrain.
