import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: mainPage
    property string pageName: "Events"

    Connections {
        target: xmppConnectivity
        /*onPersonalityChanged: {
            vCardHandler.loadVCard(settings.gStr("behavior","personality"))
            avatar.source = xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))
        }*/
    }

    XmppVCard {
        id: vCardHandler
        Component.onCompleted: loadVCard(settings.gStr("behavior","personality"))
        onVCardChanged: if (fullname !== "") name.text = fullname
    }

    Flickable {
        anchors { fill: parent; margins: platformStyle.paddingSmall; bottomMargin: 0; topMargin: 0 }
        contentWidth: width
        contentHeight: mainView.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Column {
            id: mainView
            anchors { left: parent.left; right: parent.right }
            spacing: 5

            Item { height: 5; width: 1}

            Item {
                id: account
                anchors { left: parent.left; right: parent.right }
                height: 64 + (accounts.height-48) + platformStyle.paddingSmall*2

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
                        source: main.platformInverted ? "qrc:/avatar-mask_inverse" : "qrc:/avatar-mask"
                    }
                }

                Column {
                    anchors { left: avatar.right; leftMargin: platformStyle.paddingMedium; top: parent.top; right: accountsSettings.left; rightMargin: platformStyle.paddingMedium}
                    Text {
                        id: name
                        text: qsTr("Me")
                        width: parent.width
                        color: main.textColor
                        font.pixelSize: 24
                    }
                    Grid {
                        id: accounts
                        width: parent.width
                        spacing: platformStyle.paddingSmall

                        Repeater { delegate: AccountDelegate {} model: settings.accounts }

                        // retarded fix for UI being misaligned when there are no accounts
                        Rectangle {
                            width: settings.accounts.count() > 0 ? 0 : 1;
                            color: "transparent";
                            height: settings.accounts.count() > 0 ? 0 : platformStyle.graphicSizeMedium
                        }
                    }
                }

                ToolButton {
                    id: accountsSettings
                    anchors { right: parent.right; verticalCenter: account.verticalCenter }
                    width: 50
                    height: 50
                    iconSource: "toolbar-menu"
                    platformInverted: main.platformInverted
                    onClicked: main.pageStack.push( "qrc:/pages/Accounts" )
                }

            }

            Rectangle {
                height: 1
                anchors { left: parent.left; right: parent.right }
                color:  main.platformInverted ? "black" : "white"
                opacity: 0.15
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                height: 50
                Text {
                    height: parent.height
                    width: parent.width - clearBtn.width
                    color: main.textColor
                    text: qsTr("Events")
                    font { pixelSize: 22; bold: true }
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                    id: clearBtn
                    height: parent.height
                    text: "Clear"
                    onClicked: { avkon.stopNotification(); xmppConnectivity.events.clearList() }
                    platformInverted: main.platformInverted
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
                Text {
                    color: main.textColor
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
                color:  main.platformInverted ? "black" : "white"
                opacity: 0.15
            }

            Row {
                anchors { left: parent.left; right: parent.right }
                height: 50
                Text {
                    height: parent.height
                    width: parent.width - chatBtn.width
                    color: main.textColor
                    text: qsTr("Chats")
                    font { pixelSize: 22; bold: true }
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                    id: chatBtn
                    height: parent.height
                    width: height
                    text: ""
                    iconSource: "toolbar-add"
                    platformInverted: main.platformInverted
                    onClicked: main.pageStack.push( "qrc:/pages/Roster" )
                }
            }
            Repeater {
                model: xmppConnectivity.chats
                delegate: ChatDelegate { width: mainView.width }
            }

            move: Transition {
                NumberAnimation {
                    properties: "y"
                    easing.type: Easing.OutBounce
                }
            }


        }
    }

    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: avkon.minimize();
            onPlatformPressAndHold: {
                avkon.hideChatIcon()
                Qt.quit();
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
            onClicked: dialog.create("qrc:/menus/Roster/Options")
        }
    }

}
