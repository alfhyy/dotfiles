import QtQuick

// bottom-to-top label: sizes to its text, ping-pong scrolls when longer than maxLength
Item {
    id: v

    property alias text: label.text
    property alias color: label.color
    property alias font: label.font
    property real maxLength: 150
    property bool scroll: true
    readonly property real overflow: Math.ceil(Math.max(0, label.implicitWidth - maxLength))
    property real shift: 0
    property int dir: 1

    width: label.implicitHeight
    height: Math.min(label.implicitWidth, maxLength)
    clip: overflow > 0

    function rewind() {
        shift = 0
        dir = 1
        marquee.interval = 1800
    }

    onTextChanged: {
        rewind()
        if (marquee.running) marquee.restart()
    }

    Text {
        id: label
        y: v.height + v.shift
        rotation: -90
        transformOrigin: Item.TopLeft
    }

    // A Timer, not an Animation: any running Animation (even a PauseAnimation) makes Qt render the
    // window every vsync, which cost ~4% CPU forever while a long title was playing. 1px per 28ms,
    // whole pixels (no native-text shimmer), and zero frames during the end pauses.
    Timer {
        id: marquee
        running: v.overflow > 0 && v.scroll && v.visible
        repeat: true
        interval: 1800
        onRunningChanged: if (!running) v.rewind()
        onTriggered: {
            v.shift = Math.max(0, Math.min(v.overflow, v.shift + v.dir))
            if (v.shift === v.overflow || v.shift === 0) {
                v.dir = -v.dir
                interval = v.dir < 0 ? 1400 : 1800
            } else {
                interval = 28
            }
        }
    }
}
