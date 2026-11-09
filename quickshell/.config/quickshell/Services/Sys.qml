pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs.Core

Singleton {
    readonly property int ws: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0

    readonly property var busy: {
        var set = {}
        var list = Hyprland.toplevels.values
        for (var i = 0; i < list.length; i++) {
            if (list[i].workspace) set[list[i].workspace.id] = true
        }
        return set
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real vol: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    readonly property var bat: UPower.displayDevice
    readonly property real batLevel: bat ? (bat.percentage > 1 ? bat.percentage / 100 : bat.percentage) : 0
    readonly property bool charging: bat ? bat.state === UPowerDeviceState.Charging : false
    readonly property bool batLow: bat !== null && bat.isLaptopBattery && !charging && batLevel <= 0.20
    readonly property string batGlyph: batLow ? "\udb80\udc83" // nf-md-battery_alert
        : charging ? "\uf0e7"
        : batLevel > 0.85 ? "\uf240" : batLevel > 0.6 ? "\uf241" : batLevel > 0.35 ? "\uf242" : "\uf243"

    // warn once per discharge; re-arm after charging or climbing back above 22% (no repeats around 20%)
    property bool batWarned: false
    function checkBattery() {
        if (batLow && !batWarned) {
            batWarned = true
            Quickshell.execDetached(["notify-send", "-a", "Battery", "-u", "critical", "-i", "battery-caution",
                "Battery low — " + Math.round(batLevel * 100) + "%", "Plug in your charger soon."])
        } else if (charging || batLevel > 0.22) {
            batWarned = false
        }
    }
    onBatLevelChanged: checkBattery()
    onChargingChanged: checkBattery()
    Component.onCompleted: checkBattery()

    property string net: "none"
    property string scan: "none"
    readonly property bool netUp: net !== "none"

    readonly property var player: {
        var list = Mpris.players.values
        for (var i = 0; i < list.length; i++)
            if (list[i].isPlaying) return list[i]
        return list.length > 0 ? list[0] : null
    }
    readonly property string cover: player ? player.trackArtUrl : ""
    readonly property real length: player ? player.length : 0
    readonly property bool playing: player !== null && player.isPlaying
    readonly property string title: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""

    property var spectrum: new Array(28).fill(0.06)
    readonly property bool wantSpectrum: playing && UI.drawer === "music"

    readonly property date now: clock.date
    readonly property string hours: Qt.formatDateTime(now, "HH")
    readonly property string minutes: Qt.formatDateTime(now, "mm")

    function goto(n) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + n + " })")
    }

    function moveTo(n) {
        Hyprland.dispatch("hl.dsp.window.move({ workspace = " + n + " })")
    }

    function step(dir) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = '" + (dir > 0 ? "e+1" : "e-1") + "' })")
    }

    function run(cmd) {
        Hyprland.dispatch("hl.dsp.exec_cmd('" + cmd + "')")
    }

    function nudgeVolume(delta) {
        if (sink && sink.audio)
            sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta))
    }

    function wheelVolume(delta) {
        nudgeVolume(delta / 120 * 0.05)
    }

    function toggleMute() {
        if (sink && sink.audio)
            sink.audio.muted = !sink.audio.muted
    }

    function togglePlay() {
        if (player && player.canTogglePlaying)
            player.togglePlaying()
    }

    function skip(dir) {
        if (!player) return
        if (dir > 0 && player.canGoNext) player.next()
        else if (dir < 0 && player.canGoPrevious) player.previous()
    }

    function fmt(s) {
        var m = Math.floor(s / 60)
        var r = Math.floor(s % 60)
        return m + ":" + (r < 10 ? "0" : "") + r
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    PwObjectTracker { objects: [sink] }

    // in-process libcava: keeps its calibration between sessions, so it only runs while the drawer shows it
    Loader {
        id: cava
        source: "CavaNative.qml"
    }

    Binding { target: cava.item; property: "active"; value: wantSpectrum; when: cava.item !== null }

    Connections {
        target: cava.item
        function onValuesChanged() { spectrum = cava.item.values }
    }

    // fallback when the plugin isn't built: cava process, kept warm while playing to avoid its ~2s startup/calibration
    Process {
        running: cava.status === Loader.Error && playing
        command: ["cava", "-p", Quickshell.shellPath("scripts/cava.conf")]
        stdout: SplitParser {
            onRead: data => {
                if (!wantSpectrum) return
                spectrum = data.split(";").slice(0, 28).map(v => Math.min(1, v / 100))
            }
        }
    }

    // nmcli monitor prints a burst of lines per change (a reconnect is ~10-20): swallow the burst
    // (lines < 0.3s apart) and query once instead of spawning nmcli per line
    Process {
        running: true
        command: ["sh", "-c", "p() { nmcli -t -f TYPE,STATE device; echo ==; }; p; nmcli monitor | while read -r _; do while read -r -t 0.3 _; do :; done; p; done"]
        stdout: SplitParser {
            onRead: data => {
                if (data === "==") {
                    net = scan
                    scan = "none"
                    return
                }
                var f = data.split(":")
                if (f[1] && f[1].indexOf("connected") === 0 && (f[0] === "ethernet" || (f[0] === "wifi" && scan === "none")))
                    scan = f[0]
            }
        }
    }
}