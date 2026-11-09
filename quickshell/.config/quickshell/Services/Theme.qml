pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core

// Palette from matugen (templates/quickshell-colors.json -> Services/colors.json).
// Changes don't animate colours (that re-evaluated every binding each frame): the file loads into a
// staging adapter, Liquid overlays snapshot the old look on `capture`, colours swap once, and the
// snapshots pour away on `swapped`.
Singleton {
    id: theme

    signal capture()
    signal swapped()

    property bool ready: false
    property string lastSig: ""

    property string name: "zzz"
    property string pending: ""
    property bool named: false

    function request(n) {
        n = n || "zzz"
        if (!named) {
            named = true
            name = n
            return
        }
        if (n === name) {
            pending = ""
            fallback.stop()
            return
        }
        pending = n
        UI.close()
        fallback.restart()
    }

    function commit() {
        fallback.stop()
        if (pending === "") return
        name = pending
        pending = ""
    }

    // matugen's surfaces are near-neutral; mix in the accent so the wallpaper shows in the main colour
    readonly property real tintDark: 0.25
    readonly property real tintLight: 0.18

    property color ink: "#0a0f12"
    property color ink_raised: "#262a2e"
    property color paper: "#e0e3e8"
    property color paper_dim: "#c1c7ce"
    property color accent: "#95cdf7"
    property color accent_alt: "#cec0e8"
    property color on_accent: "#00344e"
    property color line: "#8b9198"
    property color sheet: "#e0e3e8"
    property color sheet_ink: "#2d3135"
    property color sheet_mark: "#266489"
    property color stroke: "#000000"
    property color accent_soft: "#004c6e"
    property color on_accent_soft: "#c9e6ff"
    property color danger: "#ffb4ab"
    property color on_danger: "#690005"

    // derived: text/accents that sit on the always-black stroke strips, in either mode
    readonly property bool light: ink.hslLightness > 0.5
    readonly property color on_stroke: "#ffffff"
    readonly property color stroke_accent: light ? accent_soft : accent

    function tinted(base, extra) {
        var t = (Qt.tint(base, "transparent").hslLightness > 0.5 ? tintLight : tintDark) + (extra || 0)
        var a = Qt.tint(c.accent, "transparent")
        return Qt.tint(base, Qt.rgba(a.r, a.g, a.b, t))
    }

    function apply() {
        ink = tinted(c.ink)
        ink_raised = tinted(c.ink_raised, 0.06)
        paper = c.paper
        paper_dim = c.paper_dim
        accent = c.accent
        accent_alt = c.accent_alt
        on_accent = c.on_accent
        line = c.line
        sheet = c.sheet
        sheet_ink = c.sheet_ink
        sheet_mark = c.sheet_mark
        stroke = c.stroke
        accent_soft = c.accent_soft
        on_accent_soft = c.on_accent_soft
        danger = c.danger
        on_danger = c.on_danger
    }

    // ~3 frames for every Liquid snapshot to render with the old colours before swapping
    Timer {
        id: swap
        interval: 50
        onTriggered: { theme.apply(); theme.swapped() }
    }

    Timer {
        id: fallback
        interval: 3000
        onTriggered: theme.commit()
    }

    FileView {
        id: state
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/rice/theme"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: theme.request(text().trim())
        onLoadFailed: theme.named = true
    }

    FileView {
        id: file
        path: Quickshell.shellPath("Services/colors.json")
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            var sig = JSON.stringify(c)
            if (!theme.ready) { theme.apply(); theme.lastSig = sig; theme.ready = true; return }
            if (theme.pending !== "") {
                if (sig === theme.lastSig) return
                swap.stop()
                theme.lastSig = sig
                theme.apply()
                theme.commit()
                return
            }
            // the watcher and the IPC hook both fire per change: one transition per real change,
            // and none while a swap is pending (it applies the latest staged values anyway)
            if (sig === theme.lastSig || swap.running) return
            theme.lastSig = sig
            theme.capture()
            swap.restart()
        }

        JsonAdapter {
            id: c
            property string ink: "#0a0f12"
            property string ink_raised: "#262a2e"
            property string paper: "#e0e3e8"
            property string paper_dim: "#c1c7ce"
            property string accent: "#95cdf7"
            property string accent_alt: "#cec0e8"
            property string on_accent: "#00344e"
            property string line: "#8b9198"
            property string sheet: "#e0e3e8"
            property string sheet_ink: "#2d3135"
            property string sheet_mark: "#266489"
            property string stroke: "#000000"
            property string accent_soft: "#004c6e"
            property string on_accent_soft: "#c9e6ff"
            property string danger: "#ffb4ab"
            property string on_danger: "#690005"
        }
    }

    // matugen's post_hook calls `qs ipc call theme reload` (file watches miss its atomic replace)
    IpcHandler {
        target: "theme"
        function reload(): void {
            state.reload()
            file.reload()
        }
    }
}
