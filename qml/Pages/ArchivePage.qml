import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1
import "qrc:/JavaScript/EmoticonInterpreter.js" as Emotion

Page {
    id: messagesPage
    tools: toolBar

    Component.onCompleted: {
        xmppConnectivity.client.openChat( xmppConnectivity.client.chatJid )

        statusBarText.text = xmppConnectivity.client.contactName
        vars.isChatInProgress = true
    }
    /**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**/
    Component {
        id: componentWrapperItem

        Rectangle {
            id: wrapper
            color: "transparent"
            clip: true

            height: time.height + message.height + 10

            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                  id: message
                  anchors { top: parent.top; left: parent.left; right: parent.right }
                  text: "<font color='#009FEB'>" + ( isMine == true ? qsTr("Me") : (xmppConnectivity.client.contactName === "" ? xmppConnectivity.client.chatJid : xmppConnectivity.client.contactName) ) + ":</font> " + Emotion.parseEmoticons(msgText)
                  color: vars.textColor
                  font.pixelSize: 16
                  wrapMode: Text.Wrap
                  onLinkActivated: { vars.url=link; linkContextMenu.open()}
            }
            Text {
                  id: time
                  anchors { top: message.bottom; right: parent.right }
                  text: dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? dateTime.substr(9,5) : dateTime
                  font.pixelSize: 16
                  color: "#999999"
            }

            width: listViewMessages.width - 10
        }
    } //Component

    /* ------------( XMPP client and stuff )------------ */
    Connections {
        target: xmppConnectivity.client
        onMessageReceived: {
            if( xmppConnectivity.client.bareJidLastMsg == xmppConnectivity.client.chatJid ) {
                messagesPage.resourceJid = xmppConnectivity.client.resourceLastMsg
                notify.updateNotifiers()
            }
        }
    }
    /* --------------------( Messages view )-------------------- */

    Timer {
        running: true
        interval: 30
        onTriggered:  flickable.contentY = flickable.contentHeight-flickable.height;
    }

    Flickable {
        id: flickable
        boundsBehavior: Flickable.DragAndOvershootBounds

        anchors { fill: parent }

        contentHeight: listViewMessages.contentHeight+10

        ListView {
            id: listViewMessages
            interactive: false
            anchors { top: parent.top; topMargin: 5; bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right }
            clip: true
            model: xmppConnectivity.client.messagesByPage
            delegate: componentWrapperItem
            spacing: 2
        }

        Component.onCompleted: contentY = contentHeight-height;
    }
   /********************************( Toolbar )************************************/
    ToolBarLayout {
        id: toolBar

        /****/
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                pageStack.replace("qrc:/pages/Messages")
                xmppConnectivity.client.page = 1
            }
        }

        ButtonRow {
            ToolButton {
                iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
                enabled: xmppConnectivity.client.messagesCount - (xmppConnectivity.client.page*20)> 0
                opacity: enabled ? 1 : 0.2
                onClicked: xmppConnectivity.client.page++;
            }
            ToolButton {
                iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
                enabled: xmppConnectivity.client.page > 1
                opacity: enabled ? 1 : 0.2
                onClicked: {
                    xmppConnectivity.client.page--;
                    flickable.contentY = flickable.contentHeight-flickable.height;
                }
             }
        }

        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            onClicked: {
                xmppConnectivity.client.resetUnreadMessages( xmppConnectivity.client.chatJid ) //cleans unread count for this JID
                dialog.create("qrc:/dialogs/Chats")
            }
            Image {
                id: imgMarkUnread
                source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                smooth: true
                sourceSize.width: parent.width
                sourceSize.height: parent.width
                width: parent.width
                height: parent.width
                visible: vars.globalUnreadCount != 0
                anchors.centerIn: parent
            }
            Text {
                id: txtUnreadMsg
                text: vars.globalUnreadCount
                font.pixelSize: 16
                anchors.centerIn: parent
                visible: vars.globalUnreadCount != 0
                z: 1
                color: main.platformInverted ? "white" : "black"
            }
        }
    }}
