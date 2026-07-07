#!/usr/bin/env python3
"""Read Totem split peripheral battery reports from a USB HID raw device."""

from __future__ import annotations

import argparse
import glob
import json
import os
import select
import struct
import sys
import time
from dataclasses import dataclass


REPORT_ID = 0x7E
REPORT_VERSION = 0x01
UNKNOWN_LEVEL = 0xFF
REPORT_SIZE = 7
DEFAULT_MATCH = "ZMK Project TOTEM Dongle"


@dataclass(frozen=True)
class HidrawDevice:
    path: str
    name: str
    uevent: str
    physical: str


def read_text(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except OSError:
        return ""


def list_hidraw_devices() -> list[HidrawDevice]:
    devices = []

    for path in sorted(glob.glob("/dev/hidraw*")):
        name = os.path.basename(path)
        sysfs = f"/sys/class/hidraw/{name}/device"

        devices.append(
            HidrawDevice(
                path=path,
                name=read_text(f"{sysfs}/name"),
                uevent=read_text(f"{sysfs}/uevent"),
                physical=read_text(f"{sysfs}/phys"),
            )
        )

    return devices


def print_devices() -> None:
    for device in list_hidraw_devices():
        print(device.path)
        if device.name:
            print(f"  NAME={device.name}")
        if device.uevent:
            for line in device.uevent.splitlines():
                print(f"  {line}")
        if device.physical:
            print(f"  PHYS={device.physical}")


def format_level(level: int) -> str:
    if level == UNKNOWN_LEVEL:
        return "unknown"

    return f"{level}%"


def json_level(level: int) -> int | None:
    if level == UNKNOWN_LEVEL:
        return None

    return level


def parse_report(data: bytes) -> tuple[int, int, int, int, int, int] | None:
    if len(data) < REPORT_SIZE:
        return None

    report_id, version, count, slot0, slot1, flags, seq = struct.unpack("BBBBBBB", data[:REPORT_SIZE])
    if report_id != REPORT_ID:
        return None

    if version != REPORT_VERSION:
        print(f"warning: unsupported report version {version}", file=sys.stderr)

    return count, slot0, slot1, flags, seq, version


def report_to_json(parsed: tuple[int, int, int, int, int, int]) -> str:
    count, slot0, slot1, flags, seq, version = parsed
    report = {
        "version": version,
        "peripheral_count": count,
        "left_level": json_level(slot0),
        "right_level": json_level(slot1),
        "flags": flags,
        "seq": seq,
    }
    return json.dumps(report, separators=(",", ":"))


def unavailable_to_json(reason: str) -> str:
    return json.dumps({"available": False, "error": reason}, separators=(",", ":"))


def report_to_text(parsed: tuple[int, int, int, int, int, int]) -> str:
    count, slot0, slot1, flags, seq, version = parsed
    return (
        f"seq={seq} version={version} count={count} "
        f"slot0={format_level(slot0)} slot1={format_level(slot1)} flags=0x{flags:02x}"
    )


def find_matching_devices(match: str | None) -> list[HidrawDevice]:
    devices = list_hidraw_devices()
    if not match:
        return devices

    needle = match.casefold()
    return [
        device
        for device in devices
        if needle in "\n".join([device.path, device.name, device.uevent, device.physical]).casefold()
    ]


def resolve_device_path(device_path: str | None, match: str | None) -> str:
    if device_path:
        return device_path

    matches = find_matching_devices(match)
    if len(matches) == 1:
        return matches[0].path

    if not matches:
        detail = f" matching {match!r}" if match else ""
        raise SystemExit(f"no hidraw devices{detail} found; run with --list")

    paths = ", ".join(device.path for device in matches)
    raise SystemExit(f"multiple hidraw devices match; pass one explicitly: {paths}")


def try_resolve_device_path(device_path: str | None, match: str | None) -> tuple[str | None, str]:
    if device_path:
        return device_path, ""

    matches = find_matching_devices(match)
    if len(matches) == 1:
        return matches[0].path, ""

    if not matches:
        detail = f" matching {match!r}" if match else ""
        return None, f"no hidraw devices{detail} found"

    paths = ", ".join(device.path for device in matches)
    return None, f"multiple hidraw devices match: {paths}"


def emit_unavailable(reason: str, json_output: bool) -> None:
    if json_output:
        print(unavailable_to_json(reason), flush=True)
    else:
        print(reason, file=sys.stderr, flush=True)


def read_reports(device_path: str, json_output: bool, repeat_last_ms: int) -> None:
    last_line = ""
    next_repeat = 0.0
    repeat_seconds = repeat_last_ms / 1000 if repeat_last_ms > 0 else 0

    try:
        with open(device_path, "rb", buffering=0) as device:
            while True:
                timeout = None
                if repeat_seconds > 0 and last_line:
                    timeout = max(0.0, next_repeat - time.monotonic())

                readable, _, _ = select.select([device], [], [], timeout)
                if not readable:
                    print(last_line, flush=True)
                    next_repeat = time.monotonic() + repeat_seconds
                    continue

                data = device.read(64)
                if not data:
                    return

                parsed = parse_report(data)
                if parsed is not None:
                    last_line = report_to_json(parsed) if json_output else report_to_text(parsed)
                    print(last_line, flush=True)
                    if repeat_seconds > 0:
                        next_repeat = time.monotonic() + repeat_seconds
    except OSError as error:
        raise RuntimeError(f"{device_path}: {error.strerror}") from error


def watch_reports(
    device_path: str | None,
    match: str | None,
    json_output: bool,
    repeat_last_ms: int,
    scan_ms: int,
) -> int:
    scan_seconds = max(scan_ms, 250) / 1000
    last_unavailable = ""

    while True:
        resolved_path, error = try_resolve_device_path(device_path, match)
        if not resolved_path:
            if error != last_unavailable:
                emit_unavailable(error, json_output)
                last_unavailable = error
            time.sleep(scan_seconds)
            continue

        last_unavailable = ""
        try:
            read_reports(resolved_path, json_output, repeat_last_ms)
            error = f"{resolved_path}: disconnected"
        except RuntimeError as runtime_error:
            error = str(runtime_error)

        emit_unavailable(error, json_output)
        time.sleep(scan_seconds)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Read ZMK Totem split battery reports from a USB HID raw device."
    )
    parser.add_argument(
        "device",
        nargs="?",
        help="hidraw device path, for example /dev/hidraw3",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="list hidraw devices and exit",
    )
    parser.add_argument(
        "--match",
        default=DEFAULT_MATCH,
        help="auto-select a single hidraw device whose path, uevent, or phys contains this text",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="emit one Quickshell-compatible JSON object per report",
    )
    parser.add_argument(
        "--repeat-last-ms",
        type=int,
        default=0,
        help="repeat the last parsed report at this interval; useful for stale-sensitive widgets",
    )
    parser.add_argument(
        "--scan-ms",
        type=int,
        default=2000,
        help="when no explicit device is provided, rescan for matching hidraw devices at this interval",
    )
    parser.add_argument(
        "--once",
        action="store_true",
        help="exit instead of waiting for matching devices to appear or reappear",
    )

    args = parser.parse_args()

    if args.list:
        print_devices()
        return 0

    if args.once:
        device_path = resolve_device_path(args.device, args.match)
        read_reports(device_path, args.json, max(0, args.repeat_last_ms))
        return 0

    return watch_reports(
        args.device,
        args.match,
        args.json,
        max(0, args.repeat_last_ms),
        max(0, args.scan_ms),
    )


if __name__ == "__main__":
    raise SystemExit(main())
