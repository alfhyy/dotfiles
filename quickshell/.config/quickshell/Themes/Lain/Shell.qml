import QtQuick
import Quickshell
import qs.Core
import qs.Services
import qs.Themes.Lain.Kit
import "Bar"

Scope {
    Binding { target: UI; property: "spatial"; value: Style.spatial }
    Binding { target: UI; property: "fast"; value: Style.fast }
    Binding { target: UI; property: "effects"; value: Style.effects }
    Binding { target: Theme; property: "tintDark"; value: 0 }
    Binding { target: Theme; property: "tintLight"; value: 0 }

    Bar {}
    Notifications {}
    Drawer { name: "calendar"; Calendar {} }
    Drawer { name: "music"; Music {} }
}
