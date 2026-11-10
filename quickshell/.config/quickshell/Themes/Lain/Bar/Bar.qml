import QtQuick
import Quickshell
import qs.Core
import qs.Services
import qs.Themes.Lain.Kit

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData

        function at(item) {
            var p = item.mapToItem(null, item.width, 0)
            return Qt.point(p.x + win.margins.left, p.y)
        }

        screen: modelData
        anchors {
            left: true
            right: true
            bottom: true
        }
        margins.left: Style.gap
        margins.right: Style.gap
        margins.bottom: Style.gap
        implicitHeight: Style.barH
        exclusiveZone: Style.barH
        color: "transparent"

        Rectangle {
            y: Style.rule
            width: parent.width
            height: parent.height - Style.rule
            color: Theme.ink
            border.width: 1
            border.color: Theme.line
        }

        Row {
            id: row
            width: parent.width
            height: parent.height

            readonly property real fixed: navi.width + layer.width + net.width + audio.width + bat.width + day.width + time.width + exit.width

            Field {
                id: navi
                width: 152
                legend: "NAVI"
                divider: false
                lit: UI.drawer === "profile"
                hot: naviArea.containsMouse

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        width: Math.min(implicitWidth, navi.width - 32)
                        elide: Text.ElideRight
                        text: (Quickshell.env("USER") || "lain") + "@navi"
                        color: Theme.paper
                        font.family: Style.system
                        font.pixelSize: Style.px
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 11
                        color: Theme.danger
                    }
                }

                MouseArea {
                    id: naviArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UI.toggle("profile", win.modelData, win.at(navi))
                }
            }

            Field {
                id: layer
                width: 196
                legend: "LAYER"
                hot: layerInput.containsMouse

                Repeater {
                    model: 5

                    Item {
                        id: cell

                        required property int index
                        readonly property bool active: Sys.ws === index + 1

                        x: index * 35
                        width: 35
                        height: parent.height

                        onActiveChanged: if (active) jolt.fire()

                        Rectangle {
                            anchors.centerIn: parent
                            width: 26
                            height: 15
                            color: cell.active ? Theme.accent : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            width: 26
                            horizontalAlignment: Text.AlignHCenter
                            text: "0" + (cell.index + 1)
                            color: cell.active ? Theme.on_accent : Sys.busy[cell.index + 1] ? Theme.paper : Theme.line
                            font.family: Style.system
                            font.pixelSize: Style.px
                            transform: Translate { id: shift }
                        }

                        Glitch { id: jolt; target: shift }
                    }
                }

                WorkspaceInput {
                    id: layerInput
                    anchors.fill: parent
                    vertical: false
                    cell: 35
                    hoverEnabled: true
                }
            }

            Field {
                id: sig
                width: row.width - row.fixed
                legend: "SIG"
                lit: UI.drawer === "music"
                hot: media.containsMouse

                Connections {
                    target: Sys
                    function onTitleChanged() { flicker.fire() }
                }

                Item {
                    id: sigBody
                    anchors.fill: parent

                    Text {
                        id: mark
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        text: Sys.playing ? ">>" : Sys.player ? "||" : "--"
                        color: Theme.paper_dim
                        font.family: Style.system
                        font.pixelSize: Style.px
                    }

                    Leader {
                        anchors.verticalCenter: parent.verticalCenter
                        x: mark.width
                        width: parent.width - mark.width
                        lead: Sys.player ? (Sys.title || "UNTITLED") : "NO SIGNAL"
                        tail: Sys.player ? Sys.artist : ""
                        tone: Sys.player ? Theme.paper : Theme.paper_dim
                    }
                }

                Glitch { id: flicker; target: sigBody; property: "opacity"; on: 0.25; off: 1 }

                MediaInput {
                    id: media
                    anchors.fill: parent
                    onOpen: UI.toggle("music", win.modelData, win.at(sig))
                }
            }

            Field {
                id: net
                width: 104
                legend: "NET"
                hot: netArea.containsMouse

                readonly property bool alert: !Sys.netUp
                onAlertChanged: if (alert) netJolt.fire()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    elide: Text.ElideRight
                    text: Sys.net === "wifi" ? "WIFI" : Sys.net === "ethernet" ? "WIRED" : "NO CARRIER"
                    color: net.alert ? Theme.danger : Theme.paper
                    font.family: Style.system
                    font.pixelSize: Style.px
                    transform: Translate { id: netShift }
                }

                Glitch { id: netJolt; target: netShift }

                MouseArea {
                    id: netArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Sys.run("nm-connection-editor")
                }
            }

            Field {
                id: audio
                width: 152
                legend: "AUDIO"
                hot: audioArea.containsMouse

                readonly property bool alert: Sys.muted
                readonly property int lit: Math.round(Math.min(1, Sys.vol) * 10)
                onAlertChanged: if (alert) audioJolt.fire()

                Row {
                    visible: !audio.alert
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index
                                width: 3
                                height: 10
                                color: index < audio.lit ? Theme.accent : Theme.line
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30
                        text: Math.round(Sys.vol * 100)
                        color: Theme.paper
                        font.family: Style.system
                        font.pixelSize: Style.px
                    }
                }

                Text {
                    visible: audio.alert
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    elide: Text.ElideRight
                    text: "MUTE"
                    color: Theme.danger
                    font.family: Style.system
                    font.pixelSize: Style.px
                    transform: Translate { id: audioShift }
                }

                Glitch { id: audioJolt; target: audioShift }

                MouseArea {
                    id: audioArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Sys.toggleMute()
                    onWheel: wheel => Sys.wheelVolume(wheel.angleDelta.y)
                }
            }

            Field {
                id: bat
                width: 112
                legend: "BAT"
                lit: UI.drawer === "battery"
                hot: batArea.containsMouse

                onAlertChanged: if (alert) batJolt.fire()
                readonly property bool alert: Sys.batLow

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    elide: Text.ElideRight
                    text: Math.round(Sys.batLevel * 100) + "%" + (Sys.charging ? " AC" : bat.alert ? " LOW" : "")
                    color: bat.alert ? Theme.danger : Theme.paper
                    font.family: Style.system
                    font.pixelSize: Style.px
                    transform: Translate { id: batShift }
                }

                Glitch { id: batJolt; target: batShift }

                MouseArea {
                    id: batArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UI.toggle("battery", win.modelData, win.at(bat))
                }
            }

            Field {
                id: day
                width: 104
                legend: "PRESENT DAY"
                lit: UI.drawer === "calendar"
                hot: dayArea.containsMouse

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    elide: Text.ElideRight
                    text: Qt.formatDateTime(Sys.now, "ddd dd.MM").toUpperCase()
                    color: Theme.paper
                    font.family: Style.system
                    font.pixelSize: Style.px
                }

                MouseArea {
                    id: dayArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UI.toggle("calendar", win.modelData, win.at(time))
                }
            }

            Field {
                id: time
                width: 96
                legend: "PRESENT TIME"
                hot: timeArea.containsMouse

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    elide: Text.ElideRight
                    text: Sys.hours + ":" + Sys.minutes
                    color: Theme.paper
                    font.family: Style.system
                    font.pixelSize: Style.px
                }

                MouseArea {
                    id: timeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UI.toggle("calendar", win.modelData, win.at(time))
                }
            }

            Field {
                id: exit
                width: 40
                hot: exitArea.containsMouse

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: exit.hot ? Theme.paper : Theme.paper_dim
                    font.family: Style.system
                    font.pixelSize: Style.px
                }

                MouseArea {
                    id: exitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Sys.run("wlogout")
                }
            }
        }
    }
}
