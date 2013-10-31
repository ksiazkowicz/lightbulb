import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Page {
    id: messagesPage
    tools: toolBar
    /************************************************************/
    property string resourceJid: ""

    Component.onCompleted: {
        xmppClient.openChat( xmppClient.chatJid )

        statusBarText.text = xmppClient.getNameByJid(xmppClient.chatJid)

        if( xmppClient.bareJidLastMsg == xmppClient.chatJid ) {
            messagesPage.resourceJid = xmppClient.resourceLastMsg
        }

        if( messagesPage.resourceJid == "" ) {
            listModelResources.append( {resource:qsTr("(by default)"), checked:true} )
        } else {
            listModelResources.append( {resource:qsTr("(by default)"), checked:false} )
        }

        var listResources = xmppClient.getResourcesByJid(xmppClient.chatJid)
        for( var z=0; z<listResources.length; z++ )
        {
            if( listResources[z] == "" ) { continue; }
            if( messagesPage.resourceJid ==listResources[z] ) {
                listModelResources.append( {resource:listResources[z], checked:true} )
            } else {
                listModelResources.append( {resource:listResources[z], checked:false} )
            }
        }
        main.isChatInProgress = true
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
            Rectangle {
                id: bubbleCenter
                anchors { fill: parent; rightMargin: 5; leftMargin: 5; topMargin: 5; bottomMargin: 5 }
                color: "transparent"
            }
            Text {
                  id: message
                  anchors { top: bubbleCenter.top; left: bubbleCenter.left; right: bubbleCenter.right }
                  text: "<font color='#009FEB'>" + ( isMine == true ? qsTr("Me") : (xmppClient.contactName === "" ? xmppClient.chatJid : xmppClient.contactName) ) + ":</font> " + msgText
                  color: "white"
                  font.pixelSize: 16
                  wrapMode: Text.Wrap
                  onLinkActivated: { main.url=link; linkContextMenu.open()}
            }
            Text {
                  id: time
                  anchors { top: message.bottom; right: bubbleCenter.right }
                  text: dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? dateTime.substr(9,5) : dateTime
                  font.pixelSize: 16
                  color: "#999999"
            }

            width: listViewMessages.width - 10

            states: State {
                name: "Current"
                when: (wrapper.ListView.isCurrentItem )
            }
        }
    } //Component
    /**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**/
    function sendMessage() {
        var ret = xmppClient.sendMyMessage( xmppClient.chatJid, messagesPage.resourceJid, txtMessage.text )
        if( ret ) {
              flSendMsg = true
              timerTextTyping.stop()
              txtMessage.text = ""
              flTyping = false
              flSendMsg = false
              main.notifySndVibr("MsgSent")
        }
    }
    /* --------------------( resources )-------------------- */
    ListModel {
        id: listModelResources
    }
    /*--------------------( typing notifications )--------------------*/
    property bool flTyping: false
    property bool flSendMsg: false
    Timer {
        id: timerTextTyping
        interval: 3000
        repeat: true
        onTriggered: {
            if( flTyping == false ) {
                timerTextTyping.stop()
                xmppClient.typingStop( xmppClient.chatJid, messagesPage.resourceJid )
            }
            flTyping = false
        }
    }


    /* ------------( XMPP client and stuff )------------ */
    Connections {
        target: xmppClient
        onMessageReceived: {
            if( xmppClient.bareJidLastMsg == xmppClient.chatJid ) {
                messagesPage.resourceJid = xmppClient.resourceLastMsg
                if (settings.gBool("behavior","enableHsWidget")) {
                    notify.postHSWidget()
                }
            }
        }
    }
    /* --------------------( Messages view )-------------------- */

    Timer {
        running: true
        interval: 30
        onTriggered: {
            flickable.contentY = flickable.contentHeight-flickable.height;
        }
    }

    Flickable {
        id: flickable
        boundsBehavior: Flickable.DragAndOvershootBounds

        anchors { top: parent.top; bottom: txtMessage.top; left: parent.left; right: parent.right }

        contentHeight: showAllMessagesBtn.height+10+listViewMessages.contentHeight+2


        Button {
            id: showAllMessagesBtn
            text: "Next page"
            anchors { top: parent.top; topMargin: height>0 ? 5 : 0; left: parent.left; right: parent.right }
            height: xmppClient.messagesCount > xmppClient.getPage*20 ? 40 : 0
            onClicked: {
                xmppClient.gotoPage(xmppClient.getPage+1)
            }

        }

        ListView {
            id: listViewMessages
            interactive: false
            anchors { top: showAllMessagesBtn.bottom; topMargin: 5; bottom: goToPreviousPageBtn.top; bottomMargin: goToPreviousPageBtn.height>0 ? 5 : 0; left: parent.left; right: parent.right }
            clip: true
            model: xmppClient.messagesByPage
            delegate: componentWrapperItem
            spacing: 5
            onHeightChanged: {
                if (parent.contentHeight > parent.height) {
                    parent.contentY = parent.contentHeight-parent.height;
                }
            }
        }

        Button {
            id: goToPreviousPageBtn
            text: "Previous page"
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: xmppClient.getPage > 1 ? 40 : 0
            onClicked: {
                xmppClient.gotoPage(xmppClient.getPage-1)
            }

        }

        Component.onCompleted: {
            contentY = contentHeight-height;
        }

        onHeightChanged: {
            if (contentHeight > height) {
                contentY = contentHeight-height;
            }
        }
    }
   /********************************( Toolbar )************************************/
    ToolBarLayout {
        id: toolBar

        /****/
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.replace("qrc:/qml/MessagesPage.qml")
                xmppClient.gotoPage(1)
            }
        }
        ToolButton {
            iconSource: "images/bar_open_chats.png"
            onClicked: {
                pageStack.replace( "qrc:/qml/ChatsPage.qml" )
                main.isChatInProgress = false
                statusBarText.text = "Chats"
                xmppClient.resetUnreadMessages( xmppClient.chatJid ) //cleans unread count for this JID
                xmppClient.hideChat()
                xmppClient.chatJid = ""
                xmppClient.gotoPage(1)
            }
            Image {
                id: imgMarkUnread
                source: "images/message_mark.png"
                visible: globalUnreadCount != 0
                anchors.centerIn: parent
            }
            Text {
                id: txtUnreadMsg
                text: globalUnreadCount
                font.pixelSize: 16
                anchors.centerIn: parent
                visible: globalUnreadCount != 0
                z: 1
                color: "black"
            }
        }
    }}
