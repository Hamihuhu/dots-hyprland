#!/usr/bin/env python3
"""Emit mock ZMK split battery JSON reports for Quickshell."""

import argparse
import json
import sys
import time


def clamp_level(value):
    return max(0, min(100, value))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--interval-ms", type=int, default=60000)
    parser.add_argument("--allow-null", action="store_true")
    parser.add_argument("--left-start", type=int, default=94)
    parser.add_argument("--right-start", type=int, default=88)
    parser.add_argument("--hold-levels", action="store_true")
    args = parser.parse_args()

    interval_seconds = max(args.interval_ms, 100) / 1000
    left_level = clamp_level(args.left_start)
    right_level = clamp_level(args.right_start)
    seq = 0

    while True:
        report = {
            "version": 1,
            "peripheral_count": 2,
            "left_level": left_level,
            "right_level": right_level,
            "flags": 0,
            "seq": seq,
        }

        if args.allow_null:
            if seq % 37 == 12:
                report["left_level"] = None
            if seq % 41 == 17:
                report["right_level"] = None

        print(json.dumps(report, separators=(",", ":")), flush=True)

        seq = (seq + 1) % 256
        if not args.hold_levels:
            if seq % 3 == 0:
                left_level = clamp_level(left_level - 1)
            if seq % 4 == 0:
                right_level = clamp_level(right_level - 1)
            if left_level == 0 and right_level == 0:
                left_level = 100
                right_level = 96

        time.sleep(interval_seconds)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.exit(0)
