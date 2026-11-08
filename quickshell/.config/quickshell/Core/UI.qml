pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property string drawer: ""
    property var drawerScreen: null
    property real drawerY: 0
    property double closedAt: 0

    readonly property int railW: 60
    // rail box model: outline | padding | content (3D layers sit outside, in UI.depth)
    readonly property int edge: 2
    readonly property int pad: 6
    readonly property int inner: railW - 2 * (edge + pad)
    readonly property int depth: 4

    readonly property var spatial: ({ duration: 500, curve: [0.38, 1.21, 0.22, 1, 1, 1] })
    readonly property var fast: ({ duration: 350, curve: [0.42, 1.67, 0.21, 0.9, 1, 1] })
    readonly property var effects: ({ duration: 200, curve: [0.34, 0.8, 0.34, 1, 1, 1] })

    readonly property string icons: "JetBrainsMono Nerd Font"
    readonly property string body: "Rubik"
    readonly property string display: {
        var have = Qt.fontFamilies()
        var want = ["Unbounded", "Syne", "Krona One", "Archivo Black", "Rubik Mono One"]
        for (var i = 0; i < want.length; i++)
            if (have.indexOf(want[i]) >= 0) return want[i]
        return icons
    }

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