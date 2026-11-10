import QtQuick
import QtQuick.Shapes
import qs.Services

Shape {
    id: outline

    property string text
    property font font
    property color stroke: Theme.paper


    width: tm.advanceWidth + 2
    height: fm.ascent + fm.descent + 2
    preferredRendererType: Shape.CurveRenderer

    TextMetrics { id: tm; font: outline.font; text: outline.text }
    FontMetrics { id: fm; font: outline.font }

    ShapePath {
        fillColor: "transparent"
        strokeColor: outline.stroke
        strokeWidth: 1
        PathText { x: 1; y: 1; font: outline.font; text: outline.text }
    }
}
