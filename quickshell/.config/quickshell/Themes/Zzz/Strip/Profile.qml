import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import qs.Core
import qs.Themes.Zzz.Kit
import qs.Services

// Proxy deck: three numbered cards (01 profile, 02 stats, 03 tray). The open card widens and turns
// to the sheet colour; the others fold to a numbered spine. Built once with its drawer; the meters
// only poll while it is open.
Item {
    id: deck

    readonly property string home: Quickshell.env("HOME")
    readonly property string user: Quickshell.env("USER") || "proxy"

    readonly property int openW: 300
    readonly property int shutW: 84
    readonly property int gap: 10
    readonly property int cardH: 320
    readonly property int artH: 140

    property int page: 0
    readonly property int trayCount: SystemTray.items.values.length
    // an empty tray never becomes a blank page: its card folds shut and can't be picked
    onTrayCountChanged: if (trayCount === 0 && page === 2) page = 0

    property real cpu: 0
    property real mem: 0
    property real disk: 0
    property real temp: 0
    property real uptime: 0
    property var lastCpu: null

    // fixed, so the drawer window never resizes while the cards trade width
    width: openW + 2 * shutW + 2 * gap
    height: cardH + 6

    function poll() {
        stat.reload(); meminfo.reload(); uptimeFile.reload(); thermal.reload()

        var f = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
        var idle = f[3] + f[4], total = f.reduce((a, b) => a + b, 0)
        if (deck.lastCpu) deck.cpu = 1 - (idle - deck.lastCpu.idle) / Math.max(1, total - deck.lastCpu.total)
        deck.lastCpu = { idle: idle, total: total }

        var m = meminfo.text()
        var memTotal = Number(/MemTotal:\s+(\d+)/.exec(m)[1])
        var memAvail = Number(/MemAvailable:\s+(\d+)/.exec(m)[1])
        deck.mem = 1 - memAvail / memTotal

        deck.uptime = parseFloat(uptimeFile.text())
        deck.temp = Math.min(1, parseInt(thermal.text()) / 100000)
    }

    function fmtUptime(s) {
        var h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60)
        return h > 0 ? h + "H " + m + "M" : m + "M"
    }

    // optimistic: flips on click, then follows the theme once matugen lands
    property bool wantLight: Theme.light
    Connections {
        target: Theme
        function onLightChanged() { deck.wantLight = Theme.light }
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
        onTriggered: deck.poll()
    }

    Process {
        running: UI.drawer === "profile"
        command: ["df", "-P", "/"]
        stdout: StdioCollector {
            onStreamFinished: deck.disk = parseInt(text.trim().split("\n")[1].split(/\s+/)[4]) / 100
        }
    }

    Row {
        y: 6
        spacing: deck.gap

        Repeater {
            // static model: per-card parts are picked by index so live values never rebuild a card
            model: 3

            Plate {
                id: card

                required property int index
                readonly property bool active: deck.page === index
                readonly property bool live: index !== 2 || deck.trayCount > 0
                readonly property bool hot: pick.containsMouse && !active && live

                width: active ? deck.openW : deck.shutW
                height: deck.cardH
                y: hot ? -5 : 0
                radius: 10
                fill: active ? Theme.sheet : Theme.ink
                tone: Theme.accent
                edge: Theme.stroke
                edgeWidth: 2
                opacity: live ? 1 : 0.55

                // one card grows while another shrinks on the same curve, so the row keeps its length
                Behavior on width { Anim {} }
                Behavior on y { Anim { kind: "fast" } }
                Behavior on fill { CAnim {} }
                Behavior on opacity { Anim { kind: "effects" } }

                MouseArea {
                    id: pick
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: !card.active && card.live ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: if (card.live) deck.page = card.index
                }

                // ── art panel: comic frame, number stamped bottom-left ──
                Item {
                    x: 6
                    y: 6
                    width: card.width - 12
                    height: deck.artH
                    clip: true

                    Loader {
                        anchors.fill: parent
                        sourceComponent: [faceArt, sysArt, trayArt][card.index]
                    }

                    // number with a hard offset shadow (Text.Outline renders Unbounded's joins badly)
                    Item {
                        x: 9
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        width: num.implicitWidth + 2
                        height: num.implicitHeight + 2
                        // shrinks to fit the folded spine; a scale, so no text relayout per frame
                        transformOrigin: Item.BottomLeft
                        scale: card.active ? 1 : 0.72
                        Behavior on scale { Anim {} }

                        Text {
                            x: 2
                            y: 2
                            text: num.text
                            color: Theme.stroke
                            font: num.font
                        }

                        Text {
                            id: num
                            text: "0" + (card.index + 1)
                            color: Theme.on_stroke
                            font.family: Style.display
                            font.pixelSize: 34
                            font.weight: Font.Black
                        }
                    }

                    Gel {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 6
                        width: 22
                        height: 22
                        radius: 11
                        tone: card.active ? Theme.stroke : Theme.accent
                        visible: card.live
                        // ↗ to pick, → on hover, ↘ while open
                        rotation: card.active ? 90 : card.hot ? 45 : 0
                        Behavior on rotation { Anim { kind: "fast" } }

                        Text {
                            anchors.centerIn: parent
                            text: "↗"
                            color: card.active ? Theme.on_stroke : Theme.on_accent
                            font.family: Style.icons
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 2
                        border.color: Theme.stroke
                    }
                }

                Text {
                    id: title
                    x: 12
                    y: deck.artH + 16
                    width: card.width - 24
                    elide: Text.ElideRight
                    text: [deck.user.toUpperCase(), "STATS", "TRAY"][card.index]
                    color: card.active ? Theme.sheet_ink : Theme.paper
                    font.family: Style.display
                    font.pixelSize: 12
                    font.weight: Font.Black
                    font.letterSpacing: 1
                }

                Text {
                    x: 12
                    y: title.y + 20
                    width: card.width - 24
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    text: [
                        "@" + host.text().trim(),
                        "UP " + deck.fmtUptime(deck.uptime),
                        deck.trayCount > 0 ? deck.trayCount + (deck.trayCount === 1 ? " APP" : " APPS") : "ALL QUIET"
                    ][card.index]
                    color: card.active ? Theme.sheet_mark : Theme.paper_dim
                    font.family: Style.body
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }

                // ── page: laid out at full width, revealed as the card opens ──
                Loader {
                    x: 12
                    y: deck.artH + 66
                    width: deck.openW - 24
                    height: deck.cardH - y - 12
                    opacity: card.active ? 1 : 0
                    visible: opacity > 0
                    sourceComponent: [profilePage, sysPage, trayPage][card.index]
                    Behavior on opacity { Anim { kind: "effects" } }
                }
            }
        }
    }

    // ── 01 profile ──────────────────────────────────────
    Component {
        id: faceArt

        Image {
            source: "file://" + deck.home + "/.face"
            // fixed decode size: the panel width animates, the decode shouldn't
            sourceSize: Qt.size(deck.openW - 12, deck.artH)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    Component {
        id: profilePage

        Item {
            Column {
                width: parent.width
                spacing: 4

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: (/PRETTY_NAME="?([^"\n]+)/.exec(osRelease.text()) || [, "Linux"])[1]
                    color: Theme.sheet_ink
                    font.family: Style.body
                    font.pixelSize: 13
                    font.weight: Font.Black
                    font.italic: true
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: "KERNEL " + kernel.text().trim()
                    color: Theme.sheet_mark
                    font.family: Style.display
                    font.pixelSize: 8
                    font.weight: Font.Black
                    font.letterSpacing: 0.5
                }
            }

            Row {
                anchors.bottom: parent.bottom
                spacing: 6

                Repeater {
                    // static model (a theme-dependent one would rebuild the pills under the cursor);
                    // the mode pill's label comes from deck.wantLight instead
                    model: [
                        { glyph: "\uf03e", text: "WALL", cmd: deck.home + "/.config/hypr/scripts/wallpaper-picker.sh" },
                        { glyph: "", text: "", cmd: "" },
                        { glyph: "\uf023", text: "LOCK", cmd: deck.home + "/.config/hypr/lock.sh" }
                    ]

                    Gel {
                        id: pill
                        required property var modelData
                        required property int index

                        width: (deck.openW - 24 - 12) / 3
                        height: 30
                        radius: 15
                        tone: index === 0 ? Theme.accent : Theme.ink
                        scale: pillArea.pressed ? 0.92 : pillArea.containsMouse ? 1.06 : 1
                        Behavior on scale { Anim { kind: "fast" } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: pill.index === 1 ? (deck.wantLight ? "" : "") : pill.modelData.glyph
                                color: pill.index === 0 ? Theme.on_accent : Theme.paper
                                font.family: Style.icons
                                font.pixelSize: 11
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: pill.index === 1 ? (deck.wantLight ? "DARK" : "LIGHT") : pill.modelData.text
                                color: pill.index === 0 ? Theme.on_accent : Theme.paper
                                font.family: Style.display
                                font.pixelSize: 8
                                font.weight: Font.Black
                            }
                        }

                        MouseArea {
                            id: pillArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pill.index === 1 ? deck.toggleMode() : deck.run(pill.modelData.cmd)
                        }
                    }
                }
            }
        }
    }

    // ── 02 system ───────────────────────────────────────
    Component {
        id: sysArt

        Rectangle {
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.accent }
                GradientStop { position: 1; color: Theme.accent_alt }
            }

            Halftone {
                anchors.fill: parent
                ink: Qt.rgba(Theme.stroke.r, Theme.stroke.g, Theme.stroke.b, 0.22)
                pitch: 5
                rmax: 2.2
            }
        }
    }

    Component {
        id: sysPage

        Column {
            spacing: 9

            Repeater {
                model: [
                    { label: "CPU", value: deck.cpu, text: Math.round(deck.cpu * 100) + "%" },
                    { label: "MEM", value: deck.mem, text: Math.round(deck.mem * 100) + "%" },
                    { label: "DISK", value: deck.disk, text: Math.round(deck.disk * 100) + "%" },
                    { label: "TEMP", value: deck.temp, text: Math.round(deck.temp * 100) + "°" }
                ]

                Item {
                    id: meter
                    required property var modelData
                    readonly property int lit: Math.round(modelData.value * 10)
                    readonly property color tone: modelData.value > 0.85 ? Theme.danger : Theme.sheet_mark

                    width: deck.openW - 24
                    height: 14

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: meter.modelData.label
                        color: Theme.sheet_ink
                        opacity: 0.7
                        font.family: Style.display
                        font.pixelSize: 8
                        font.weight: Font.Black
                    }

                    Row {
                        x: 40
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index
                                readonly property bool on: index < meter.lit

                                width: 16
                                height: 8
                                color: on ? meter.tone : Qt.rgba(Theme.sheet_ink.r, Theme.sheet_ink.g, Theme.sheet_ink.b, 0.15)
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
                        color: meter.modelData.value > 0.85 ? Theme.danger : Theme.sheet_ink
                        font.family: Style.display
                        font.pixelSize: 9
                        font.weight: Font.Black
                    }
                }
            }
        }
    }

    // ── 03 tray ─────────────────────────────────────────
    Component {
        id: trayArt

        Rectangle {
            gradient: Gradient {
                GradientStop { position: 0; color: deck.trayCount > 0 ? Theme.accent_alt : Theme.line }
                GradientStop { position: 1; color: deck.trayCount > 0 ? Theme.accent_soft : Theme.ink_raised }
            }

            Halftone {
                anchors.fill: parent
                ink: Qt.rgba(Theme.stroke.r, Theme.stroke.g, Theme.stroke.b, 0.22)
                pitch: 5
                rmax: 2.2
            }

            // the first few apps peek out as stickers, so the folded card shows what's inside
            Column {
                x: 8
                y: 8
                spacing: 4

                Repeater {
                    model: deck.trayCount > 0 ? SystemTray.items.values.slice(0, 3) : []

                    Rectangle {
                        required property var modelData
                        width: 22
                        height: 22
                        radius: 11
                        color: Theme.ink
                        border.width: 2
                        border.color: Theme.stroke

                        Image {
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            source: parent.modelData.icon
                            sourceSize: Qt.size(28, 28)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: trayPage

        Item {
            id: tray
            property var hot: null

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: tray.hot ? (tray.hot.tooltipTitle || tray.hot.title || tray.hot.id).toUpperCase()
                               : "CLICK OPENS · RIGHT-CLICK MENU"
                color: Theme.sheet_mark
                font.family: Style.display
                font.pixelSize: 8
                font.weight: Font.Black
                font.letterSpacing: 0.5
            }

            Flow {
                y: 18
                width: parent.width
                spacing: 9

                Repeater {
                    model: SystemTray.items

                    Gel {
                        id: sticker
                        required property SystemTrayItem modelData

                        width: 44
                        height: 44
                        radius: 22
                        tone: Theme.ink
                        scale: tap.pressed ? 0.9 : tap.containsMouse ? 1.1 : 1
                        rotation: tap.containsMouse ? 0 : -6
                        Behavior on scale { Anim { kind: "fast" } }
                        Behavior on rotation { Anim { kind: "fast" } }

                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: sticker.modelData.icon
                            sourceSize: Qt.size(48, 48)
                        }

                        MouseArea {
                            id: tap
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: tray.hot = containsMouse ? sticker.modelData : (tray.hot === sticker.modelData ? null : tray.hot)
                            onClicked: mouse => {
                                var it = sticker.modelData
                                var menu = it.hasMenu && (mouse.button === Qt.RightButton || it.onlyMenu)
                                if (menu) {
                                    var p = sticker.mapToItem(null, 0, sticker.height + 4)
                                    it.display(QsWindow.window, p.x, p.y)
                                } else if (mouse.button === Qt.LeftButton) {
                                    it.activate()
                                } else {
                                    it.secondaryActivate()
                                }
                            }
                            onWheel: wheel => sticker.modelData.scroll(wheel.angleDelta.y, false)
                        }
                    }
                }
            }
        }
    }
}
