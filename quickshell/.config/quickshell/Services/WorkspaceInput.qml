import QtQuick

MouseArea {
    property int count: 5
    property real cell: 30
    property real offset: 0
    property bool vertical: true
    property int last: -1
    property double lastWheel: 0

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor

    function at(mouse) {
        var p = (vertical ? mouse.y : mouse.x) - offset
        return Math.max(0, Math.min(count - 1, Math.floor(p / cell))) + 1
    }

    onPressed: mouse => {
        last = at(mouse)
        if (mouse.button === Qt.MiddleButton) Sys.moveTo(last)
        else Sys.goto(last)
    }

    onPositionChanged: mouse => {
        var i = at(mouse)
        if (pressed && pressedButtons === Qt.LeftButton && i !== last) {
            last = i
            Sys.goto(i)
        }
    }

    onWheel: wheel => {
        var now = Date.now()
        if (now - lastWheel < 120) return
        lastWheel = now
        Sys.step(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
