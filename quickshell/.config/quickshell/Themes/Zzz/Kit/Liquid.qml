import QtQuick
import qs.Services

// Theme-change transition for one window. Place it as a sibling over `source`:
// Theme.capture -> snapshot the old look; Theme.swapped (colours already switched, once) ->
// the snapshot drains away behind a liquid front. Cost: one texture grab + one quad per frame.
Item {
    id: fx

    required property Item source
    // skip hidden content (closed drawers, empty notification stack)
    property bool active: true

    property real progress: 1
    property real seed: 0
    property bool armed: false

    ShaderEffectSource {
        id: snap
        sourceItem: fx.source
        live: false
        hideSource: false
        visible: false
    }

    ShaderEffect {
        anchors.fill: parent
        // also while armed: an unused texture isn't rendered, so the snapshot would only be taken
        // after the swap (new colours). Armed + progress 1 draws nothing but forces the old-look grab.
        visible: fx.progress < 1 || fx.armed
        property var old: snap
        property real progress: fx.progress
        property real seed: fx.seed
        property size px: Qt.size(width, height)
        fragmentShader: Qt.resolvedUrl("shaders/liquid.frag.qsb")
    }

    NumberAnimation {
        id: pour
        target: fx
        property: "progress"
        from: 0
        to: 1
        duration: 620
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.45, 0, 0.2, 1, 1, 1]
    }

    Connections {
        target: Theme
        function onCapture() {
            if (!fx.active) return
            pour.stop()
            fx.progress = 1
            snap.scheduleUpdate()
            fx.armed = true
        }
        function onSwapped() {
            if (!fx.armed) return
            fx.armed = false
            fx.seed = Math.random() * 10
            pour.restart()
        }
    }
}
