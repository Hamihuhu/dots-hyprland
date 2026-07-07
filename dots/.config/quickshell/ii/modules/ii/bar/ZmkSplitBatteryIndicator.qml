import QtQuick
import qs.modules.common
import qs.services

MouseArea {
    id: root

    readonly property bool zmkEnabled: Config.options?.zmkSplitBattery?.enable ?? true
    readonly property bool shouldShow: zmkEnabled && ZmkSplitBattery.available && (ZmkSplitBattery.leftKnown || ZmkSplitBattery.rightKnown || ZmkSplitBattery.showWhenUnknown)

    visible: shouldShow
    implicitWidth: 26
    implicitHeight: 26
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    ZmkSplitBatteryVerticalIcon {
        anchors.centerIn: parent
        leftLevel: ZmkSplitBattery.leftLevel
        rightLevel: ZmkSplitBattery.rightLevel
        leftKnown: ZmkSplitBattery.leftKnown
        rightKnown: ZmkSplitBattery.rightKnown
    }

    ZmkSplitBatteryPopup {
        hoverTarget: root
    }
}
