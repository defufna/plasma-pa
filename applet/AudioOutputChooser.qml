
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

Window {
    id: root

    property rect screenGeometry: Qt.rect(Screen.virtualX, Screen.virtualY, Screen.width, Screen.height)

    width: Kirigami.Units.gridUnit * 40
    height: Math.max(Kirigami.Units.gridUnit * 15, Math.min(mainLayout.implicitHeight, screenGeometry.height * 0.9))

    // Center the window on the screen
    x: screenGeometry.x + (screenGeometry.width - width) / 2
    y: screenGeometry.y + (screenGeometry.height - height) / 2

    // Make it look like a popup/dialog
    flags: Qt.Popup | Qt.FramelessWindowHint
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            // Find the current default device and select it
            for (var i = 0; i < listView.count; ++i) {
                var item = deviceModel.data(deviceModel.index(i, 0), Qt.UserRole + 1) // PulseObject role
                if (item && item.default) {
                    listView.currentIndex = i
                    break
                }
            }
            listView.forceActiveFocus()
        }
    }

    required property var deviceModel

    component Delegate : PC3.ItemDelegate {
        id: delegate
        width: ListView.view.width
        
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        topPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.smallSpacing

        readonly property var pulseObject: model.PulseObject

        // Highlight the current default device
        highlighted: pulseObject.default

        contentItem: RowLayout {
            spacing: Kirigami.Units.mediumSpacing

            PC3.Label {
                Layout.fillWidth: true
                text: pulseObject.description || pulseObject.name
                elide: Text.ElideRight
                font.weight: delegate.highlighted ? Font.Bold : Font.Normal
            }

            PC3.Label {
                visible: delegate.highlighted
                text: i18n("Default")
                color: Kirigami.Theme.highlightColor
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }

        onClicked: {
            pulseObject.default = true
            root.close()
        }
    }

    Kirigami.ShadowedRectangle {
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.backgroundColor
        
        // Add a border/shadow to make it stand out
        border.width: 1
        border.color: Kirigami.Theme.separatorColor

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: 0

            PlasmaExtras.Heading {
                id: header
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.largeSpacing
                level: 3
                text: i18n("Select Audio Output")
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.separatorColor
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 5
                implicitHeight: contentHeight
                clip: true
                
                model: root.deviceModel
                delegate: Delegate {}

                highlight: PlasmaExtras.Highlight {}
                highlightMoveDuration: Kirigami.Units.shortDuration

                Keys.onReturnPressed: {
                    if (currentItem) {
                        currentItem.pulseObject.default = true
                        root.close()
                    }
                }
                Keys.onEnterPressed: Keys.onReturnPressed(event)
                Keys.onEscapePressed: root.close()

                // ScrollBar
                PC3.ScrollBar.vertical: PC3.ScrollBar {}
            }
        }
    }
}
