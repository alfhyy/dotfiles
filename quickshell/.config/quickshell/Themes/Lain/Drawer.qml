import QtQuick
import Quickshell
import qs.Core
import qs.Themes.Lain.Kit

DrawerWindow {
    id: drawer

    default property Component content

    anchors { left: true; bottom: true }
    margins.bottom: Style.barH + Style.gap * 2
    margins.left: Math.max(Style.gap, Math.min((screen ? screen.width : 1366) - implicitWidth - Style.gap, at.x - implicitWidth))
    implicitWidth: body.width + 2
    implicitHeight: body.height + 8
    hit: body

    Loader {
        id: body

        property real t: drawer.t
        property bool shown: drawer.shown

        y: 8
        sourceComponent: drawer.content
    }
}
