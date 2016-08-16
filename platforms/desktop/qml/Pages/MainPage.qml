import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls.Universal 2.0
import lightbulb 1.0
import "../Components"


Page {
    id: mainPage
    property alias stack: mainPage.parent
    property color textColor: "white"
    property color midColor: "gray"

    Flickable {
        anchors { fill: parent; margins: PlatformStyle.paddingSmall; bottomMargin: 0; topMargin: 0 }
        contentWidth: width
        contentHeight: mainView.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        clip: true
        ColumnLayout {
            id: mainView
            anchors { left: parent.left; right: parent.right }
            spacing: 5

            Row {
                anchors { left: parent.left; right: parent.right }
                height: 50
                Label {
                    height: parent.height
                    width: parent.width - clearBtn.width
                    text: qsTr("Events")
                    font { pixelSize: 22; bold: true }
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                    id: clearBtn
                    height: parent.height
                    text: "Dismiss"
                    onClicked: { xmppConnectivity.events.clearList() }
                }
            }
            Repeater {
                id: eventsList
                model: xmppConnectivity.events.list
                anchors { left: parent.left; right: parent.right }
                delegate: EventDelegate { width: mainView.width }
            }
            Rectangle {
                id: eventLabel
                height: 64
                visible: eventsList.model.count <= 0
                color: "transparent"
                clip: true
                anchors { left: parent.left; right: parent.right }
                Label {
                    text: "No unread events ^^"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 21
                    opacity: 0.5
                    visible: parent.height > 0
                }
            }

            Rectangle {
                height: 1
                anchors { left: parent.left; right: parent.right }
                color:  "white"
                opacity: 0.15
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                height: 50
                Label {
                    height: parent.height
                    width: parent.width - chatBtn.width
                    text: qsTr("Chats")
                    font { pixelSize: 22; bold: true }
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                    id: chatBtn
                    height: parent.height
                    width: height
                    text: "\uE710"
                    font.family: "Segoe MDL2 Assets"
                    onClicked: stack.push( "qrc:/Pages/RosterPage" )
                }
            }
            Repeater {
                id: chatsList
                model: xmppConnectivity.chats
                delegate: ChatDelegate { width: mainView.width }
            }

            Rectangle {
                id: chatsLabel
                height: 64
                visible: chatsList.model.count <= 0
                color: "transparent"
                clip: true
                anchors { left: parent.left; right: parent.right }
                Label {
                    text: "No unread chats ^^"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 21
                    opacity: 0.5
                    visible: parent.height > 0
                }
            }

            /*move: Transition {
                NumberAnimation {
                    properties: "y"
                    easing.type: Easing.OutBounce
                }
            }*/


        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            Item { Layout.fillWidth: true }
            ToolButton {
                id: menuButton
                text: "\uE712"
                font.family: "Segoe MDL2 Assets"
                onClicked: mainMenu.open()

                Menu {
                    y: -mainMenu.height
                    id: mainMenu
                    MenuItem {
                        text: qsTr("Join a MUC")
                        onClicked: dialog.createWithContext("qrc:/Dialogs/MUC/Join")
                    }
                    MenuItem {
                        text: qsTr("Browse services")
                        onClicked: dialog.createWithContext("qrc:/Dialogs/Services/Ask")
                    }
                    MenuItem {
                        text: qsTr("Preferences")
                        onClicked: stack.push( "qrc:/Pages/Preferences" )
                    }
                    MenuItem {
                        text: qsTr("XML Console")
                        onClicked: stack.push( "qrc:/Pages/XMLConsole" )
                    }
                    MenuItem {
                        text: qsTr("About...")
                        onClicked: stack.push( "qrc:/Pages/AboutPage" )
                    }
                    MenuItem {
                        text: qsTr("Exit")
                        onClicked: Qt.quit()
                    }
                }
            }
        }
    }

}
