#!/usr/bin/env bash
# FLINT conformance cross-check for the released `hex-row-reduce` repo.
# Emit a fresh fixture set from Lean, diff it against the committed fixture,
# then pipe the fresh emission into the python-flint oracle (matrix_flint.py).
set -uo pipefail

lib="HexRowReduce"
fixture="conformance-fixtures/HexRowReduce/rowreduce.jsonl"
fresh="/tmp/HexRowReduce-fresh.jsonl"

echo ">>> $lib :: emit=hexrowreduce_emit_fixtures oracle=scripts/oracle/matrix_flint.py"

if ! (cd conformance && lake exe hexrowreduce_emit_fixtures) >"$fresh"; then
  echo "FAIL: $lib :: emit exited non-zero" >&2; exit 1; fi
if ! diff -u "$fixture" "$fresh"; then
  echo "FAIL: $lib :: fresh emission diverges from committed fixture" >&2; exit 1; fi
if ! python3 scripts/oracle/matrix_flint.py <"$fresh"; then
  echo "FAIL: $lib :: oracle reported a divergence" >&2; exit 1; fi
echo "Conformance: $lib oracle passed."
