import QtQuick

NumberAnimation {
    property string kind: "spatial"
    readonly property var spec: kind === "fast" ? UI.fast : kind === "effects" ? UI.effects : UI.spatial

    duration: spec.duration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: spec.curve
}