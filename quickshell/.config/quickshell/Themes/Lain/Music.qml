import QtQuick
import qs.Core
import qs.Services
import qs.Themes.Lain.Kit

Frame {
    id: music

    readonly property var p: Sys.player
    readonly property bool open: UI.drawer === "music"
    readonly property real len: Sys.length
    property real pos: 0
    readonly property real progress: len > 0 ? Math.max(0, Math.min(1, pos / len)) : 0
    readonly property int ticks: 46
    readonly property bool canSeek: p !== null && p.canSeek && p.positionSupported

    function refresh() {
        pos = p ? p.position : 0
    }

    function stamp(s) {
        var m = Math.floor(s / 60)
        var r = Math.floor(s % 60)
        return ("0" + m).slice(-2) + ":" + ("0" + r).slice(-2)
    }

    width: 360
    height: 172
    legend: "SIG"
    aside: Sys.playing ? "PLAYING" : p ? "PAUSED" : "NO SIGNAL"
    asideTone: Sys.playing ? Theme.accent : Theme.paper_dim

    onOpenChanged: if (open) refresh()

    Connections {
        target: Sys
        function onPlayerChanged() { music.refresh() }
        function onTitleChanged() {
            music.refresh()
            flicker.fire()
        }
        function onLengthChanged() { music.refresh() }
        function onPlayingChanged() { music.refresh() }
    }

    Timer {
        interval: 1000
        repeat: true
        running: music.open && Sys.playing
        onTriggered: music.refresh()
    }

    Rectangle {
        id: art
        x: 14
        y: 18
        width: 72
        height: 72
        color: Theme.ink
        border.width: 1
        border.color: Theme.line

        Image {
            id: cover
            anchors.fill: parent
            anchors.margins: 1
            source: Sys.cover
            sourceSize: Qt.size(144, 144)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            opacity: 0.75
        }

        Repeater {
            model: cover.status === Image.Ready ? 35 : 0

            Rectangle {
                required property int index
                x: 1
                y: 1 + index * 2
                width: art.width - 2
                height: 1
                color: Theme.ink
                opacity: 0.45
            }
        }

        Text {
            anchors.centerIn: parent
            visible: cover.status !== Image.Ready
            text: "NO IMAGE"
            color: Theme.line
            font.family: Style.system
            font.pixelSize: Style.px
        }
    }

    Item {
        id: info
        x: 100
        y: 16
        width: 246
        height: 40

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: Sys.player ? (Sys.title || "UNTITLED") : "NO SIGNAL"
            color: Sys.player ? Theme.paper : Theme.paper_dim
            font.family: Style.body
            font.pixelSize: 13
            font.weight: Font.Bold
        }

        Text {
            y: 20
            width: parent.width
            elide: Text.ElideRight
            text: Sys.artist || "—"
            color: Theme.paper_dim
            font.family: Style.system
            font.pixelSize: Style.px
        }
    }

    Glitch { id: flicker; target: info; property: "opacity"; on: 0.25; off: 1 }

    Item {
        x: 100
        y: 58
        width: 246
        height: 32

        Rectangle {
            y: parent.height - 1
            width: parent.width
            height: 1
            color: Theme.line
        }

        Repeater {
            model: Sys.spectrum.length

            Rectangle {
                required property int index
                readonly property real slot: 246 / Sys.spectrum.length

                x: Math.round(index * slot + (slot - 3) / 2)
                y: parent.height - 1 - height
                width: 3
                height: Sys.playing ? Math.max(1, Math.round(Sys.spectrum[index] * 30)) : 1
                color: Sys.playing ? Theme.accent : Theme.line
            }
        }
    }

    Item {
        id: ruler
        x: 14
        y: 102
        width: 332
        height: 10

        Repeater {
            model: music.ticks

            Rectangle {
                required property int index
                readonly property bool lit: (index + 0.5) / music.ticks <= music.progress

                x: Math.round(index * (ruler.width - 1) / (music.ticks - 1))
                y: index % 5 === 0 ? 0 : 3
                width: 1
                height: index % 5 === 0 ? 10 : 7
                color: lit ? Theme.accent : Theme.line
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            enabled: music.canSeek
            cursorShape: music.canSeek ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: mouse => {
                music.p.position = Math.max(0, Math.min(1, (mouse.x - 4) / ruler.width)) * music.len
                music.refresh()
            }
        }
    }

    Leader {
        x: 14
        y: 116
        width: 332
        lead: music.stamp(music.pos)
        tail: music.stamp(music.len)
        tone: Theme.paper
        dim: Theme.paper_dim
    }

    Row {
        x: 14
        y: 138
        spacing: 8

        Repeater {
            model: ["PREV", "", "NEXT"]

            Rectangle {
                id: key

                required property string modelData
                required property int index
                readonly property bool hot: keyArea.containsMouse && Sys.player !== null

                width: index === 1 ? 152 : 82
                height: 22
                color: hot ? Theme.accent : "transparent"
                border.width: 1
                border.color: hot ? Theme.accent : Theme.line

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 8
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: key.index === 1 ? (Sys.playing ? "|| PAUSE" : ">> PLAY") : key.index === 0 ? "|<< PREV" : "NEXT >>|"
                    color: key.hot ? Theme.on_accent : Sys.player ? Theme.paper : Theme.line
                    font.family: Style.system
                    font.pixelSize: Style.px
                }

                MouseArea {
                    id: keyArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Sys.player ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (key.index === 1) Sys.togglePlay()
                        else Sys.skip(key.index === 0 ? -1 : 1)
                    }
                }
            }
        }
    }
}
