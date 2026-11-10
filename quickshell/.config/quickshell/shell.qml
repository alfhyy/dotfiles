//@ pragma NativeTextRendering
//@ pragma Env QML_IMPORT_PATH=/home/hapis/.local/lib/qt6/qml

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Services

ShellRoot {
    readonly property list<QtObject> services: [Sys, Notifs, Theme, SystemTray]

    Loader {
        source: Quickshell.shellPath("Themes/" + Theme.name.charAt(0).toUpperCase() + Theme.name.slice(1) + "/Shell.qml")
    }
}
