import QtQuick
import qs.Core
import qs.Services

Plate {
    id: cal

    property int shift: 0

    readonly property date view: new Date(Sys.now.getFullYear(), Sys.now.getMonth() + shift, 1)
    readonly property int lead: (view.getDay() + 6) % 7
    readonly property int days: new Date(view.getFullYear(), view.getMonth() + 1, 0).getDate()
    readonly property string letters: "MTWTFSS"

    width: 290
    height: 322
    fill: Theme.sheet
    tone: Theme.accent
    edge: Theme.stroke
    edgeWidth: 2

    Halftone {
        anchors.fill: parent
        anchors.margins: 2
        ink: Qt.rgba(Theme.sheet_ink.r, Theme.sheet_ink.g, Theme.sheet_ink.b, 0.1)
    }

    MouseArea {
        anchors.fill: parent
        property double last: 0

        onWheel: wheel => {
            var now = Date.now()
            if (now - last < 150) return
            last = now
            cal.shift += wheel.angleDelta.y > 0 ? -1 : 1
        }
    }

    Rectangle {
        x: 2
        y: 2
        width: parent.width - 4
        height: 26
        color: Theme.stroke

        Text {
            x: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "CALENDAR"
            color: Theme.on_stroke
            font.family: UI.display
            font.pixelSize: 10
            font.weight: Font.Black
            font.letterSpacing: 3
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: cal.view.getFullYear()
            color: Theme.stroke_accent
            font.family: UI.display
            font.pixelSize: 11
            font.weight: Font.Black
        }
    }

    Text {
        x: 12
        y: 32
        text: ("0" + (cal.shift === 0 ? Sys.now.getDate() : 1)).slice(-2)
        color: Theme.sheet_ink
        font.family: UI.display
        font.pixelSize: 62
        font.weight: Font.Black

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: cal.shift = 0
        }
    }

    Text {
        x: 112
        y: 76
        text: Qt.formatDateTime(cal.view, "MMM").toUpperCase()
        color: Theme.sheet_mark
        font.family: UI.display
        font.pixelSize: 20
        font.weight: Font.Black
        font.italic: true
    }

    Repeater {
        model: 7

        Text {
            required property int index

            x: 12 + index * 38
            y: 110
            width: 38
            horizontalAlignment: Text.AlignHCenter
            text: cal.letters[index]
            color: index >= 5 ? Theme.sheet_mark : Theme.sheet_ink
            opacity: index >= 5 ? 1 : 0.6
            font.family: UI.display
            font.pixelSize: 10
            font.weight: Font.Black
        }
    }

    Rectangle {
        x: 12
        y: 126
        width: 266
        height: 2
        color: Theme.stroke
    }

    // one pill for today, behind the numbers (was a hidden Gel in each of the 42 cells)
    Gel {
        readonly property int i: cal.lead + Sys.now.getDate() - 1
        visible: cal.shift === 0
        x: 12 + (i % 7) * 38 + 4
        y: 132 + Math.floor(i / 7) * 30 + 3
        width: 30
        height: 24
        radius: 12
    }

    Repeater {
        model: 42

        Item {
            id: cell
            required property int index

            readonly property int day: index - cal.lead + 1
            readonly property bool valid: day >= 1 && day <= cal.days
            readonly property bool today: valid && cal.shift === 0 && day === Sys.now.getDate()

            x: 12 + (index % 7) * 38
            y: 132 + Math.floor(index / 7) * 30
            width: 38
            height: 30

            Text {
                anchors.centerIn: parent
                text: cell.valid ? cell.day : ""
                color: cell.today ? Theme.on_accent : index % 7 >= 5 ? Theme.sheet_mark : Theme.sheet_ink
                font.family: UI.display
                font.pixelSize: 12
                font.weight: Font.Black
            }
        }
    }
}