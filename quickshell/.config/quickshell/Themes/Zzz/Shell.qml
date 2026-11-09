import QtQuick
import Quickshell
import qs.Core
import qs.Themes.Zzz.Kit
import "Strip"
import "Notif"

Scope {
    Binding { target: UI; property: "spatial"; value: Style.spatial }
    Binding { target: UI; property: "fast"; value: Style.fast }
    Binding { target: UI; property: "effects"; value: Style.effects }

    Strip {}
    Notifications {}
    Drawer { name: "calendar"; Calendar {} }
    Drawer { name: "music"; Music {} }
    Drawer { name: "profile"; Profile {} }
    Drawer { name: "battery"; Battery {} }
}
