import QtQuick
import Quickshell
import qs.Core
import qs.Themes.Zzz.Kit

DrawerWindow {
    id: drawer

    default property Component content

    // Built once and kept mapped: creating the surface + content on every open stalled the first
    // frames of the slide. Closed = fully transparent with an empty input region (click-through).
    anchors { left: true; top: true }
    margins.left: 5 + Style.railW + Style.depth + 4
    margins.top: Math.max(5, Math.min((screen ? screen.height : 768) - implicitHeight - 5, at.y - implicitHeight / 2))
    implicitWidth: body.width + Style.depth + 8
    implicitHeight: body.height + Style.depth + 8
    hit: body

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
