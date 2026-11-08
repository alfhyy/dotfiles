import QtQuick

Canvas {
    id: dots

    property color ink: "white"
    property real pitch: 4
    property real rmax: 1.5

    onInkChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        ctx.fillStyle = ink
        ctx.beginPath()
        for (var row = 0; row * pitch < height; row++) {
            var y = row * pitch
            var r = rmax * Math.pow(1 - y / height, 1.4)
            if (r < 0.25) continue
            for (var x = (row % 2) * pitch / 2; x < width; x += pitch) {
                ctx.moveTo(x + r, y)
                ctx.arc(x, y, r, 0, 6.2832)
            }
        }
        ctx.fill()
    }
}