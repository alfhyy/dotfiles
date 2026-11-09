import QtQuick
import Quickshell
import qs.Core
import qs.Themes.Zzz.Kit
import qs.Services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData

        screen: modelData
        margins.left: 5
        margins.top: 5
        margins.bottom: 5
        implicitWidth: Style.railW + Style.depth
        exclusiveZone: Style.railW + Style.depth
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
        }

        Item {
            id: railBox

            anchors.fill: parent

            Plate {
                width: Style.railW
                height: parent.height - Style.depth
                fill: Theme.ink
                tone: Theme.accent
                // radius:
                edge: Theme.stroke
                edgeWidth: 2

                Halftone {
                    anchors.fill: parent
                    ink: Qt.rgba(Theme.paper.r, Theme.paper.g, Theme.paper.b, 0.16)
                }

                Rectangle {
                    x: -20
                    y: parent.height - 150
                    width: 110
                    height: 22
                    antialiasing: true
                    rotation: -38
                    color: Theme.ink_raised
                }

                // profile: opens the Proxy ID card
                Item {
                    id: avatar

                    x: (Style.railW - width) / 2
                    y: Style.edge + Style.pad
                    width: 32
                    height: 32
                    rotation: avatarArea.containsMouse ? 0 : -4
                    scale: avatarArea.pressed ? 0.9 : 1
                    Behavior on rotation { Anim { kind: "fast" } }
                    Behavior on scale { Anim { kind: "fast" } }

                    Rectangle {
                        x: 2
                        y: 2
                        width: parent.width
                        height: parent.height
                        color: UI.drawer === "profile" ? Theme.accent_alt : Theme.accent
                        antialiasing: true
                        Behavior on color { CAnim {} }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.ink_raised
                        border.width: 2
                        border.color: Theme.stroke
                        antialiasing: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: "file://" + Quickshell.env("HOME") + "/.face"
                            // decoded at display size: downscaling a large photo on the GPU is what made it jagged
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            antialiasing: true
                        }
                    }

                    MouseArea {
                        id: avatarArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: UI.toggle("profile", win.modelData, avatar.mapToItem(null, 0, avatar.height / 2).y + win.margins.top)
                    }
                }

                Workspaces {
                    id: ws

                    y: 56
                }

                Lane {
                    id: lane

                    anchors.horizontalCenter: parent.horizontalCenter
                    y: ws.y + ws.height + (bottomGroup.y - ws.y - ws.height - height) / 2
                    onToggled: UI.toggle("music", win.modelData, lane.mapToItem(null, 0, lane.height / 2).y + win.margins.top)
                }

                Column {
                    id: bottomGroup

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.edge + Style.pad
                    width: parent.width
                    spacing: 0

                    Orb {
                        glyph: ({
                            "wifi": "\uf1eb",
                            "ethernet": "\uf0e8"
                        })[Sys.net] || "\uf071"
                        dim: !Sys.netUp
                        onClicked: Sys.run("nm-connection-editor")
                    }

                    Orb {
                        id: vol

                        glyph: Sys.muted || Sys.vol < 0.01 ? "\uf026" : Sys.vol < 0.5 ? "\uf027" : "\uf028"
                        level: Sys.vol
                        dim: Sys.muted
                        onClicked: Sys.toggleMute()
                        onWheeled: (delta) => {
                            return Sys.nudgeVolume(delta / 120 * 0.05);
                        }
                    }

                    Orb {
                        id: batOrb

                        glyph: Sys.batGlyph
                        level: Sys.batLevel
                        alert: Sys.batLow
                        onClicked: UI.toggle("battery", win.modelData, batOrb.mapToItem(null, 0, batOrb.height / 2).y + win.margins.top)
                    }

                    Item {
                        id: clock

                        width: parent.width
                        height: 60

                        Pop {
                            id: tick

                            item: mm
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            scale: clockArea.pressed ? 0.94 : clockArea.containsMouse ? 1.06 : 1

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Sys.hours
                                color: Theme.paper
                                font.family: Style.display
                                font.pixelSize: 18
                                font.weight: Font.Black
                            }

                            Text {
                                id: mm

                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Sys.minutes
                                color: Theme.accent
                                font.family: Style.display
                                font.pixelSize: 18
                                font.weight: Font.Black
                            }

                            Behavior on scale {
                                Anim {
                                    kind: "fast"
                                }

                            }

                        }

                        MouseArea {
                            id: clockArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: UI.toggle("calendar", win.modelData, clock.mapToItem(null, 0, clock.height / 2).y + win.margins.top)
                        }

                    }

                    // power, below the clock
                    Item {
                        width: parent.width
                        height: 40

                        Item {
                            anchors.centerIn: parent
                            width: 28
                            height: 28

                            Item {
                                anchors.fill: parent
                                rotation: power.containsMouse ? 45 : 0

                                Repeater {
                                    model: 2

                                    Rectangle {
                                        required property int index

                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        rotation: index * 45
                                        color: Theme.accent_alt
                                        antialiasing: true
                                    }
                                }

                                Behavior on rotation { Anim { kind: "fast" } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "\uf011"
                                color: Theme.ink
                                font.family: Style.icons
                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: power

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Sys.run("wlogout")
                            }
                        }
                    }
                }

            }
        }

        Liquid {
            anchors.fill: railBox
            source: railBox
        }

        Connections {
            function onVolChanged() {
                vol.ping();
            }

            function onMinutesChanged() {
                tick.restart();
            }

            target: Sys
        }

    }

}
