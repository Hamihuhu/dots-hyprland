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
            visible: ZmkSplitBattery.leftKnown && ZmkSplitBattery.rightKnown
            icon: "battery_alert"
            label: Translation.tr("Lowest:")
            value: `${Math.min(ZmkSplitBattery.leftLevel, ZmkSplitBattery.rightLevel)}%`
        }

        StyledPopupValueRow {
            visible: ZmkSplitBattery.lastSeq >= 0
            icon: "tag"
            label: Translation.tr("Seq:")
            value: `${ZmkSplitBattery.lastSeq}`
        }

        StyledPopupValueRow {
            visible: ZmkSplitBattery.errorText.length > 0
            icon: "error"
            label: Translation.tr("Status:")
            value: ZmkSplitBattery.errorText
        }
    }
}
