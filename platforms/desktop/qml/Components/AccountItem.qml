import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Universal 2.0
import QtQuick.Layouts 1.1
import "."

Item {
    id: root
    property alias text: itemText.text
    property alias icon: accountIcon.source
    property bool enableRemove: true

    signal editButtonClick
    signal removeButtonClick

    anchors {
        leftMargin: 15;
        rightMargin: 15;
        verticalCenter: parent.verticalCenter;
        fill: parent;
    }

    Image {
        id: accountIcon

        anchors {
            left: parent.Left
            verticalCenter: parent.verticalCenter
        }

        sourceSize { width: PlatformStyle.graphicSizeMedium; height: PlatformStyle.graphicSizeMedium }
    }

    Label {
        id: itemText
        horizontalAlignment: Text.AlignLeft

        anchors {
            left: accountIcon.right
            leftMargin: PlatformStyle.paddingMedium
            right: groupButtons.left
            rightMargin: PlatformStyle.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        elide: Text.ElideRight
        color: "white"
    }

    RowLayout {
        id: groupButtons

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        ToolButton {
            id: previewButton
            text: "\uE052"
            font.family: "Segoe MDL2 Assets"
            //onClicked: removeButtonClick()
        }

        ToolButton {
            id: editButton
            text: "\uE70F"
            font.family: "Segoe MDL2 Assets"
            onClicked: editButtonClick()
        }

        ToolButton {
            id: removeButton
            text: "\uE74D"
            font.family: "Segoe MDL2 Assets"
            onClicked: removeButtonClick()
        }
    }
}
