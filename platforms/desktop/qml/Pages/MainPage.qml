import QtQuick 2.0
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

    Connections {
        target: xmppConnectivity
        onPersonalityChanged: {
            vCardHandler.loadVCard(settings.gStr("behavior","personality"))
            avatar.source = xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))
        }
    }

    XmppVCard {
        id: vCardHandler
        Component.onCompleted: loadVCard(settings.gStr("behavior","personality"))
        onVCardChanged: if (fullname !== "") name.text = fullname
    }

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

            Item { height: 5; width: 1}

            Item {
                id: account
                anchors { left: parent.left; right: parent.right }
                height: 64 + (accounts.height-48) + PlatformStyle.paddingSmall*2

                Image {
                    id: avatar
                    clip: true
                    width: 64; height: 64
                    smooth: true
                    source: xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))

                    Rectangle { anchors.fill: parent; color: "black"; z: -1 }

                    Image {
                        anchors.fill: parent
                        smooth: true
                        sourceSize { width: 64; height: 64 }
                        source: "qrc:/avatar-mask"
                    }
                }

                ColumnLayout {
                    anchors { left: avatar.right; leftMargin: PlatformStyle.paddingMedium; top: parent.top; right: accountsSettings.left; rightMargin: PlatformStyle.paddingMedium}
                    Label {
                        id: name
                        text: qsTr("Me")
                        width: parent.width
                        font.pixelSize: 24
                    }
                    Grid {
                        id: accounts
                        width: parent.width
                        spacing: PlatformStyle.paddingSmall

                        Repeater { delegate: AccountDelegate {} model: settings.accounts }

                        // retarded fix for UI being misaligned when there are no accounts
                        Rectangle {
                            width: settings.accounts.count() > 0 ? 0 : 1;
                            color: "transparent";
                            height: settings.accounts.count() > 0 ? 0 : PlatformStyle.graphicSizeMedium
                        }
                    }
                }

                ToolButton {
                    id: accountsSettings
                    anchors { right: parent.right; verticalCenter: account.verticalCenter }
                    width: 50
                    height: 50
                    text: "\uE713"
                    font.family: "Segoe MDL2 Assets"
                    onClicked: stack.push( "qrc:/Pages/AccountPage" )
                }
            }

            Rectangle {
                height: 1
                anchors { left: parent.left; right: parent.right }
                color: "white"
                opacity: 0.15
            }

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
            Item {
                height: eventsList.model.count > 0 ? 0 : 64
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
                model: xmppConnectivity.chats
                delegate: ChatDelegate { width: mainView.width }
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
