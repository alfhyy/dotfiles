import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Core
import qs.Services

Scope {
    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => Hyprland.focusedMonitor && s.name === Hyprland.focusedMonitor.name) ?? null
        anchors { top: true; right: true }
        margins { top: 5; right: 5 }
        // side room for the spring overshoot and hover pull-out
        implicitWidth: list.width + 30
        // list height stays fixed; the window and click mask follow the real card extent
        // (ListView.contentHeight goes stale when a card grows after creation, e.g. wrapped body text)
        readonly property real stackH: Math.min(list.contentItem.childrenRect.height, list.height)
        implicitHeight: Math.max(1, stackH + 16)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"
        color: "transparent"
        // always mapped (toggling visibility broke its binding and left cards unbuilt); the mask makes empty space click-through
        mask: Region { item: hit }

        Item {
            id: hit
            x: list.x
            y: list.y
            width: list.width
            height: win.stackH
        }

        ListView {
            id: list

            x: 24
            y: 4
            width: 340
            height: (win.screen ? win.screen.height : 768) - 40
            spacing: 10
            interactive: false
            // newest on top; ScriptModel diffs the array so existing cards keep their delegates
            model: ScriptModel { values: [...Notifs.server.trackedNotifications.values].reverse() }
            delegate: NotifCard {}


            add: Transition {
                ParallelAnimation {
                    Anim { property: "x"; from: 380; to: 0 }
                    Anim { property: "opacity"; from: 0; to: 1; kind: "effects" }
                }
            }
            remove: Transition {
                ParallelAnimation {
                    Anim { property: "x"; to: 380; kind: "fast" }
                    Anim { property: "opacity"; to: 0; kind: "effects" }
                }
            }
            displaced: Transition {
                Anim { property: "y" }
            }
        }

        Liquid {
            anchors.fill: list
            source: list
            active: list.count > 0
        }
    }
}
