import QtQuick

ColorAnimation {
    duration: UI.effects.duration
    easing.type: Easing.BezierSpline
    easing.bezierCurve: UI.effects.curve
}