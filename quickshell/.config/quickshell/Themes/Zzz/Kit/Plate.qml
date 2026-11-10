import QtQuick
import qs.Services

Item {
    id: plate

    default property alias content: face.data

    property color fill: Theme.ink
    property color tone: Theme.accent
    property color edge: "transparent"
    property int edgeWidth: 0
    property real radius: 0
    property bool raised: true

    Repeater {
        model: plate.raised ? 2 : 0

        Rectangle {
            required property int index

            x: Style.depth * (index === 0 ? 1 : 0.5)
            y: x
            width: plate.width
            height: plate.height
            radius: plate.radius
            color: index === 0 ? plate.tone : Qt.darker(plate.tone, 1.5)
        }
    }

    Rectangle {
        id: face
        anchors.fill: parent
        radius: plate.radius
        color: plate.fill
        clip: true
    }

    // drawn above content so halftone/decals never paint over the outline
    Rectangle {
        anchors.fill: parent
        radius: plate.radius
        color: "transparent"
        border.width: plate.edgeWidth
        border.color: plate.edge
        antialiasing: true
    }
}
