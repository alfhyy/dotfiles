import QtQuick

QtObject {
    property int shift: 0
    property double last: 0

    readonly property date view: new Date(Sys.now.getFullYear(), Sys.now.getMonth() + shift, 1)
    readonly property int lead: (view.getDay() + 6) % 7
    readonly property int days: new Date(view.getFullYear(), view.getMonth() + 1, 0).getDate()
    readonly property int today: shift === 0 ? Sys.now.getDate() : 0

    function wheel(dy) {
        var now = Date.now()
        if (now - last < 150) return
        last = now
        shift += dy > 0 ? -1 : 1
    }

    function reset() {
        shift = 0
    }
}
