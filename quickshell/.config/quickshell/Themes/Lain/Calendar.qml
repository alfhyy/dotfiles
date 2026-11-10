import QtQuick
import qs.Services
import qs.Themes.Lain.Kit

Frame {
    id: cal

    readonly property CalendarModel m: CalendarModel {}
    readonly property var days: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    readonly property int week: isoWeek(Sys.now)

    function isoWeek(d) {
        var t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
        var n = t.getUTCDay() || 7
        t.setUTCDate(t.getUTCDate() + 4 - n)
        var y = new Date(Date.UTC(t.getUTCFullYear(), 0, 1))
        return Math.ceil(((t - y) / 86400000 + 1) / 7)
    }

    width: 300
    height: 320
    legend: "NAVI:CAL"
    aside: cal.m.view.getFullYear()

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => cal.m.wheel(wheel.angleDelta.y)
    }

    Outline {
        x: 16
        y: 24
        text: ("0" + (cal.m.today || 1)).slice(-2)
        font.family: Style.display
        font.pixelSize: 64

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: cal.m.reset()
        }
    }

    Text {
        x: 122
        y: 30
        width: 162
        elide: Text.ElideRight
        text: Qt.formatDateTime(cal.m.view, "MMMM").toUpperCase()
        color: Theme.paper
        font.family: Style.display
        font.pixelSize: 18
        font.weight: Font.Light
        font.letterSpacing: 1
    }

    Text {
        x: 122
        y: 56
        width: 162
        elide: Text.ElideRight
        text: "WEEK " + cal.week + " · " + Qt.formatDateTime(Sys.now, "ddd").toUpperCase()
        color: Theme.paper_dim
        font.family: Style.system
        font.pixelSize: Style.px
    }

    Text {
        x: 122
        y: 72
        width: 162
        elide: Text.ElideRight
        text: "カレンダー"
        color: Theme.line
        opacity: 0.6
        font.family: Style.kana
        font.pixelSize: 20
    }

    Repeater {
        model: 8

        Rectangle {
            required property int index
            x: 16 + index * 38
            y: 112
            width: 1
            height: 164
            color: Theme.line
        }
    }

    Repeater {
        model: [112, 132, 156, 180, 204, 228, 252, 276]

        Rectangle {
            required property int modelData
            x: 16
            y: modelData
            width: 267
            height: 1
            color: Theme.line
        }
    }

    Repeater {
        model: 7

        Text {
            required property int index
            x: 16 + index * 38
            y: 112
            width: 38
            height: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: cal.days[index]
            color: Theme.paper_dim
            font.family: Style.system
            font.pixelSize: Style.px
        }
    }

    Repeater {
        model: 42

        Item {
            id: cell

            required property int index
            readonly property int day: index - cal.m.lead + 1
            readonly property bool valid: day >= 1 && day <= cal.m.days
            readonly property bool today: valid && day === cal.m.today

            x: 16 + (index % 7) * 38
            y: 132 + Math.floor(index / 7) * 24
            width: 38
            height: 24

            Rectangle {
                visible: cell.today
                x: 1
                y: 1
                width: parent.width - 1
                height: parent.height - 1
                color: Theme.accent
            }

            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: cell.valid ? ("0" + cell.day).slice(-2) : "··"
                color: cell.today ? Theme.on_accent : !cell.valid ? Theme.line : cell.index % 7 >= 5 ? Theme.paper_dim : Theme.paper
                font.family: Style.system
                font.pixelSize: Style.px
            }
        }
    }

    Leader {
        x: 16
        y: 290
        width: 268
        lead: cal.m.shift === 0 ? ">> " + Qt.formatDateTime(Sys.now, "ddd dd.MM.yyyy").toUpperCase() : ">> VIEWING"
        tail: cal.m.shift === 0 ? "W" + cal.week : (cal.m.shift > 0 ? "+" : "") + cal.m.shift + (Math.abs(cal.m.shift) === 1 ? " MONTH" : " MONTHS")
    }
}
