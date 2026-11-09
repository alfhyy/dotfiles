import QtQuick
import qs.Core
import qs.Services

Item {
    id: wave

    // "dots" (dot matrix) | "bars" | "line"
    property string style: "dots"
    property var values: []
    readonly property int count: values.length
    property color tone: Sys.playing ? Theme.accent : Sys.player ? Theme.paper_dim : Theme.accent_alt
    readonly property color dim: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.1)
    readonly property real slot: width / Math.max(1, count)
    readonly property real rowH: height / 7
    readonly property real dot: Math.max(2, Math.min(slot, rowH) - 2)

    Behavior on tone { CAnim {} }

    // dot matrix as plain rectangles: a column only changes when its lit run (0..3 dots each side
    // of the middle) steps, so most spectrum frames touch nothing. Was a Canvas repainting
    // ~200 arcs in JS + a texture upload per frame.
    Repeater {
        model: wave.style === "dots" ? wave.count : 0

        Item {
            id: col
            required property int index
            readonly property int k: Math.round(wave.values[index] * 3)

            x: index * wave.slot
            width: wave.slot
            height: wave.height

            Repeater {
                model: 7

                Rectangle {
                    required property int index
                    x: (wave.slot - width) / 2
                    y: index * wave.rowH + (wave.rowH - height) / 2
                    width: wave.dot
                    height: wave.dot
                    radius: wave.dot / 2
                    color: Math.abs(index - 3) <= col.k ? wave.tone : wave.dim
                }
            }
        }
    }

    Repeater {
        model: wave.style === "bars" ? wave.count : 0

        Rectangle {
            required property int index

            x: index * wave.slot
            y: (wave.height - height) / 2
            width: Math.max(1, wave.slot - 2)
            height: Math.max(2, wave.values[index] * wave.height)
            color: wave.tone
        }
    }

    Loader {
        anchors.fill: parent
        active: wave.style === "line"

        sourceComponent: Canvas {
            onPaint: {
                var ctx = getContext("2d")
                var n = wave.count, slot = wave.slot, mid = height / 2
                ctx.clearRect(0, 0, width, height)
                if (n === 0) return
                var top = [], bottom = []
                for (var i = 0; i < n; i++) {
                    top.push({ x: i * slot + slot / 2, y: mid - wave.values[i] * mid })
                    bottom.push({ x: i * slot + slot / 2, y: mid + wave.values[i] * mid })
                }
                bottom.reverse()
                var curve = function (a) {
                    for (var k = 0; k < a.length - 1; k++)
                        ctx.quadraticCurveTo(a[k].x, a[k].y, (a[k].x + a[k + 1].x) / 2, (a[k].y + a[k + 1].y) / 2)
                    ctx.lineTo(a[a.length - 1].x, a[a.length - 1].y)
                }
                ctx.beginPath()
                ctx.moveTo(top[0].x, top[0].y)
                curve(top)
                ctx.lineTo(bottom[0].x, bottom[0].y)
                curve(bottom)
                ctx.closePath()
                ctx.globalAlpha = 0.35
                ctx.fillStyle = wave.tone
                ctx.fill()
                ctx.globalAlpha = 1
                ctx.lineWidth = 1.5
                ctx.strokeStyle = wave.tone
                ctx.stroke()
            }

            Connections {
                target: wave
                function onValuesChanged() { requestPaint() }
                function onToneChanged() { requestPaint() }
            }
        }
    }
}
