#!/bin/sh
set -e
cd "$(dirname "$0")"

if [ ! -x .venv/bin/python ]; then
    python3 -m venv .venv
    .venv/bin/pip install -r requirements.txt
fi

.venv/bin/pytest -q

# fresh replay so the table doesn't stack
rm -f aerogrid.db
.venv/bin/python stream_monitor.py --speed 0 --db aerogrid.db

.venv/bin/python dashboard.py --host 127.0.0.1 --port 8765 &
d_pid=$!

cleanup() {
    kill "$d_pid" 2>/dev/null || true
    wait "$d_pid" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

echo "page: http://127.0.0.1:8765/"
echo "You should see: T-04 and T-07 in the table"
echo "stop with ctrl-c"

wait "$d_pid"
