import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: root

    property alias text: itemText.text
    property alias icon: accountIcon.source
    property bool enableRemove: true

    signal editButtonClick
    signal removeButtonClick

    anchors.verticalCenter: parent.verticalCenter
    anchors.fill: parent.paddingItem

    Image {
        id: accountIcon

        anchors {
            left: parent.Left
            verticalCenter: parent.verticalCenter
        }

        sourceSize { width: platformStyle.graphicSizeMedium; height: platformStyle.graphicSizeMedium }
    }

    ListItemText {
        id: itemText
        horizontalAlignment: Text.AlignLeft

        anchors {
            left: accountIcon.right
            leftMargin: platformStyle.paddingMedium
            right: groupButtons.left
            rightMargin: platformStyle.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        elide: Text.ElideRight
        platformInverted: main.platformInverted
        role: "Title"
    }

    ButtonRow {
        id: groupButtons
        exclusive: false

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        ToolButton {
            id: editButton
            platformInverted: main.platformInverted
            iconSource: platformInverted ? "qrc:/toolbar/edit_inverse" : "qrc:/toolbar/edit"
            onClicked: editButtonClick()
        }

        ToolButton {
            id: removeButton
            platformInverted: main.platformInverted
            iconSource: "toolbar-delete"
            onClicked: removeButtonClick()
        }
    }
}
