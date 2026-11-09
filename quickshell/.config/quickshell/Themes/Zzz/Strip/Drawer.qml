import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Core
import qs.Themes.Zzz.Kit

Scope {
    id: drawer

    default property Component content
    property string name
    property real anchorY: 0
    property var anchorScreen: Quickshell.screens[0]

    readonly property bool shown: UI.drawer === name
    property real t: shown ? 1 : 0
    Behavior on t { Anim {} }

    Binding { target: drawer; property: "anchorY"; value: UI.drawerY; when: drawer.shown; restoreMode: Binding.RestoreNone }
    Binding { target: drawer; property: "anchorScreen"; value: UI.drawerScreen; when: drawer.shown; restoreMode: Binding.RestoreNone }

    // Built once and kept mapped: creating the surface + content on every open stalled the first
    // frames of the slide. Closed = fully transparent with an empty input region (click-through).
    PanelWindow {
        id: win

        screen: drawer.anchorScreen
        anchors { left: true; top: true }
        margins.left: 5 + Style.railW + Style.depth + 4
        margins.top: Math.max(5, Math.min((win.screen ? win.screen.height : 768) - implicitHeight - 5, drawer.anchorY - implicitHeight / 2))
        implicitWidth: body.width + Style.depth + 8
        implicitHeight: body.height + Style.depth + 8
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: drawer.t > 0.002 ? open : closed

        Region { id: open; item: body }
        Region { id: closed }

        HyprlandFocusGrab {
            windows: [win]
            active: drawer.shown
            onCleared: UI.close()
        }

        Item {
            id: stage
            anchors.fill: parent

            Loader {
                id: body
                // whole pixels: fractional slide positions made the native-rendered text shimmer
                x: Math.round(-40 * (1 - drawer.t))
                y: 4
                opacity: Math.min(1, drawer.t * 1.5)
                sourceComponent: drawer.content
            }
        }

        Liquid {
            anchors.fill: stage
            source: stage
            active: drawer.t > 0.002
        }
    }
}
