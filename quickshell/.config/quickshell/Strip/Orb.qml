import QtQuick
import QtQuick.Shapes
import qs.Core
import qs.Theme

Item {
    id: orb

    property string glyph: ""
    property real level: -1
    property bool dim: false
    property bool alert: false
    readonly property bool hovered: area.containsMouse

    property real shown: Math.max(0, level)
    Behavior on shown { Anim { kind: "effects" } }

    signal clicked()
    signal wheeled(real delta)

    // value changed: emphasise the ring, never cover it with the chip
    function ping() { ringPop.restart() }

    width: UI.railW
    height: 38

    onGlyphChanged: pop.restart()

    // 24 * 1.12 = 26.9 stays inside the ring's 28.5px inner edge
    Pop { id: pop; item: inner; peak: ring.visible ? 1.12 : 1.25 }
    Pop { id: ringPop; item: ring; peak: 1.12 }

    Item {
        id: dial
        anchors.centerIn: parent
        width: 34
        height: 34
        // ring lives inside the scaled item so hover never closes the gap;
        // worst case (hover + ping) 34 * 1.1 * 1.12 ≈ 42px, inside the 56px within the outline
        scale: area.pressed ? 0.9 : orb.hovered ? 1.1 : 1
        Behavior on scale { Anim { kind: "fast" } }

        Item {
            id: inner
            anchors.centerIn: parent
            width: 24
            height: 24

            Gel {
                anchors.fill: parent
                radius: 12
                tone: orb.alert ? Theme.danger : orb.dim ? Theme.ink_raised : Theme.accent
            }

            Text {
                anchors.centerIn: parent
                text: orb.glyph
                color: orb.alert ? Theme.on_danger : orb.dim ? Theme.paper_dim : Theme.on_accent
                font.family: UI.icons
                font.pixelSize: 11
            }
        }

        Shape {
            id: ring
            anchors.fill: parent
            visible: orb.level >= 0
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeWidth: 2.5
                strokeColor: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.15)
                PathAngleArc { centerX: 17; centerY: 17; radiusX: 15.5; radiusY: 15.5; sweepAngle: 360 }
            }
            ShapePath {
                fillColor: "transparent"
                strokeWidth: 2.5
                capStyle: ShapePath.RoundCap
                strokeColor: orb.alert ? Theme.danger : orb.dim ? Theme.line : Theme.accent_alt
                PathAngleArc { centerX: 17; centerY: 17; radiusX: 15.5; radiusY: 15.5; startAngle: -90; sweepAngle: 360 * Math.max(0.02, orb.shown) }
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: orb.clicked()
        onWheel: wheel => orb.wheeled(wheel.angleDelta.y)
    }
}
