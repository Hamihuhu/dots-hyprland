import QtQuick
import qs.modules.common
import qs.services

MouseArea {
    id: root

    readonly property bool shouldShow: Config.options?.zmkSplitBattery?.enable ?? true

    visible: shouldShow
    implicitWidth: shouldShow ? 26 : 0
    implicitHeight: shouldShow ? 26 : 0
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
