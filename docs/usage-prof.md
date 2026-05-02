# prof — usage

Parse and align profiler output (denet, Snakemake bench files) with
logger events for per-phase resource attribution.

> **Status:** not yet implemented. This page will cover the Python
> submodule (`obkit.prof`) and the R prefix group (`prof_*`) once the
> API stabilises.

---

## Concept

A sampling profiler such as [denet](https://github.com/btraven00/denet)
records CPU / RSS / IO at a fixed cadence. The logger records sparse
phase anchors (`align start`, `align end`, …). `prof` joins the two on
timestamp, attributing profiler samples to the phase active at each
sample time.

```
denet samples:       ~~.~..~~..~~..~~..~~..~~..
logger events:  |start "align"                    |end "align"
                └──────────── attributed ──────────┘
```

The result is a per-phase resource summary without any instrumentation
inside the profiler or changes to the workflow rule.

---

## Planned API surface

### Python (`obkit.prof`)

```python
from obkit.prof import load_events, load_denet, attribute
```

### R (`prof_*`)

```r
library(obkit)

prof_load_events(log_file)
prof_load_denet(denet_file)
prof_attribute(events, samples)
```
