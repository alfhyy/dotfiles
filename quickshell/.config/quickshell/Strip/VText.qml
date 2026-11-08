import QtQuick

// bottom-to-top label: sizes to its text, ping-pong scrolls when longer than maxLength
Item {
    id: v

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font
    property real maxLength: 150
    property bool scroll: true
    readonly property real overflow: Math.max(0, label.implicitWidth - maxLength)
    property real shift: 0

    width: label.implicitHeight
    height: Math.min(label.implicitWidth, maxLength)
    clip: overflow > 0

    onTextChanged: {
        shift = 0
        if (marquee.running) marquee.restart()
    }

    Text {
        id: label
        y: v.height + v.shift
        rotation: -90
        transformOrigin: Item.TopLeft
    }

    // only a transform changes per frame (no relayout), and the long pauses leave the rail idle most of the time
    SequentialAnimation {
        id: marquee
        running: v.overflow > 0 && v.scroll && v.visible
        loops: Animation.Infinite
        onStopped: v.shift = 0

        PauseAnimation { duration: 1800 }
        NumberAnimation { target: v; property: "shift"; to: v.overflow; duration: v.overflow * 28; easing.type: Easing.InOutSine }
        PauseAnimation { duration: 1400 }
        NumberAnimation { target: v; property: "shift"; to: 0; duration: v.overflow * 28; easing.type: Easing.InOutSine }
    }
}
