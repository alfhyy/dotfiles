import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Theme

// Proxy ID card: identity + live system meters + quick actions. Built once with its drawer;
// the meters only poll while it is open.
Plate {
    id: card

    readonly property string home: Quickshell.env("HOME")
    readonly property string user: Quickshell.env("USER") || "proxy"

    property real cpu: 0
    property real mem: 0
    property real disk: 0
    property real temp: 0
    property real uptime: 0
    property var lastCpu: null

    width: 320
    height: col.height + 4
    fill: Theme.ink
    tone: Theme.accent
    edge: Theme.stroke
    edgeWidth: 2
    radius: 4

    function poll() {
        stat.reload(); meminfo.reload(); uptimeFile.reload(); thermal.reload()

        var f = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
        var idle = f[3] + f[4], total = f.reduce((a, b) => a + b, 0)
        if (card.lastCpu) card.cpu = 1 - (idle - card.lastCpu.idle) / Math.max(1, total - card.lastCpu.total)
        card.lastCpu = { idle: idle, total: total }

        var m = meminfo.text()
        var memTotal = Number(/MemTotal:\s+(\d+)/.exec(m)[1])
        var memAvail = Number(/MemAvailable:\s+(\d+)/.exec(m)[1])
        card.mem = 1 - memAvail / memTotal

        card.uptime = parseFloat(uptimeFile.text())
        card.temp = Math.min(1, parseInt(thermal.text()) / 100000)
    }

    function fmtUptime(s) {
        var h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60)
        return h > 0 ? h + "H " + m + "M" : m + "M"
    }

    // optimistic: flips on click, then follows the theme once matugen lands
    property bool wantLight: Theme.light
    Connections {
        target: Theme
        function onLightChanged() { card.wantLight = Theme.light }
    }

    // stays open so the fade is visible; the mode is saved for the wallpaper picker
    function toggleMode() {
        wantLight = !wantLight
        var m = wantLight ? "light" : "dark"
        Quickshell.execDetached(["sh", "-c", "echo " + m + " > \"$HOME/.cache/matugen-mode\"; "
            + "matugen image \"$(awww query | sed -n 's/.*image: //p' | head -1)\" --source-color-index 0 -m " + m])
    }

    function run(cmd) {
        UI.close()
        Quickshell.execDetached(["sh", "-c", cmd])
    }

    FileView { id: stat; path: "/proc/stat"; blockLoading: true }
    FileView { id: meminfo; path: "/proc/meminfo"; blockLoading: true }
    FileView { id: uptimeFile; path: "/proc/uptime"; blockLoading: true }
    FileView { id: thermal; path: "/sys/class/thermal/thermal_zone0/temp"; blockLoading: true }
    FileView { id: host; path: "/proc/sys/kernel/hostname"; blockLoading: true }
    FileView { id: kernel; path: "/proc/sys/kernel/osrelease"; blockLoading: true }
    FileView { id: osRelease; path: "/etc/os-release"; blockLoading: true }

    Timer {
        interval: 2000
        running: UI.drawer === "profile"
        repeat: true
        triggeredOnStart: true
        onTriggered: card.poll()
    }

    Process {
        running: UI.drawer === "profile"
        command: ["df", "-P", "/"]
        stdout: StdioCollector {
            onStreamFinished: card.disk = parseInt(text.trim().split("\n")[1].split(/\s+/)[4]) / 100
        }
    }

    Halftone {
        anchors.fill: parent
        ink: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.08)
    }

    Column {
        id: col
        x: 2
        y: 2
        width: parent.width - 4

        // ── header strip ────────────────────────────────
        Rectangle {
            width: parent.width
            height: 26
            color: Theme.stroke

            Rectangle {
                width: 26
                height: 26
                color: Theme.accent

                Text {
                    anchors.centerIn: parent
                    text: "ID"
                    color: Theme.on_accent
                    font.family: UI.display
                    font.pixelSize: 10
                    font.weight: Font.Black
                }
            }

            Text {
                x: 34
                anchors.verticalCenter: parent.verticalCenter
                text: "PROXY PROFILE"
                color: Theme.on_stroke
                font.family: UI.display
                font.pixelSize: 9
                font.weight: Font.Black
                font.letterSpacing: 1.5
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "UP " + card.fmtUptime(card.uptime)
                color: Theme.stroke_accent
                font.family: UI.display
                font.pixelSize: 8
                font.weight: Font.Black
            }
        }

        // ── identity ────────────────────────────────────
        Item {
            width: parent.width
            height: 104

            Item {
                id: avatar
                x: 14
                y: 14
                width: 76
                height: 76
                rotation: avatarArea.containsMouse ? 0 : -3
                Behavior on rotation { Anim { kind: "fast" } }

                Rectangle {
                    x: 4
                    y: 4
                    width: parent.width
                    height: parent.height
                    color: Theme.accent
                    antialiasing: true
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.ink_raised
                    border.width: 2
                    border.color: Theme.stroke
                    antialiasing: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 2
                        source: "file://" + card.home + "/.face"
                        // decoded at display size: downscaling a large photo on the GPU is what made it jagged
                        sourceSize: Qt.size(width, height)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        antialiasing: true
                    }
                }

                MouseArea { id: avatarArea; anchors.fill: parent; hoverEnabled: true }
            }

            Column {
                x: avatar.x + avatar.width + 18
                y: 16
                width: parent.width - x - 12
                spacing: 7

                // name tag: parallelogram (/NAME/) with the text sheared to the same slope
                Item {
                    id: tag

                    readonly property real slant: 8 // horizontal offset across the height (~17°)

                    width: Math.min(parent.width, name.implicitWidth + 22 + slant)
                    height: 26

                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer

                        ShapePath {
                            fillColor: Theme.accent
                            strokeColor: Theme.stroke
                            strokeWidth: 2
                            joinStyle: ShapePath.MiterJoin
                            // inset by half the stroke so the outline isn't clipped
                            startX: tag.slant + 1; startY: 1
                            PathLine { x: tag.width - 1; y: 1 }
                            PathLine { x: tag.width - tag.slant - 1; y: tag.height - 1 }
                            PathLine { x: 1; y: tag.height - 1 }
                            PathLine { x: tag.slant + 1; y: 1 }
                        }
                    }

                    Text {
                        id: name
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, tag.parent.width - 22 - tag.slant)
                        elide: Text.ElideRight
                        text: card.user.toUpperCase()
                        color: Theme.on_accent
                        font.family: UI.body
                        font.pixelSize: 15
                        font.weight: Font.Black
                        antialiasing: true
                        // shear x by -k·y around the vertical centre: same lean as the shape's sides
                        readonly property real k: tag.slant / tag.height
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, -name.k, 0, name.k * name.height / 2,
                                                 0, 1, 0, 0,
                                                 0, 0, 1, 0,
                                                 0, 0, 0, 1)
                        }
                    }
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: "@" + host.text().trim() + " · " + ((/PRETTY_NAME="?([^"\n]+)/.exec(osRelease.text()) || [, "Linux"])[1])
                    color: Theme.paper
                    font.family: UI.body
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: "KERNEL " + kernel.text().trim()
                    color: Theme.paper_dim
                    font.family: UI.display
                    font.pixelSize: 8
                    font.weight: Font.Black
                    font.letterSpacing: 0.5
                }
            }
        }

        // ── live meters ─────────────────────────────────
        Column {
            x: 14
            width: parent.width - 28
            spacing: 8

            Repeater {
                model: [
                    { label: "CPU", value: card.cpu, text: Math.round(card.cpu * 100) + "%" },
                    { label: "MEM", value: card.mem, text: Math.round(card.mem * 100) + "%" },
                    { label: "DISK", value: card.disk, text: Math.round(card.disk * 100) + "%" },
                    { label: "TEMP", value: card.temp, text: Math.round(card.temp * 100) + "°" }
                ]

                Item {
                    id: meter
                    required property var modelData
                    readonly property int lit: Math.round(modelData.value * 10)
                    readonly property color tone: modelData.value > 0.85 ? Theme.danger : Theme.accent

                    width: parent.width
                    height: 14

                    Text {
                        width: 40
                        anchors.verticalCenter: parent.verticalCenter
                        text: meter.modelData.label
                        color: Theme.paper_dim
                        font.family: UI.display
                        font.pixelSize: 8
                        font.weight: Font.Black
                    }

                    Row {
                        x: 42
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index
                                readonly property bool on: index < meter.lit

                                width: 16
                                height: 8
                                color: on ? meter.tone : Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.12)
                                border.width: on ? 1.5 : 0
                                border.color: Theme.stroke
                                scale: on ? 1 : 0.75
                                Behavior on color { CAnim {} }
                                Behavior on scale { Anim { kind: "fast" } }
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: meter.modelData.text
                        color: meter.modelData.value > 0.85 ? Theme.danger : Theme.paper
                        font.family: UI.display
                        font.pixelSize: 9
                        font.weight: Font.Black
                    }
                }
            }
        }

        Item { width: 1; height: 14 }

        // ── quick actions: sticker pills ────────────────
        Row {
            x: 14
            spacing: 6

            Repeater {
                // static model (a theme-dependent one would rebuild the pills under the cursor);
                // the mode pill's label comes from card.wantLight instead
                model: [
                    { glyph: "", text: "WALL", cmd: card.home + "/.config/hypr/scripts/wallpaper-picker.sh" },
                    { glyph: "", text: "", cmd: "" },
                    { glyph: "", text: "LOCK", cmd: card.home + "/.config/hypr/lock.sh" }
                ]

                Gel {
                    id: pill
                    required property var modelData
                    required property int index

                    width: (col.width - 28 - 12) / 3
                    height: 30
                    radius: 15
                    tone: index === 0 ? Theme.accent : Theme.ink_raised
                    scale: pillArea.pressed ? 0.92 : pillArea.containsMouse ? 1.06 : 1
                    Behavior on scale { Anim { kind: "fast" } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: pill.index === 1 ? (card.wantLight ? "\uf186" : "\uf185") : pill.modelData.glyph
                            color: pill.index === 0 ? Theme.on_accent : Theme.paper
                            font.family: UI.icons
                            font.pixelSize: 11
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: pill.index === 1 ? (card.wantLight ? "DARK" : "LIGHT") : pill.modelData.text
                            color: pill.index === 0 ? Theme.on_accent : Theme.paper
                            font.family: UI.display
                            font.pixelSize: 8
                            font.weight: Font.Black
                        }
                    }

                    MouseArea {
                        id: pillArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pill.index === 1 ? card.toggleMode() : card.run(pill.modelData.cmd)
                    }
                }
            }
        }

        Item { width: 1; height: 14 }
    }
}
