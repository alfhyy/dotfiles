pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property string drawer: ""
    property var drawerScreen: null
    property real drawerY: 0
    property double closedAt: 0

    property var spatial: ({ duration: 250, curve: [0.2, 0, 0, 1, 1, 1] })
    property var fast: ({ duration: 250, curve: [0.2, 0, 0, 1, 1, 1] })
    property var effects: ({ duration: 150, curve: [0.2, 0, 0, 1, 1, 1] })

    function toggle(name, screen, y) {
        if (drawer === name) {
            drawer = ""
        } else if (drawer !== "" || Date.now() - closedAt > 250) {
            drawerScreen = screen
            drawerY = y
            drawer = name
        }
    }

    function close() {
        drawer = ""
        closedAt = Date.now()
    }
}