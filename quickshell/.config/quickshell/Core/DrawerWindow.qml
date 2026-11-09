import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: win

    property string name
    property point at: Qt.point(0, 0)
    property Item hit
    readonly property bool shown: UI.drawer === name
    property real t: shown ? 1 : 0
    Behavior on t { Anim {} }

    Binding { target: win; property: "at"; value: UI.drawerAt; when: win.shown; restoreMode: Binding.RestoreNone }
    Binding { target: win; property: "screen"; value: UI.drawerScreen; when: win.shown; restoreMode: Binding.RestoreNone }

    screen: Quickshell.screens[0]
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: t > 0.002 ? open : closed

    Region { id: open; item: win.hit }
    Region { id: closed }

    HyprlandFocusGrab {
        windows: [win]
        active: win.shown
        onCleared: UI.close()
    }
}
