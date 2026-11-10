pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property var families: Qt.fontFamilies()

    readonly property string body: "JetBrainsMono Nerd Font"
    readonly property string system: families.indexOf("Departure Mono") >= 0 ? "Departure Mono" : body
    readonly property string display: families.indexOf("Archivo Expanded") >= 0 ? "Archivo Expanded" : body
    readonly property string kana: "Noto Sans CJK JP"
    readonly property int px: 11

    readonly property int gap: 6
    readonly property int barH: 30
    readonly property int rule: 6

    readonly property var spatial: ({ duration: 360, curve: [0.05, 0.7, 0.1, 1, 1, 1] })
    readonly property var fast: ({ duration: 220, curve: [0.05, 0.7, 0.1, 1, 1, 1] })
    readonly property var effects: ({ duration: 150, curve: [0.2, 0, 0, 1, 1, 1] })
}
