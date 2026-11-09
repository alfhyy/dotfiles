import QtQuick
import qs.Services

Rectangle {
    id: chip

    property color tone: Theme.accent
    property color edge: Theme.stroke

    color: tone
    border.width: 2
    border.color: edge

    Behavior on tone { CAnim {} }
}