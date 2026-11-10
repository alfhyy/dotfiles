import QtQuick
import qs.Core
import qs.Themes.Zzz.Kit
import qs.Services

Rectangle {
    id: cover

    color: Theme.ink_raised
    antialiasing: true

    Rectangle {
        z: -1
        x: Math.max(2, Math.round(cover.width / 24))
        y: x
        width: cover.width
        height: cover.height
        color: Theme.accent
        antialiasing: true
    }

    Text {
        anchors.centerIn: parent
        visible: art.status !== Image.Ready
        text: "\uf001"
        color: Theme.accent_alt
        font.family: Style.icons
        font.pixelSize: cover.width * 0.3
    }

    Image {
        id: art

        anchors.fill: parent
        anchors.margins: 1
        source: Sys.cover
        // decoded at display size: downscaling a large photo on the GPU is what made it jagged
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        border.color: Theme.stroke
        antialiasing: true
    }

}
