import QtQuick
import QtQuick.Shapes
import qs.Core
import qs.Services
import qs.Theme

// Battery readout: one big outlined "bubble" number with a pill badge, in the usual outline + 3D frame.
Plate {
    id: card

    readonly property string value: Math.round(Sys.batLevel * 100) + ""
    readonly property color face: Sys.batLow ? Theme.danger : Theme.stroke_accent

    width: Math.max(150, num.width + 52)
    height: 104
    fill: Theme.ink
    tone: Sys.batLow ? Theme.danger : Theme.accent
    edge: Theme.stroke
    edgeWidth: 2
    radius: 4

    onValueChanged: pop.restart()
    Pop { id: pop; item: num; peak: 1.08 }

    Halftone {
        anchors.fill: parent
        ink: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.08)
    }

    Text {
        x: 12
        y: 10
        text: Sys.charging ? "CHARGING" : Sys.batLow ? "LOW BATTERY" : "BATTERY"
        color: Sys.batLow ? Theme.danger : Theme.paper_dim
        font.family: UI.display
        font.pixelSize: 8
        font.weight: Font.Black
        font.letterSpacing: 1.5
    }

    FontMetrics { id: fm; font: tm.font }

    TextMetrics {
        id: tm
        font.family: UI.display
        font.pixelSize: 58
        font.weight: Font.Black
        text: card.value
    }

    // number as glyph paths: a thick round-joined stroke gives the bubbly outline, a white copy nudged
    // up-left peeks out as a glossy rim, and an offset copy is the hard shadow
    Shape {
        id: num

        x: (card.width - width) / 2 - 8
        y: 28
        width: tm.advanceWidth + 12
        height: tm.height + 10
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillRule: ShapePath.WindingFill
            fillColor: Theme.stroke
            strokeColor: Theme.stroke
            strokeWidth: 8
            joinStyle: ShapePath.RoundJoin
            PathText { x: 9; y: 9; font: tm.font; text: card.value }
        }
        ShapePath {
            fillRule: ShapePath.WindingFill
            fillColor: Theme.stroke
            strokeColor: Theme.stroke
            strokeWidth: 8
            joinStyle: ShapePath.RoundJoin
            PathText { x: 5; y: 5; font: tm.font; text: card.value }
        }
        ShapePath {
            fillRule: ShapePath.WindingFill
            fillColor: "white"
            strokeColor: "transparent"
            PathText { x: 3.5; y: 3.5; font: tm.font; text: card.value }
        }
        ShapePath {
            fillRule: ShapePath.WindingFill
            fillColor: card.face
            strokeColor: "transparent"
            PathText { x: 5; y: 5; font: tm.font; text: card.value }
        }
    }

    // badge, tucked under the number's bottom-right like the reference's "PM"
    Rectangle {
        // glyph box starts at +5 inside the shape; sit on the baseline, overlapping the last digit
        x: num.x + 5 + tm.advanceWidth - 10
        y: num.y + 5 + fm.ascent - height + 4
        width: badge.implicitWidth + 16
        height: 20
        radius: 10
        color: Theme.stroke
        border.width: 2
        border.color: card.face

        Row {
            id: badge
            anchors.centerIn: parent
            spacing: 3

            Text {
                visible: Sys.charging
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: card.face
                font.family: UI.icons
                font.pixelSize: 9
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "%"
                color: Theme.on_stroke
                font.family: UI.display
                font.pixelSize: 9
                font.weight: Font.Black
            }
        }
    }
}
