import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.Core
import qs.Services

Item {
    id: card

    required property Notification modelData
    readonly property Notification n: modelData

    // snapshot: the Notification object is deleted on dismiss, but the card still animates out
    property string app: ""
    property string summary: ""
    property string body: ""
    property string icon: ""
    property string badge: "00"
    property int urgency: NotificationUrgency.Normal
    property var acts: []
    property double expireMs: -1

    readonly property bool critical: urgency === NotificationUrgency.Critical
    readonly property bool low: urgency === NotificationUrgency.Low
    readonly property color tone: critical ? Theme.danger : low ? Theme.line : Theme.accent
    readonly property color onTone: critical ? Theme.on_danger : low ? Theme.ink : Theme.on_accent
    readonly property int timeout: critical ? 0 : expireMs > 0 ? expireMs : low ? 4000 : 6500
    readonly property int segments: 10
    property int remaining: segments
    readonly property double at: Date.now()
    readonly property bool hovered: hover.containsMouse

    function sync() {
        if (!n) return
        app = n.appName || "SYSTEM"
        summary = n.summary
        body = n.body
        badge = ("0" + (n.id % 100)).slice(-2)
        urgency = n.urgency
        expireMs = n.expireTimeout
        acts = Array.from(n.actions).filter(a => a.identifier !== "default").map(a => ({ id: a.identifier, text: a.text }))

        var img = n.image
        if (!img && n.appIcon)
            img = n.appIcon.indexOf("://") >= 0 ? n.appIcon
                : n.appIcon.startsWith("/") ? "file://" + n.appIcon
                : Quickshell.iconPath(n.appIcon, true)
        if (!img && n.desktopEntry) {
            var entry = DesktopEntries.byId(n.desktopEntry)
            if (entry) img = Quickshell.iconPath(entry.icon, true)
        }
        icon = img || ""
        remaining = segments
        pop.restart()
    }

    function invoke(id) {
        var a = n ? Array.from(n.actions).find(x => x.identifier === id) : null
        if (a) a.invoke()
        else if (n) n.dismiss()
    }

    function dismiss() { if (n) n.dismiss() }

    Component.onCompleted: sync()

    Connections {
        target: card.n
        function onSummaryChanged() { card.sync() }
        function onBodyChanged() { card.sync() }
        function onImageChanged() { card.sync() }
        function onActionsChanged() { card.sync() }
        function onUrgencyChanged() { card.sync() }
    }

    width: 340
    height: plate.height + UI.depth

    Pop { id: pop; item: badgeBox; peak: 1.2 }

    Timer {
        interval: Math.max(50, card.timeout / card.segments)
        repeat: true
        running: card.timeout > 0 && !card.hovered && card.remaining > 0
        onTriggered: {
            card.remaining--
            if (card.remaining === 0 && card.n) card.n.expire()
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => mouse.button === Qt.RightButton ? card.dismiss() : card.invoke("default")
    }

    Plate {
        id: plate

        // pull-out on hover: the card slides toward the screen like a drawer tab
        x: card.hovered ? -6 : 0
        Behavior on x { Anim { kind: "fast" } }

        width: card.width - UI.depth
        height: col.height + 4
        radius: 4
        fill: Theme.ink
        // 3D layers carry the urgency colour
        tone: card.tone
        edge: Theme.stroke
        edgeWidth: 2

        Halftone {
            anchors.fill: parent
            ink: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.07)
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
                color: card.critical ? Theme.danger : Theme.stroke

                Rectangle {
                    id: badgeBox
                    width: 26
                    height: 26
                    color: card.critical ? Theme.stroke : card.tone

                    Text {
                        anchors.centerIn: parent
                        text: card.critical ? "!!" : card.badge
                        color: card.critical ? Theme.danger : card.onTone
                        font.family: UI.display
                        font.pixelSize: 10
                        font.weight: Font.Black
                    }
                }

                Text {
                    x: 34
                    anchors.verticalCenter: parent.verticalCenter
                    width: stamp.x - x - 8
                    text: card.app.toUpperCase()
                    elide: Text.ElideRight
                    color: card.critical ? Theme.on_danger : Theme.on_stroke
                    font.family: UI.display
                    font.pixelSize: 9
                    font.weight: Font.Black
                    font.letterSpacing: 1.5
                }

                Text {
                    id: stamp
                    anchors.right: close.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    readonly property int mins: Math.floor((Sys.now.getTime() - card.at) / 60000)
                    text: mins < 1 ? "NOW" : mins < 60 ? mins + "M" : Math.floor(mins / 60) + "H"
                    color: card.critical ? Theme.on_danger : card.low ? Theme.on_stroke : Theme.stroke_accent
                    font.family: UI.display
                    font.pixelSize: 8
                    font.weight: Font.Black
                }

                // square close box, like the game's dialog windows
                Rectangle {
                    id: close
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    color: closeArea.containsMouse ? card.tone : "transparent"
                    border.width: 2
                    border.color: card.critical ? Theme.on_danger : closeArea.containsMouse ? card.tone : Theme.on_stroke
                    scale: closeArea.pressed ? 0.85 : 1
                    Behavior on color { CAnim {} }
                    Behavior on scale { Anim { kind: "fast" } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: closeArea.containsMouse ? card.onTone : card.critical ? Theme.on_danger : Theme.on_stroke
                        font.family: UI.icons
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.dismiss()
                    }
                }
            }

            // ── content ─────────────────────────────────────
            Item {
                width: parent.width
                height: Math.max(art.visible ? art.height : 0, text.height) + 20

                Rectangle {
                    id: art
                    x: 8
                    y: 10
                    width: 46
                    height: 46
                    visible: card.icon !== "" && artImg.status !== Image.Error
                    color: Theme.ink_raised
                    border.width: 2
                    border.color: Theme.stroke

                    Image {
                        id: artImg
                        anchors.fill: parent
                        anchors.margins: 2
                        source: card.icon
                        sourceSize: Qt.size(92, 92)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Column {
                    id: text
                    x: art.visible ? art.x + art.width + 12 : 10
                    y: 10
                    width: parent.width - x - 10
                    spacing: 4

                    Text {
                        width: parent.width
                        text: card.summary
                        visible: text !== ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: Theme.paper
                        font.family: UI.body
                        font.pixelSize: 14
                        font.weight: Font.Black
                        font.italic: true
                    }

                    Text {
                        width: parent.width
                        text: card.body
                        visible: text !== ""
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        color: Theme.paper_dim
                        linkColor: card.tone
                        font.family: UI.body
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        lineHeight: 1.1
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }
            }

            // ── actions: sticker pills, first one filled ─────
            Item {
                width: parent.width
                height: card.acts.length > 0 ? 34 : 0
                visible: card.acts.length > 0

                Row {
                    x: 8
                    spacing: 6

                    Repeater {
                        model: card.acts

                        Gel {
                            id: pill
                            required property var modelData
                            required property int index

                            width: label.implicitWidth + 24
                            height: 24
                            radius: 12
                            tone: index === 0 ? card.tone : Theme.ink_raised
                            scale: pillArea.pressed ? 0.92 : pillArea.containsMouse ? 1.06 : 1
                            Behavior on scale { Anim { kind: "fast" } }

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: pill.modelData.text.toUpperCase()
                                color: pill.index === 0 ? card.onTone : Theme.paper
                                font.family: UI.display
                                font.pixelSize: 8
                                font.weight: Font.Black
                                font.letterSpacing: 0.5
                            }

                            MouseArea {
                                id: pillArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: card.invoke(pill.modelData.id)
                            }
                        }
                    }
                }
            }

            // ── countdown: segments drop one by one (paused on hover) ──
            Row {
                x: 8
                width: parent.width - 16
                height: card.timeout > 0 ? 10 : 0
                visible: card.timeout > 0
                spacing: 3

                Repeater {
                    model: card.segments

                    Rectangle {
                        required property int index
                        readonly property bool lit: index < card.remaining

                        y: 2
                        width: (parent.width - (card.segments - 1) * 3) / card.segments
                        height: 4
                        color: lit ? card.tone : Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.12)
                        scale: lit ? 1 : 0.6
                        Behavior on color { CAnim {} }
                        Behavior on scale { Anim { kind: "fast" } }
                    }
                }
            }
        }
    }
}
