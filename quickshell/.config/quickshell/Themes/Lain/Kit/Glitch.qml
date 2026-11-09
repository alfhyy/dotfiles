import QtQuick

SequentialAnimation {
    id: g

    property QtObject target
    property string property: "x"
    property real on: 2
    property real off: 0

    function fire() {
        restart()
    }

    PropertyAction { target: g.target; property: g.property; value: g.on }
    PauseAnimation { duration: 34 }
    PropertyAction { target: g.target; property: g.property; value: g.off }
}
