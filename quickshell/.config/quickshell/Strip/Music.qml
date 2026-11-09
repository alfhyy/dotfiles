import QtQuick
import qs.Core
import qs.Services

Plate {
    id: music

    readonly property var p: Sys.player
    readonly property var flat: new Array(28).fill(0.06)
    property var idle: flat
    readonly property var spectrum: Sys.playing ? Sys.spectrum : idle
    property real phase: 0

    width: 372
    height: 188
    fill: Theme.ink
    tone: Theme.accent
    edge: Theme.stroke
    edgeWidth: 3

    Connections {
        target: Sys
        function onPlayingChanged() { if (!Sys.playing) music.idle = music.flat }
    }

    // standby breathing wave; cava drives the spectrum while playing
    Timer {
        running: !Sys.player && UI.drawer === "music"
        interval: 120
        repeat: true
        onTriggered: {
            music.phase += 0.45
            var v = 0.12 + 0.07 * Math.sin(music.phase) + 0.04 * Math.sin(music.phase * 2.7)
            music.idle = [v].concat(music.idle.slice(0, 27))
        }
    }

    // One position value for the bar and both labels, read straight from the player (Quickshell
    // extrapolates it locally, so reading is free). Separate 1s-refreshed bindings showed a stale
    // 0:00 on open and let the bar lag behind track changes.
    readonly property bool open: UI.drawer === "music"
    property real pos: 0
    readonly property real len: Sys.length
    readonly property real progress: len > 0 ? Math.max(0, Math.min(1, pos / len)) : 0
    property real wavePhase: 0
    // wave flattens out when paused
    property real amp: Sys.playing ? 3 : 0
    Behavior on amp { Anim { kind: "effects" } }

    function refresh() { pos = p ? p.position : 0 }

    onOpenChanged: if (open) refresh()
    Connections {
        target: Sys
        function onPlayerChanged() { music.refresh() }
        function onTitleChanged() { music.refresh() }
        function onLengthChanged() { music.refresh() }
        function onPlayingChanged() { music.refresh() }
    }

    FrameAnimation {
        running: Sys.playing && music.open
        onTriggered: {
            music.refresh()
            music.wavePhase = (music.wavePhase + frameTime * 4) % 6.2831853
        }
    }

    Halftone {
        anchors.fill: parent
        ink: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.1)
    }

    Text {
        x: 14
        y: 10
        text: Sys.playing ? "NOW PLAYING" : Sys.player ? "PAUSED" : "STANDBY"
        color: Theme.accent
        font.family: UI.display
        font.pixelSize: 9
        font.weight: Font.Black
        font.letterSpacing: 3
    }

    Cover {
        x: 14
        y: 28
        width: 96
        height: 96
    }

    Text {
        x: 124
        y: 26
        width: parent.width - 138
        text: Sys.title || "NOTHING PLAYING"
        elide: Text.ElideRight
        color: Theme.paper
        font.family: UI.display
        font.pixelSize: 18
        font.weight: Font.Black
    }

    Text {
        x: 124
        y: 52
        width: parent.width - 138
        text: Sys.artist || "\u2014"
        elide: Text.ElideRight
        color: Theme.paper_dim
        font.family: UI.display
        font.pixelSize: 11
        font.weight: Font.Bold
    }

    Wave {
        x: 124
        y: 74
        width: parent.width - 138
        height: 50
        // style: "line"
        values: music.spectrum
    }

    Item {
        x: 14
        y: 131
        width: parent.width - 28
        height: 20

        ShaderEffect {
            anchors.fill: parent
            property real progress: music.progress
            property real phase: music.wavePhase
            property real amp: music.amp
            property size px: Qt.size(width, height)
            property color playedColor: Theme.accent
            property color trackColor: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.25)
            fragmentShader: Qt.resolvedUrl("shaders/squiggle.frag.qsb")
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (!music.p || !music.p.canSeek || !music.p.positionSupported) return
                // 6px = the shader's PAD
                music.p.position = Math.max(0, Math.min(1, (mouse.x - 6) / (width - 12))) * music.len
                music.refresh()
            }
        }
    }

    Text {
        x: 14
        y: 162
        text: Sys.fmt(music.pos)
        color: Theme.paper_dim
        font.family: UI.display
        font.pixelSize: 9
        font.weight: Font.Bold
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 14
        y: 162
        text: Sys.fmt(music.len)
        color: Theme.paper_dim
        font.family: UI.display
        font.pixelSize: 9
        font.weight: Font.Bold
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 154
        spacing: 8

        Repeater {
            model: 3

            Gel {
                id: btn

                required property int index

                width: index === 1 ? 52 : 38
                height: 24
                radius: 12
                tone: index === 1 ? Theme.accent : Theme.ink_raised
                opacity: Sys.player ? 1 : 0.4
                scale: area.pressed ? 0.92 : area.containsMouse ? 1.08 : 1

                Text {
                    anchors.centerIn: parent
                    text: btn.index === 0 ? "\uf048" : btn.index === 2 ? "\uf051" : Sys.playing ? "\uf04c" : "\uf04b"
                    color: btn.index === 1 ? Theme.on_accent : Theme.paper
                    font.family: UI.icons
                    font.pixelSize: 10
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (btn.index === 1)
                            Sys.togglePlay();
                        else
                            Sys.skip(btn.index === 0 ? -1 : 1);
                    }
                }

                Behavior on scale {
                    Anim {
                        kind: "fast"
                    }

                }

            }

        }

    }

}
