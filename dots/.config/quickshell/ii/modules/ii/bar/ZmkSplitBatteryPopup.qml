import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

StyledPopup {
    id: root

    function formatLevel(known, level) {
        return known ? `${level}%` : "--";
    }

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 4

        StyledPopupHeaderRow {
            icon: "battery_android_full"
            label: Translation.tr("Split battery")
        }

        StyledPopupValueRow {
            icon: ZmkSplitBattery.connected ? "check_circle" : ZmkSplitBattery.scriptRunning ? "sync" : "power_settings_new"
            label: Translation.tr("Status:")
            value: Translation.tr(ZmkSplitBattery.displayStatus)
        }

        StyledPopupValueRow {
            icon: "keyboard"
            label: Translation.tr("Left:")
            value: root.formatLevel(ZmkSplitBattery.leftKnown, ZmkSplitBattery.leftLevel)
        }

        StyledPopupValueRow {
            icon: "keyboard"
            label: Translation.tr("Right:")
            value: root.formatLevel(ZmkSplitBattery.rightKnown, ZmkSplitBattery.rightLevel)
        }

        StyledPopupValueRow {
            visible: ZmkSplitBattery.errorText.length > 0
            icon: "error"
            label: Translation.tr("Message:")
            value: ZmkSplitBattery.errorText
        }

        RippleButtonWithIcon {
            visible: !ZmkSplitBattery.scriptRunning
            Layout.fillWidth: true
            materialIcon: "play_arrow"
            mainText: Translation.tr("Start scanning")
            onClicked: {
                Config.options.zmkSplitBattery.enable = true;
            }
        }
    }
}
