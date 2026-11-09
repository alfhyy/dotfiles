import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Core
import qs.Services
import qs.Themes.Lain.Kit

Scope {
    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => Hyprland.focusedMonitor && s.name === Hyprland.focusedMonitor.name) ?? null
        anchors { top: true; right: true }
        margins { top: Style.gap; right: Style.gap }
        implicitWidth: list.width
        readonly property real stackH: Math.min(list.contentItem.childrenRect.height, list.height)
        implicitHeight: Math.max(1, stackH + 16)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"
        color: "transparent"
        mask: Region { item: hit }

        Item {
            id: hit
            y: list.y
            width: list.width
            height: win.stackH
        }

        ListView {
            id: list

            y: 8
            width: 320
            height: (win.screen ? win.screen.height : 768) - 60
            spacing: 14
            interactive: false
            model: ScriptModel { values: [...Notifs.server.trackedNotifications.values].reverse() }

            delegate: Frame {
                id: card

                required property Notification modelData
                readonly property Notification n: modelData
                readonly property bool critical: n ? n.urgency === NotificationUrgency.Critical : false
                readonly property int timeout: !n || critical ? 0 : n.expireTimeout > 0 ? n.expireTimeout : n.urgency === NotificationUrgency.Low ? 4000 : 6500

                width: 320
                height: col.height + 24
                crosshairs: false
                legend: n ? (n.appName || "NAVI").toUpperCase() : ""
                aside: critical ? "ALERT" : ""
                asideTone: Theme.danger

                Component.onCompleted: if (critical) jolt.fire()

                Glitch { id: jolt; target: card; property: "x"; on: 2; off: 0 }

                Timer {
                    interval: card.timeout
                    running: card.timeout > 0 && !area.containsMouse
                    onTriggered: if (card.n) card.n.expire()
                }

                Column {
                    id: col
                    x: 12
                    y: 14
                    width: parent.width - 24
                    spacing: 4

                    Text {
                        width: parent.width
                        visible: text !== ""
                        elide: Text.ElideRight
                        text: card.n ? card.n.summary : ""
                        color: Theme.paper
                        font.family: Style.body
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        textFormat: Text.StyledText
                        text: card.n ? card.n.body : ""
                        color: Theme.paper_dim
                        linkColor: Theme.paper
                        font.family: Style.body
                        font.pixelSize: Style.px
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (!card.n) return
                        if (mouse.button === Qt.RightButton) {
                            card.n.dismiss()
                            return
                        }
                        var a = Array.from(card.n.actions).find(x => x.identifier === "default")
                        if (a) a.invoke()
                        else card.n.dismiss()
                    }
                }
            }

            add: Transition {
                Anim { property: "opacity"; from: 0; to: 1; kind: "effects" }
            }
            remove: Transition {
                Anim { property: "opacity"; to: 0; kind: "effects" }
            }
            displaced: Transition {
                Anim { property: "y" }
            }
        }
    }
}
