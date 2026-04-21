# omnibench-logger

Tiny structured event logger for [omnibenchmark](
https://omnibenchmark.org) / Snakemake pipelines. Writes named
start/end events to a JSON-lines file so that downstream tooling can
reason about the phases of a rule without parsing ad-hoc stdout.

## Why this exists

Workflow rules do interesting things in several named phases
(`download`, `align`, `sort`, `index`, …). Wall-clock timing is
useful but phase-level attribution is what actually helps you
optimize. This library gives you two calls — `init_logger(path)` and
`emit(event, phase)` — that drop a structured anchor into a log file
whenever a phase begins or ends.

## Coordinated logging with a profiler

`omnibench-logger` is designed to be paired with a sampling profiler
such as [denet](https://github.com/chatziko/denet). The profiler
records CPU / memory / IO at a fixed cadence; this logger records the
rule's named phase boundaries. At analysis time you join the two on
timestamp:

```
denet samples:                ~~.~..~~..~~..~~..~~..~~..
omnibench events:       |start "align"                     |end "align"
                        └──────────── attributed ──────────┘
```

The profiler tells you **what** the process was doing; this log tells
you **what phase it was in** while it was doing it. Neither is
sufficient alone.

## Installation

```bash
pip install omnibench-logger
```

Or directly from source:

```bash
pip install .
```

## Usage

```python
from omnibench_logger import init_logger, emit

init_logger("/path/to/logs")

emit("align", "start")
# … do work …
emit("align", "end")
```

`init_logger(path)` creates the directory if needed and sets the output file
to `<path>/omnibench-events.jsonl`. `emit(event, phase)` appends a JSON-lines
record with a UTC timestamp, PID, and hostname. An optional `attrs` dict can
carry extra fields.

## Layout

- [`SPEC.md`](SPEC.md) — language-agnostic wire format (omnibench-events 0.1).
- [`omnibench_logger/`](omnibench_logger/) — Python package (`omnibench-logger` on PyPI).
- [`omnibench.logger/`](omnibench.logger/) — R reference implementation.
  (The package is named with a dot because R doesn't allow hyphens in
  package names.)

## Status

v0.1, pre-release. Wire format is stable; API may still shift.
