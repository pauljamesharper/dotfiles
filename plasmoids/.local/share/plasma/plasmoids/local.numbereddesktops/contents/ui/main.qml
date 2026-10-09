import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation

    TaskManager.VirtualDesktopInfo { id: vdi }

    // VirtualDesktopInfo.requestActivate isn't callable from QML, so ask KWin
    // over D-Bus (desktops are numbered from 1 there).
    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        onNewData: (source) => disconnectSource(source)
    }
    function activate(index) {
        exec.connectSource("qdbus-qt6 org.kde.KWin /KWin setCurrentDesktop " + (index + 1))
    }

    fullRepresentation: RowLayout {
        spacing: 2
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.fillHeight: true

        Repeater {
            model: vdi.desktopIds
            delegate: Rectangle {
                readonly property bool current: modelData === vdi.currentDesktop
                Layout.fillHeight: true
                Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 1.6)
                radius: Kirigami.Units.cornerRadius
                color: current ? Kirigami.Theme.highlightColor
                     : mouse.containsMouse ? Qt.alpha(Kirigami.Theme.highlightColor, 0.3) : "transparent"

                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.25)
                    text: vdi.desktopNames[index] || (index + 1)
                    font.bold: parent.current
                    color: parent.current ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.activate(index)
                }
            }
        }
    }
}
