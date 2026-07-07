pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

Singleton {
    id: root

    readonly property var serviceConfig: Config.options?.zmkSplitBattery ?? ({})
    readonly property bool enabled: serviceConfig.enable ?? true
    readonly property var configuredCommand: serviceConfig.command ?? ["python3", Quickshell.shellPath("scripts/zmk-split-battery.py")]
    readonly property int configuredIntervalMs: serviceConfig.intervalMs ?? 60000
    readonly property int staleAfterMs: serviceConfig.staleAfterMs ?? 180000
    readonly property int retryAfterMs: serviceConfig.retryAfterMs ?? 5000
    readonly property bool showWhenUnknown: serviceConfig.showWhenUnknown ?? false
    readonly property string commandKey: JSON.stringify(command)
    readonly property var command: {
        const baseCommand = Array.isArray(configuredCommand) ? configuredCommand.slice() : ["python3", Quickshell.shellPath("scripts/zmk-split-battery.py")];
        if (baseCommand.length === 2 && String(baseCommand[1]).endsWith("/scripts/zmk-split-battery.py")) {
            baseCommand.push("--json");
            baseCommand.push("--repeat-last-ms", String(configuredIntervalMs));
        }
        return baseCommand;
    }

    property bool available: false
    property int leftLevel: -1
    property int rightLevel: -1
    property bool leftKnown: false
    property bool rightKnown: false
    property int lastSeq: -1
    property string statusText: "Unavailable"
    property string errorText: ""
    property double lastUpdateMs: 0
    property bool completed: false
    readonly property bool scriptRunning: batteryProc.running
    readonly property bool connected: available && (leftKnown || rightKnown)
    readonly property string displayStatus: !enabled ? "Idle" : connected ? "Connected" : scriptRunning ? "Scanning" : "Idle"

    function resetUnavailable(reason) {
        available = false;
        leftLevel = -1;
        rightLevel = -1;
        leftKnown = false;
        rightKnown = false;
        statusText = "Unavailable";
        errorText = reason ?? "";
    }

    function validLevel(value) {
        return typeof value === "number" && isFinite(value) && value >= 0 && value <= 100;
    }

    function setReportLevel(side, value) {
        const knownProperty = side + "Known";
        const levelProperty = side + "Level";
        if (value === null || value === undefined) {
            root[knownProperty] = false;
            root[levelProperty] = -1;
            return;
        }
        if (!validLevel(value)) {
            throw new Error(side + "_level must be 0..100 or null");
        }
        root[knownProperty] = true;
        root[levelProperty] = Math.round(value);
    }

    function handleLine(line) {
        const trimmed = line.trim();
        if (trimmed.length === 0) {
            return;
        }

        try {
            const report = JSON.parse(trimmed);
            if (report.available === false) {
                resetUnavailable(report.error ?? "ZMK split battery dongle unavailable");
                return;
            }
            if (report.version !== 1 || report.peripheral_count !== 2) {
                throw new Error("Unsupported ZMK split battery report");
            }
            if (typeof report.seq !== "number" || report.seq < 0 || report.seq > 255) {
                throw new Error("Invalid report seq");
            }

            setReportLevel("left", report.left_level);
            setReportLevel("right", report.right_level);
            lastSeq = Math.round(report.seq);
            available = leftKnown || rightKnown || showWhenUnknown;
            statusText = available ? "OK" : "Unknown";
            errorText = "";
            lastUpdateMs = Date.now();
            staleTimer.restart();
        } catch (error) {
            resetUnavailable(String(error));
        }
    }

    function restartProcess() {
        if (!enabled || !completed) {
            return;
        }
        batteryProc.running = false;
        restartTimer.restart();
        resetUnavailable("");
    }

    onEnabledChanged: {
        if (enabled) {
            batteryProc.running = true;
            staleTimer.restart();
        } else {
            batteryProc.running = false;
            staleTimer.stop();
            resetUnavailable("");
        }
    }

    onCommandKeyChanged: restartProcess()

    Component.onCompleted: {
        completed = true;
        if (enabled) {
            staleTimer.restart();
        }
    }

    Timer {
        id: staleTimer
        interval: root.staleAfterMs
        repeat: false
        onTriggered: root.resetUnavailable("Stale ZMK split battery data")
    }

    Timer {
        id: restartTimer
        interval: root.retryAfterMs
        repeat: false
        onTriggered: {
            if (root.enabled) {
                batteryProc.running = true;
                staleTimer.restart();
            }
        }
    }

    Process {
        id: batteryProc
        running: root.enabled
        command: root.command

        stdout: SplitParser {
            onRead: line => root.handleLine(line)
        }

        stderr: SplitParser {
            onRead: line => {
                const trimmed = line.trim();
                if (trimmed.length > 0) {
                    root.errorText = trimmed;
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.resetUnavailable("ZMK split battery process exited: " + exitCode);
            if (root.enabled) {
                restartTimer.restart();
            }
        }
    }
}
