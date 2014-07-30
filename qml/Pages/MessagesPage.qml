import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Page {
    id: messagesPage
    tools: toolBar
    /************************************************************/
    property bool isTyping: false
    property bool emoticonsDisabled: settings.gBool("behavior","disableEmoticons")
    property string contactName: ""
    property string pageName: contactName

    Component.onCompleted: {
        vars.resourceJid = ""
        listModelResources.clear()
        xmppConnectivity.page = 1
        console.log( xmppConnectivity.chatJid )
        xmppConnectivity.openChat( xmppConnectivity.currentAccount,xmppConnectivity.chatJid )

        if( xmppConnectivity.client.bareJidLastMsg == xmppConnectivity.chatJid ) vars.resourceJid = xmppConnectivity.client.resourceLastMsg

        if( vars.resourceJid == "" ) listModelResources.append( {resource:qsTr("(by default)"), checked:true} )
        else listModelResources.append( {resource:qsTr("(by default)"), checked:false} )

        if (notify.getStatusNameByIndex(xmppConnectivity.client.status) != "Offline") {
            var listResources = xmppConnectivity.client.getResourcesByJid(xmppConnectivity.chatJid)
            for( var z=0; z<listResources.length; z++ ) {
                if ( listResources[z] == "" ) { continue; }
                if ( vars.resourceJid ==listResources[z] ) listModelResources.append( {resource:listResources[z], checked:true} )
                else listModelResources.append( {resource:listResources[z], checked:false} )
           }
        }
    }
    // Code for destroying the page after pop
    onStatusChanged: if (messagesPage.status === PageStatus.Inactive) messagesPage.destroy()
    /**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**/
    Component {
        id: componentWrapperItem

        Item {
            id: wrapper
            height: triangleTop.height + bubbleTop.height/2 + time.height + message.height + bubbleBottom.height/2 + triangleBottom.height

            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                id: triangleTop
                anchors { top: parent.top;
                    right: parent.right;
                    rightMargin: 16
                }
                source: isMine == true ? "" : "qrc:/images/bubble_incTriangle.png"
                width: 13
                height: isMine == true ? 0 : 13
            }
            Rectangle {
                id: bubbleTop
                anchors { top: triangleTop.bottom;
                          left: parent.left;
                          right: parent.right;
                          rightMargin: isMine == true ? 64 : 6;
                          leftMargin: isMine == true ? 6 : 64
                }
                height: 20
                gradient: Gradient {
                    GradientStop { position: 0.0; color: isMine == true ? "#6f6f74" : "#f2f1f4" }
                    GradientStop { position: 0.5; color: isMine == true ? "#56565b" : "#eae9ed" }
                    GradientStop { position: 1.0; color: isMine == true ? "#56565b" : "#eae9ed" }
                }

                radius: 8
            }
            Rectangle {
                id: bubbleBottom
                anchors { bottom: triangleBottom.top;
                    left: parent.left;
                    right: parent.right;
                    rightMargin: isMine == true ? 64 : 6;
                    leftMargin: isMine == true ? 6 : 64
                }
                height: 20
                gradient: Gradient {
                    GradientStop { position: 0.0; color: isMine == true ? "#56565b" : "#e6e6eb" }
                    GradientStop { position: 0.5; color: isMine == true ? "#56565b" : "#e6e6eb" }
                    GradientStop { position: 1.0; color: isMine == true ? "#46464b" : "#b9b8bd" }
                }

                radius: 8
            }
            Rectangle {
                id: bubbleCenter
                anchors { fill: parent; rightMargin: isMine == true ? 64 : 6; leftMargin: isMine == true ? 6 : 64; topMargin: triangleTop.height+10; bottomMargin: triangleBottom.height+10 }
                color: isMine == true ? "#56565b" : "#e6e6eb"
                Text {
                      id: message
                      anchors { top: parent.top; left: parent.left; leftMargin: 5; right: parent.right; rightMargin: 5 }
                      property string messageText: msgText.replace(String.fromCharCode(10),"<br/>").replace(String.fromCharCode(11),"<br />").replace(String.fromCharCode(12),"<br />").replace(String.fromCharCode(13),"<br />")
                      text: "<font color='#009FEB'>" + ( isMine == true ? qsTr("Me") : (contactName === "" ? xmppConnectivity.chatJid : contactName) ) + ":</font> " + (emoticonsDisabled ? messageText : emoticon.parseEmoticons(messageText))
                      color: isMine == true ? "white" : "black"
                      font.pixelSize: 16
                      wrapMode: Text.Wrap
                      onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})

                      Component.onCompleted: {
                          console.log("nieeee")
                          console.log(messageText)
                          console.log("to smutne że")
                          console.log(msgText)
                      }
                }
                Text {
                      id: time
                      anchors { top: message.bottom; right: parent.right; rightMargin: 5 }
                      text: dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? dateTime.substr(9,5) : dateTime
                      font.pixelSize: 16
                      color: "#999999"
                }
            }

            Image {
                id: triangleBottom
                anchors { bottom: parent.bottom;
                    left: parent.left;
                    leftMargin: 16
                }
                source: isMine == true ? "qrc:/images/bubble_outTriangle.png" : ""
                width: 13
                height: isMine == true ? 13 : 0
            }
            width: listViewMessages.width - 10
        }
    } //Component
    /**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**/
    function sendMessage() {
        var ret = xmppConnectivity.sendAMessage( xmppConnectivity.currentAccount, xmppConnectivity.chatJid, vars.resourceJid, txtMessage.text, 1 )
        if( ret ) {
              txtMessage.text = ""
              xmppConnectivity.client.typingStop( xmppConnectivity.chatJid, vars.resourceJid )
              notify.notifySndVibr("MsgSent")
        } else {
            avkon.displayGlobalNote("Something went wrong while sending a message.",true);
        }
    }

    /* ------------( XMPP client and stuff )------------ */
    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: if( jid == xmppConnectivity.chatJid ) vars.resourceJid = xmppConnectivity.client.resourceLastMsg
        onQmlChatChanged: {
            listModelResources.clear()
            xmppConnectivity.openChat( xmppConnectivity.currentAccount,xmppConnectivity.chatJid )
            contactName = xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,"name",xmppConnectivity.chatJid)
            statusBarText.text = contactName

            txtMessage.text = xmppConnectivity.getPreservedMsg(xmppConnectivity.chatJid);

            if( xmppConnectivity.client.bareJidLastMsg == xmppConnectivity.chatJid ) vars.resourceJid = xmppConnectivity.client.resourceLastMsg

            if( vars.resourceJid == "" ) listModelResources.append( {resource:qsTr("(by default)"), checked:true} )
            else listModelResources.append( {resource:qsTr("(by default)"), checked:false} )

            if (notify.getStatusNameByIndex(xmppConnectivity.client.status) != "Offline") {
                var listResources = xmppConnectivity.client.getResourcesByJid(xmppConnectivity.chatJid)
                for( var z=0; z<listResources.length; z++ ) {
                    if ( listResources[z] == "" ) { continue; }
                    if ( vars.resourceJid ==listResources[z] ) listModelResources.append( {resource:listResources[z], checked:true} )
                    else listModelResources.append( {resource:listResources[z], checked:false} )
               }
            }
        }
    }

    /* --------------------( Messages view )-------------------- */

    Flickable {
        id: flickable
        boundsBehavior: Flickable.DragAndOvershootBounds

        anchors { top: parent.top; topMargin:5; bottom: txtMessage.top; bottomMargin: 2; left: parent.left; right: parent.right }

        contentHeight: listViewMessages.contentHeight

        ListView {
            id: listViewMessages
            interactive: false
            anchors { fill: parent }
            clip: true
            model: xmppConnectivity.cachedMessages
            delegate: componentWrapperItem
            spacing: 5
            onHeightChanged: flickable.contentY = flickable.contentHeight;
        }

        Component.onCompleted: contentY = contentHeight-height;
        onHeightChanged: contentY = contentHeight;
    }
    /*--------------------( Text input field )--------------------*/
    TextArea {
              id: txtMessage
              anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
              placeholderText: qsTr( "Tap here to enter message..." )

              onTextChanged: {
                  if (text.lenght > 0 && !isTyping) {
                    isTyping = true
                    xmppConnectivity.client.typingStart( xmppConnectivity.chatJid, vars.resourceJid )
                  }
                  if (text.length == 0 && isTyping) {
                      isTyping = false
                      xmppConnectivity.client.typingStop( xmppConnectivity.chatJid, vars.resourceJid )
                  }
                  if (text.charCodeAt(text.length-1) === 10) {
                      text = text.substring(0,text.length-1)
                      sendMessage()
                  }
              }
              Component.onCompleted: text = xmppConnectivity.getPreservedMsg(xmppConnectivity.chatJid);
    }

    /********************************( Toolbar )************************************/
    ToolBarLayout {
        id: toolBar

        /****/
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                if (isTyping) xmppConnectivity.client.typingStop( xmppConnectivity.chatJid, vars.resourceJid )
                pageStack.pop()
                xmppConnectivity.resetUnreadMessages( xmppConnectivity.chatJid )
                xmppConnectivity.chatJid = ""
            }
            onPlatformPressAndHold: {
                xmppConnectivity.closeChat(xmppConnectivity.chatJid )
            }
        }
        ToolButton {
            id: toolBarButtonSend
            iconSource: main.platformInverted ? "qrc:/toolbar/send_inverse" : "qrc:/toolbar/send"
            opacity: enabled ? 1 : 0.5
            enabled: txtMessage.text != "" && xmppConnectivity.client.stateConnect === 1
            onClicked: sendMessage()
        }
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            onClicked: {
                xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                xmppConnectivity.resetUnreadMessages( xmppConnectivity.chatJid ) //cleans unread count for this JID
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
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
            onClicked: {
                xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                dialog.createWithProperties("qrc:/menus/Messages",{"contactName":contactName})
            }
        }
    }
}
