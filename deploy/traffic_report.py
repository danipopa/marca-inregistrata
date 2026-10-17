#!/usr/bin/env python3
"""Summarize sanitized JSON request logs from stdin (no external dependencies)."""
import argparse
from collections import Counter
import json
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source', choices=['web', 'gateway'], default='web')
args = parser.parse_args()
count = errors = known_bytes = bytes_count = 0
duration_total = duration_max = 0.0
paths = Counter()
statuses = Counter()
for line in sys.stdin:
    try:
        # kubectl --prefix / --timestamps may add text before the JSON message.
        row = json.loads(line[line.index('{'):])
        if row.get('event') != args.source + '_request':
            continue
        status = int(row['status'])
        duration = float(row['duration_ms']) if args.source == 'web' else float(row['duration_s']) * 1000
        size = row.get('content_length') if args.source == 'web' else row.get('bytes_sent')
        size = int(size) if size is not None else None
    except (ValueError, TypeError, KeyError):
        continue
    count += 1
    errors += status >= 500
    duration_total += duration
    duration_max = max(duration_max, duration)
    if size is not None:
        bytes_count += 1
        known_bytes += size
    paths[str(row.get('path', '(other)'))] += 1
    statuses[status] += 1
print(json.dumps({
    'source': args.source,
    'requests': count,
    'server_errors': errors,
    'average_ms': round(duration_total / count, 1) if count else 0,
    'maximum_ms': round(duration_max, 1),
    'bytes': known_bytes,
    'requests_with_known_bytes': bytes_count,
    'bytes_meaning': 'Actual bytes sent including headers' if args.source == 'gateway' else 'Content-Length only; streamed/compressed responses may be absent or differ from wire bytes',
    'statuses': dict(statuses),
    'top_paths': dict(paths.most_common(20)),
}, indent=2))
