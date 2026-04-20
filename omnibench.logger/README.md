# omnibench.logger

Streaming structured event logger for omnibenchmark / Snakemake rules.
R reference implementation of the [omnibench-events](../SPEC.md) 0.1 spec.

Only runtime dependency: `jsonlite`.

Designed to be run alongside an external profiler (e.g. [denet](
https://github.com/chatziko/denet)) so CPU / memory samples can be
aligned against the named lifecycle events emitted from inside your
rule. See the top-level [README](../README.md) for the coordination
pattern.

## Install

```r
devtools::install_local("omnibench.logger")
```

## Usage

```r
library(omnibench.logger)

init_logger(snakemake@params$logdir)

emit("align", "start")
# ... work ...
emit("align", "end", attrs = list(nreads = 12345))
```

This appends JSON-lines records to
`<logdir>/omnibench-events.jsonl`, one per call:

```json
{"ts":"2026-04-20T17:10:00.123Z","event":"align","phase":"start","pid":4211,"host":"node01"}
{"ts":"2026-04-20T17:12:03.004Z","event":"align","phase":"end","pid":4211,"host":"node01","attrs":{"nreads":12345}}
```

## API

- `init_logger(path)` — set the output directory (created if missing).
  Call once per script.
- `emit(event, phase, attrs = NULL)` — append one event. `phase` must be
  `"start"` or `"end"`. `attrs` is an optional named list of scalars.

Emit never interrupts your rule on I/O failure — it warns and continues.

## Test

```sh
Rscript -e 'devtools::test("omnibench.logger")'
```
