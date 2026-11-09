import QtQuick
import qs.Services

Item {
    id: field

    property string legend
    property bool lit: false
    property bool hot: false
    property bool divider: true
    default property alias content: body.data
    readonly property bool marked: lit || hot

    height: Style.barH

    Rectangle {
        visible: field.divider
        y: Style.rule
        width: 1
        height: field.height - Style.rule
        color: Theme.line
    }

    Rectangle {
        visible: field.legend !== ""
        x: 7
        y: Style.rule - height / 2
        width: tag.implicitWidth + 6
        height: tag.implicitHeight
        color: field.marked ? Theme.paper : Theme.ink

        Text {
            id: tag
            x: 3
            text: field.legend
            color: field.marked ? Theme.ink : Theme.paper_dim
            font.family: Style.system
            font.pixelSize: Style.px
        }
    }

    Item {
        id: body
        x: 10
        y: Style.rule + 1
        width: field.width - 20
        height: field.height - Style.rule - 2
    }
}
