import QtQuick
import qs.Services

Item {
    id: frame

    property real t: parent && parent.t !== undefined ? parent.t : 1
    property bool shown: parent && parent.shown !== undefined ? parent.shown : true
    property string legend
    property string aside
    property color asideTone: Theme.paper
    property bool crosshairs: true
    default property alias content: inner.data

    readonly property real p: shown ? t : 1
    readonly property real fade: shown ? Math.max(0, Math.min(1, (t - 0.55) / 0.45)) : t
    readonly property real a: Math.max(0, Math.min(1, p / 0.25))
    readonly property real b: Math.max(0, Math.min(1, (p - 0.2) / 0.25))
    readonly property real c: Math.max(0, Math.min(1, (p - 0.4) / 0.2))

    opacity: shown ? 1 : t

    Rectangle {
        anchors.fill: parent
        color: Theme.ink
        opacity: frame.fade
    }

    Rectangle {
        x: Math.round(frame.width * (1 - frame.a) / 2)
        y: frame.height - 1
        width: Math.round(frame.width * frame.a)
        height: 1
        color: Theme.line
    }

    Repeater {
        model: 2

        Rectangle {
            required property int index
            x: index === 0 ? 0 : frame.width - 1
            y: frame.height - height
            width: 1
            height: Math.round(frame.height * frame.b)
            color: Theme.line
        }
    }

    Repeater {
        model: 2

        Rectangle {
            required property int index
            x: index === 0 ? 0 : frame.width - width
            width: Math.round(frame.width / 2 * frame.c)
            height: 1
            color: Theme.line
        }
    }

    Item {
        anchors.fill: parent
        opacity: frame.fade

        Rectangle {
            visible: frame.legend !== ""
            x: 9
            y: -height / 2
            width: lt.implicitWidth + 8
            height: lt.implicitHeight
            color: Theme.ink

            Text {
                id: lt
                x: 4
                text: frame.legend
                color: Theme.line
                font.family: Style.system
                font.pixelSize: Style.px
            }
        }

        Rectangle {
            visible: frame.aside !== ""
            x: frame.width - width - 9
            y: -height / 2
            width: rt.implicitWidth + 8
            height: rt.implicitHeight
            color: Theme.ink

            Text {
                id: rt
                x: 4
                text: frame.aside
                color: frame.asideTone
                font.family: Style.system
                font.pixelSize: Style.px
            }
        }

        Repeater {
            model: frame.crosshairs ? 2 : 0

            Text {
                required property int index
                x: index === 0 ? 8 : frame.width - implicitWidth - 8
                y: 10
                text: "+"
                color: Theme.line
                font.family: Style.system
                font.pixelSize: Style.px
            }
        }

        Item {
            id: inner
            anchors.fill: parent
        }
    }
}
