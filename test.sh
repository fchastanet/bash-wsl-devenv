#!/bin/bash

set -e
trap 'rc=$?; if ((rc)); then echo "ERROR $rc caught."; exit $rc; fi' debug

fn() { if test -d nosuchdir; then echo no dir; else echo dir; return 1; fi; }
fn
echo survived