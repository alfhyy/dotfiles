import QtQuick

SequentialAnimation {
    id: pop

    property Item item
    property real peak: 1.25

    Anim { target: pop.item; property: "scale"; to: pop.peak; kind: "effects" }
    Anim { target: pop.item; property: "scale"; to: 1; kind: "fast" }
}