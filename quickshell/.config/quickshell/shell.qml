//@ pragma NativeTextRendering
//@ pragma Env QML_IMPORT_PATH=/home/hapis/.local/lib/qt6/qml

import Quickshell
import "Strip"
import "Notif"

ShellRoot {
    Strip {}
    Notifications {}
    Drawer { name: "calendar"; Calendar {} }
    Drawer { name: "music"; Music {} }
    Drawer { name: "profile"; Profile {} }
    Drawer { name: "battery"; Battery {} }
}