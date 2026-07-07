import QtQuick
import qs.modules.common
import qs.modules.common.functions

Item {
    id: root

    property int leftLevel: -1
    property int rightLevel: -1
    property bool leftKnown: false
    property bool rightKnown: false
    property int lowThreshold: Config.options?.battery?.low ?? 20
    property color normalColor: Appearance.colors.colOnLayer2
    property color lowColor: Appearance.m3colors.m3error
    property color emptyColor: ColorUtils.transparentize(normalColor, 0.78)

    implicitWidth: 24
    implicitHeight: 22

    component VerticalBattery: Item {
        id: batteryRoot

        required property int level
        required property bool known
        readonly property bool low: known && level <= root.lowThreshold
        readonly property color activeColor: low ? root.lowColor : root.normalColor
        readonly property real fillRatio: known ? Math.max(0, Math.min(100, level)) / 100 : 0

        width: 9
        height: 16

        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            width: 4
            height: 2
            radius: 1
            color: batteryRoot.activeColor
        }

        Rectangle {
            id: body
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                topMargin: 2
                bottom: parent.bottom
            }
            radius: 2
            color: root.emptyColor
            border.width: 1.5
            border.color: batteryRoot.activeColor
            clip: true

            Rectangle {
                x: 2
                width: parent.width - 4
                height: (parent.height - 4) * batteryRoot.fillRatio
                y: parent.height - height
                radius: 1
                color: batteryRoot.activeColor
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 2

        VerticalBattery {
            level: root.leftLevel
            known: root.leftKnown
        }

        VerticalBattery {
            level: root.rightLevel
            known: root.rightKnown
        }
    }
}