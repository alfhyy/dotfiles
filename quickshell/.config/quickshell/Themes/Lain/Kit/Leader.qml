import QtQuick
import qs.Services

Item {
    id: leader

    property string lead
    property string tail
    property color tone: Theme.paper
    property color dim: Theme.paper_dim

    implicitHeight: l.implicitHeight

    Text {
        id: l
        width: Math.max(0, Math.min(implicitWidth, leader.width - r.width - 48))
        elide: Text.ElideRight
        text: leader.lead
        color: leader.tone
        font.family: Style.system
        font.pixelSize: Style.px
    }

    Text {
        id: r
        anchors.right: parent.right
        width: Math.min(implicitWidth, leader.width * 0.4)
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        text: leader.tail
        color: leader.dim
        font.family: Style.system
        font.pixelSize: Style.px
    }

    Text {
        x: l.width + 6
        width: Math.max(0, r.x - x - 6)
        clip: true
        text: ".".repeat(160)
        color: Theme.line
        font.family: Style.system
        font.pixelSize: Style.px
    }
}
