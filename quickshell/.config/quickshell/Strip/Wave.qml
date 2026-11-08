import QtQuick
import qs.Core
import qs.Services
import qs.Theme

Item {
    id: wave

    property string style: "bar"
    property var values: []
    readonly property int count: values.length
    property color tone: Sys.playing ? Theme.accent : Sys.player ? Theme.paper_dim : Theme.accent_alt

    onValuesChanged: canvas.requestPaint()
    onToneChanged: canvas.requestPaint()
    onStyleChanged: canvas.requestPaint()

    Connections {
        target: Theme
        function onPaperChanged() { canvas.requestPaint() }
    }

    Repeater {
        model: wave.style === "bars" ? wave.count : 0

        Rectangle {
            required property int index
            readonly property real slot: wave.width / wave.count

            x: index * slot
            y: (wave.height - height) / 2
            width: Math.max(1, slot - 2)
            height: Math.max(2, wave.values[index] * wave.height)
            color: wave.tone
        }

    }

    Canvas {
        id: canvas

        anchors.fill: parent
        visible: wave.style !== "bars"
        onPaint: {
            var ctx = getContext("2d");
            var n = wave.count;
            var slot = width / n;
            var mid = height / 2;
            ctx.clearRect(0, 0, width, height);
            if (wave.style === "line") {
                var top = [];
                var bottom = [];
                for (var i = 0; i < n; i++) {
                    top.push({
                        "x": i * slot + slot / 2,
                        "y": mid - wave.values[i] * mid
                    });
                    bottom.push({
                        "x": i * slot + slot / 2,
                        "y": mid + wave.values[i] * mid
                    });
                }
                bottom.reverse();
                var curve = function curve(a) {
                    for (var k = 0; k < a.length - 1; k++) ctx.quadraticCurveTo(a[k].x, a[k].y, (a[k].x + a[k + 1].x) / 2, (a[k].y + a[k + 1].y) / 2)
                    ctx.lineTo(a[a.length - 1].x, a[a.length - 1].y);
                };
                ctx.beginPath();
                ctx.moveTo(top[0].x, top[0].y);
                curve(top);
                ctx.lineTo(bottom[0].x, bottom[0].y);
                curve(bottom);
                ctx.closePath();
                ctx.globalAlpha = 0.35;
                ctx.fillStyle = wave.tone;
                ctx.fill();
                ctx.globalAlpha = 1;
                ctx.lineWidth = 1.5;
                ctx.strokeStyle = wave.tone;
                ctx.stroke();
                return ;
            }
            var rows = 7;
            var rowH = height / rows;
            var r = Math.max(1, Math.min(slot, rowH) / 2 - 1);
            var c = (rows - 1) / 2;
            ctx.fillStyle = Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.1);
            ctx.beginPath();
            for (var col = 0; col < n; col++) for (var row = 0; row < rows; row++) if (Math.abs(row - c) > Math.round(wave.values[col] * c)) {
                ctx.moveTo(col * slot + slot / 2 + r, row * rowH + rowH / 2);
                ctx.arc(col * slot + slot / 2, row * rowH + rowH / 2, r, 0, 2 * Math.PI);
            }
            ctx.fill();
            ctx.fillStyle = wave.tone;
            ctx.beginPath();
            for (var col2 = 0; col2 < n; col2++) for (var row2 = 0; row2 < rows; row2++) if (Math.abs(row2 - c) <= Math.round(wave.values[col2] * c)) {
                ctx.moveTo(col2 * slot + slot / 2 + r, row2 * rowH + rowH / 2);
                ctx.arc(col2 * slot + slot / 2, row2 * rowH + rowH / 2, r, 0, 2 * Math.PI);
            }
            ctx.fill();
        }
    }

    Behavior on tone {
        CAnim {
        }

    }

}
