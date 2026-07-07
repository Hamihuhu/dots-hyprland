import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services

ColumnLayout {
    id: root

    readonly property bool zmkEnabled: Config.options?.zmkSplitBattery?.enable ?? true
    readonly property int lowThreshold: Config.options?.battery?.low ?? 20
    readonly property bool shouldShow: zmkEnabled && ZmkSplitBattery.available && (ZmkSplitBattery.leftKnown || ZmkSplitBattery.rightKnown || ZmkSplitBattery.showWhenUnknown)

    visible: shouldShow
    spacing: -2

    component SideStatus: ColumnLayout {
        id: sideRoot

        required property int level
        required property bool known

        spacing: -4

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            text: sideRoot.known ? Icons.getBatteryIcon(sideRoot.level) : "battery_unknown"
            iconSize: Appearance.font.pixelSize.normal
            color: sideRoot.known && sideRoot.level <= root.lowThreshold ? Appearance.m3colors.m3error : Appearance.colors.colOnLayer0
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: sideRoot.known ? `${sideRoot.level}%` : "--"
            font.pixelSize: 11
            color: sideRoot.known && sideRoot.level <= root.lowThreshold ? Appearance.m3colors.m3error : Appearance.colors.colOnLayer0
        }
    }

    SideStatus {
        level: ZmkSplitBattery.leftLevel
        known: ZmkSplitBattery.leftKnown
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: "|"
        font.pixelSize: 10
        color: Appearance.colors.colSubtext
    }

    SideStatus {
        level: ZmkSplitBattery.rightLevel
        known: ZmkSplitBattery.rightKnown
    }
}
