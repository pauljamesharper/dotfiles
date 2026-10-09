import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

// State lives in a detached kde-inhibit process, so every instance (one per bar) agrees.
PlasmoidItem {
    id: root
    readonly property string marker: "sleep 2147483646"
    readonly property string inhibitCmd: "kde-inhibit --power --screenSaver " + marker
    property bool active: false

    preferredRepresentation: fullRepresentation
    toolTipMainText: "Caffeine"
    toolTipSubText: active ? "On: screen stays awake" : "Off"

    P5Support.DataSource {
        id: exec
        engine: "executable"
        onNewData: (source, data) => {
            if (source.startsWith("pgrep")) root.active = data["exit code"] === 0
            disconnectSource(source)
            if (!source.startsWith("pgrep")) root.poll()
        }
    }

    function poll() { exec.connectSource("pgrep -f '^" + inhibitCmd + "$' #" + Date.now()) }
    function toggle() {
        exec.connectSource(active ? "pkill -f '^" + inhibitCmd + "$'"
                                  : "setsid -f " + inhibitCmd + " >/dev/null 2>&1")
    }

    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.poll() }

    fullRepresentation: MouseArea {
        Layout.fillHeight: true
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        onClicked: root.toggle()
        Kirigami.Icon {
            anchors.fill: parent
            source: Qt.resolvedUrl("../icons/" + (root.active ? "cup-full.svg" : "cup-empty.svg"))
            isMask: true
            color: parent.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
        }
        hoverEnabled: true
    }
}
