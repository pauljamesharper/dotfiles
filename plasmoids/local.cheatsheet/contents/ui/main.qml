import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    preferredRepresentation: compactRepresentation
    readonly property real scale: 1.4

    // The global shortcut activates the applet; show our own centered window instead of a panel popup.
    Connections {
        target: Plasmoid
        function onActivated() { sheet.visible = !sheet.visible }
    }

    readonly property var sections: [
        { title: "Apps", keys: [
            ["Super+Space", "Launcher (KRunner)"],
            ["Super+Enter", "Terminal"],
            ["Super+Shift+Enter", "Terminal with tmux"],
            ["Super+B", "Brave"],
            ["Super+F", "Files (Dolphin)"],
            ["Super+/", "This cheat sheet"] ] },
        { title: "Workspaces", keys: [
            ["Super+1…9, 0", "Go to workspace 1–10"],
            ["Super+Shift+1…9, 0", "Move window to workspace"],
            ["Super+W", "Overview"] ] },
        { title: "Monitors", keys: [
            ["Super+O", "Focus other monitor"],
            ["Super+Shift+O", "Move window to other monitor"] ] },
        { title: "Windows", keys: [
            ["Super+Q", "Close window"],
            ["Super+H/J/K/L", "Focus left/down/up/right"],
            ["Super+Shift+H/J/K/L", "Move window"],
            ["Super+Ctrl+H/J/K/L", "Resize window"],
            ["Super+. / Super+,", "Focus next / previous"],
            ["Super+PgUp", "Maximize"],
            ["Super+D", "Show desktop"],
            ["Alt+Tab", "Switch windows"] ] },
        { title: "Tiling (Krohnkite)", keys: [
            ["Super+M", "Monocle layout"],
            ["Super+\\", "Next layout"],
            ["Super+|", "Previous layout"],
            ["Super+R", "Rotate layout"],
            ["Super+I", "More master windows"],
            ["Super+Shift+F", "Float all windows"] ] },
        { title: "System", keys: [
            ["Super+Escape", "Lock screen"],
            ["Super+X", "Power / log out menu"] ] }
    ]

    compactRepresentation: MouseArea {
        Layout.minimumWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.fillHeight: true
        onClicked: sheet.visible = !sheet.visible
        Kirigami.Icon {
            anchors.fill: parent
            source: "input-keyboard-symbolic"
        }
    }

    PlasmaCore.Dialog {
        id: sheet
        location: PlasmaCore.Types.Floating
        flags: Qt.WindowStaysOnTopHint
        hideOnWindowDeactivate: true
        backgroundHints: PlasmaCore.Types.StandardBackground

        onVisibleChanged: if (visible) { reposition(); content.forceActiveFocus() }
        onWidthChanged: reposition()
        onHeightChanged: reposition()
        function reposition() {
            const g = Plasmoid.containment.screenGeometry
            x = g.x + Math.round((g.width - width) / 2)
            y = g.y + Math.round((g.height - height) / 2)
        }

        mainItem: FocusScope {
            id: content
            implicitWidth: grid.implicitWidth + Kirigami.Units.gridUnit * 4
            implicitHeight: grid.implicitHeight + Kirigami.Units.gridUnit * 4
            Keys.onEscapePressed: sheet.visible = false

            GridLayout {
                id: grid
                anchors.centerIn: parent
                columns: 3
                columnSpacing: Kirigami.Units.gridUnit * 3
                rowSpacing: Kirigami.Units.gridUnit * 1.5

                Repeater {
                    model: root.sections
                    delegate: ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        spacing: Kirigami.Units.smallSpacing * 1.5
                        Kirigami.Heading {
                            level: 2
                            text: modelData.title
                            Layout.bottomMargin: Kirigami.Units.smallSpacing
                        }
                        Repeater {
                            model: modelData.keys
                            delegate: RowLayout {
                                spacing: Kirigami.Units.largeSpacing * 2
                                PlasmaComponents.Label {
                                    Layout.preferredWidth: Kirigami.Units.gridUnit * 9 * root.scale
                                    text: modelData[0]
                                    font.family: "monospace"
                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * root.scale
                                    color: Kirigami.Theme.highlightColor
                                }
                                PlasmaComponents.Label {
                                    text: modelData[1]
                                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * root.scale
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
