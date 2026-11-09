import QtQuick

ShaderEffect {
    property color ink: "white"
    property real pitch: 4
    property real rmax: 1.5
    readonly property size px: Qt.size(width, height)

    fragmentShader: Qt.resolvedUrl("shaders/halftone.frag.qsb")
}
