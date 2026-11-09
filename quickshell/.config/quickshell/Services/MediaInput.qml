import QtQuick

MouseArea {
    property double lastWheel: 0

    signal open()

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) Sys.togglePlay()
        else open()
    }

    onWheel: wheel => {
        var now = Date.now()
        if (now - lastWheel < 400) return
        lastWheel = now
        Sys.skip(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
