import QtQuick
import qs.Core
import qs.Themes.Zzz.Kit
import qs.Services

Item {
    id: ws

    readonly property int cell: 30
    readonly property int count: 5
    readonly property int idx: Sys.ws - 1

    width: Style.railW
    height: count * cell

    // gel travel: the edge facing the target springs ahead, the other one catches up,
    // so the pill stretches toward the new workspace and snaps back to size
    onIdxChanged: {
        var t = idx * cell + 4
        var up = t < pill.lo
        loAnim.kind = up ? "fast" : "spatial"
        hiAnim.kind = up ? "spatial" : "fast"
        pill.lo = t
        pill.hi = t + cell - 8
    }

    Gel {
        id: pill

        property real lo: ws.idx * ws.cell + 4
        property real hi: (ws.idx + 1) * ws.cell - 4
        Behavior on lo { Anim { id: loAnim } }
        Behavior on hi { Anim { id: hiAnim } }

        x: Style.edge + Style.pad
        y: lo
        width: Style.inner
        height: Math.max(8, hi - lo)
        radius: width / 2
        opacity: ws.idx >= 0 && ws.idx < ws.count ? 1 : 0
        Behavior on opacity { Anim { kind: "effects" } }
    }

    Repeater {
        model: ws.count

        Text {
            required property int index

            y: index * ws.cell
            width: ws.width
            height: ws.cell
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "0" + (index + 1)
            color: ws.idx === index ? Theme.on_accent : Sys.busy[index + 1] ? Theme.accent : Theme.paper_dim
            font.family: Style.display
            font.pixelSize: 10
            font.weight: Font.Black
            font.letterSpacing: 1
            Behavior on color { CAnim {} }
        }
    }

    WorkspaceInput {
        anchors.fill: parent
        count: ws.count
        cell: ws.cell
    }
}
