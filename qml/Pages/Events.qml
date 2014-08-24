import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: mainPage
    property string pageName: "Events"
    orientationLock: 1

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
        onVCardChanged: {
            if (fullname !== "")
                name.text = fullname
        }
    }

    Flickable {
        anchors { fill: parent; leftMargin: 5; rightMargin: 5 }
        contentWidth: width
        contentHeight: mainView.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Column {
            id: mainView
            anchors { left: parent.left; right: parent.right }
            spacing: 5

            move: Transition {
                     NumberAnimation {
                         properties: "y"
                         easing.type: Easing.OutBounce
                     }
                 }

            Item { height: 5; width: 1}

            Item {
                id: account
                anchors { left: parent.left; right: parent.right }
                height: 64 + (accounts.height-48)

                Image {
                    id: avatar
                    width: 64
                    height: 64
                    clip: true
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

                Text {
                    id: name
                    width: 215
                    height: 31
                    text: qsTr("Me")
                    anchors { left: avatar.right; leftMargin: 24; top: parent.top}
                    color: main.textColor
                    font.pixelSize: 24
                }

                ToolButton {
                    anchors { right: parent.right; verticalCenter: account.verticalCenter }
                    width: 50
                    height: 50
                    iconSource: "toolbar-menu"
                    platformInverted: main.platformInverted
                    onClicked: main.pageStack.push( "qrc:/pages/Accounts" )
                }

                GridView {
                    id: accounts
                    interactive: false
                    anchors { right: name.right; left: name.left; top: name.bottom }
                    cellWidth: 48
                    cellHeight: 48
                    height: contentHeight
                    delegate: MouseArea {
                        height: 32
                        width: 48
                        onClicked: {
                            dialog.createWithProperties("qrc:/dialogs/Status/Change", {"accountId": accGRID})
                        }

                        Connections {
                            target: xmppConnectivity
                            onXmppStatusChanged: {
                                if (accountId == accGRID)
                                    accPresence.source = "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
                            }
                        }

                        Image {
                            sourceSize { height: 32; width: 32 }
                            anchors.centerIn: parent
                            smooth: true
                            source: "qrc:/accounts/" + accIcon
                            Image {
                                id: accPresence
                                width: 12; height: width
                                anchors { right: parent.right; bottom: parent.bottom }
                                source: "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
                                smooth: true
                                sourceSize { width: 12; height: 12 }
                            }
                        }
                    }
                    model: settings.accounts
                }

            }

            LineItem {}
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
                    onClicked: xmppConnectivity.events.clearList();
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

            LineItem {}
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
