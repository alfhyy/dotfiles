import QtQuick
import qs.Core
import qs.Themes.Zzz.Kit
import qs.Services

Item {
    id: lane

    readonly property real span: Math.max(title.height, artist.height)

    signal toggled()

    width: Style.inner
    height: cover.height + 4 + (Sys.player ? span + 10 : 0)

    // 36px * 1.15, tilted, + 2px offset ≈ 46px: stays inside the 56px within the outline
    Pop {
        id: pop

        item: cover
        peak: 1.15
    }

    Connections {
        function onTitleChanged() {
            pop.restart();
        }

        target: Sys
    }

    Cover {
        id: cover

        x: (lane.width - width) / 2
        width: 36
        height: 36
        rotation: area.containsMouse ? 0 : -4
        opacity: Sys.playing || !Sys.player ? 1 : 0.55

        Behavior on rotation {
            Anim {
                kind: "fast"
            }

        }

        Behavior on opacity {
            Anim {
                kind: "effects"
            }

        }

    }

    Row {
        x: (lane.width - width) / 2
        y: cover.height + 14
        height: lane.span
        spacing: 4
        opacity: Sys.player ? 1 : 0

        // bottom-aligned so both lines start at the same point
        VText {
            id: title

            y: lane.span - height
            visible: text !== ""
            scroll: Sys.playing
            text: Sys.title
            color: Theme.paper
            font.family: Style.display
            font.pixelSize: 12
            font.weight: Font.Black
        }

        VText {
            id: artist

            y: lane.span - height
            visible: text !== ""
            scroll: Sys.playing
            text: Sys.artist
            color: Theme.accent
            font.family: Style.display
            font.pixelSize: 9
            font.weight: Font.Bold
        }

        Behavior on opacity {
            Anim {
                kind: "effects"
            }

        }

    }

    MediaInput {
        id: area

        anchors.fill: parent
        onOpen: lane.toggled()
    }

    Behavior on height {
        Anim {
        }

    }

}
