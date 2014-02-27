import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Page {
    id: messagesPage
    tools: toolBar
    /************************************************************/
    property string resourceJid: ""
    property bool isTyping: false
    property bool emoticonsDisabled: settings.gBool("behavior","disableEmoticons")

    Component.onCompleted: {
        xmppConnectivity.page = 1
        console.log( xmppConnectivity.chatJid )
        xmppConnectivity.client.openChat( xmppConnectivity.chatJid )

        statusBarText.text = vars.contactName

        if( xmppConnectivity.client.bareJidLastMsg == xmppConnectivity.chatJid ) messagesPage.resourceJid = xmppConnectivity.client.resourceLastMsg

        if( messagesPage.resourceJid == "" ) listModelResources.append( {resource:qsTr("(by default)"), checked:true} )
        else listModelResources.append( {resource:qsTr("(by default)"), checked:false} )

        if (notify.getStatusName() != "Offline") {
            var listResources = xmppConnectivity.client.getResourcesByJid(xmppConnectivity.chatJid)
            for( var z=0; z<listResources.length; z++ ) {
                if ( listResources[z] == "" ) { continue; }
                if ( messagesPage.resourceJid ==listResources[z] ) listModelResources.append( {resource:listResources[z], checked:true} )
                else listModelResources.append( {resource:listResources[z], checked:false} )
           }
        }
        vars.isChatInProgress = true
        notify.updateNotifiers()
    }
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
                      text: "<font color='#009FEB'>" + ( isMine == true ? qsTr("Me") : (vars.contactName === "" ? xmppConnectivity.chatJid : vars.contactName) ) + ":</font> " + (emoticonsDisabled ? msgText : emoticon.parseEmoticons(msgText))
                      color: isMine == true ? "white" : "black"
                      font.pixelSize: 16
                      wrapMode: Text.Wrap
                      onLinkActivated: { vars.url=link; linkContextMenu.open()}
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
        var ret = xmppConnectivity.client.sendMyMessage( xmppConnectivity.chatJid, messagesPage.resourceJid, txtMessage.text )
        if( ret ) {
              txtMessage.text = ""
              xmppConnectivity.client.typingStop( xmppConnectivity.chatJid, messagesPage.resourceJid )
              notify.notifySndVibr("MsgSent")
        }
    }
    /* --------------------( resources )-------------------- */
    ListModel { id: listModelResources }

    /* ------------( XMPP client and stuff )------------ */
    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: if( jid == xmppConnectivity.chatJid ) messagesPage.resourceJid = xmppConnectivity.client.resourceLastMsg
        onQmlChatChanged: {
            console.log( "qml chat jid switched to " +xmppConnectivity.chatJid )
            xmppConnectivity.client.openChat( xmppConnectivity.chatJid )

            statusBarText.text = vars.contactName

            if( xmppConnectivity.client.bareJidLastMsg == xmppConnectivity.chatJid ) messagesPage.resourceJid = xmppConnectivity.client.resourceLastMsg

            if( messagesPage.resourceJid == "" ) listModelResources.append( {resource:qsTr("(by default)"), checked:true} )
            else listModelResources.append( {resource:qsTr("(by default)"), checked:false} )

            if (notify.getStatusName() != "Offline") {
                var listResources = xmppConnectivity.client.getResourcesByJid(xmppConnectivity.chatJid)
                for( var z=0; z<listResources.length; z++ ) {
                    if ( listResources[z] == "" ) { continue; }
                    if ( messagesPage.resourceJid ==listResources[z] ) listModelResources.append( {resource:listResources[z], checked:true} )
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
                    xmppConnectivity.client.typingStart( xmppConnectivity.chatJid, messagesPage.resourceJid )
                  }
                  if (text.length == 0 && isTyping) {
                      isTyping = false
                      xmppConnectivity.client.typingStop( xmppConnectivity.chatJid, messagesPage.resourceJid )
                  }
                  if (text.charCodeAt(text.length-1) === 10) {
                      text = text.substring(0,text.length-1)
                      sendMessage()
                  }
              }
              Component.onCompleted: text = xmppConnectivity.getPreservedMsg(xmppConnectivity.chatJid);
    }
    Item {
        id: splitViewInput

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Behavior on height { PropertyAnimation { duration: 1 } }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height-toolBar.height }
                PropertyChanges { target: vars; inputInProgress: true }
            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; }
                PropertyChanges { target: vars; inputInProgress: false }
            }
        ]
    }
    CommonDialog {
        id: dlgResources
        titleText: qsTr("Resources")
        privateCloseIcon: true
        platformInverted: main.platformInverted

        content: ListView {
                    anchors.fill: parent
                    height: (listModelResources.count*48)+1
                    highlightFollowsCurrentItem: false
                    model: listModelResources
                    delegate: Component {
                        Rectangle {
                            id: itemResource
                            height: 48
                            width: parent.width
                            gradient: gr_normal
                            Gradient {
                                id: gr_normal
                                GradientStop { position: 0; color: "transparent" }
                                GradientStop { position: 1; color: "transparent" }
                            }
                            Gradient {
                                id: gr_press
                                GradientStop { position: 0; color: "#1C87DD" }
                                GradientStop { position: 1; color: "#51A8FB" }
                            }
                            Text {
                                id: textResource
                                text: resource
                                font.pixelSize: itemResource.height/2
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                color: vars.textColor
                                font.bold: false
                            }
                            states: State {
                                name: "Current"
                                when: itemResource.ListView.isCurrentItem
                                PropertyChanges { target: itemResource; gradient: gr_press }
                                PropertyChanges { target: textResource; color: platformStyle.colorNormalLight }
                                PropertyChanges { target: textResource; font.bold: true }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    itemResource.ListView.view.currentIndex = index

                                    if( index == 0 ) messagesPage.resourceJid = ""
                                    else messagesPage.resourceJid = resource

                                    for (var i=0; i<listModelResources.count; i++) {
                                        if(index == i) listModelResources.get(index).checked = true
                                        else listModelResources.get(index).checked = false
                                    }
                                    dlgResources.close()
                                } //onClicked
                            } //MouseArea
                        }
                    } //Component
                }
    }

    /********************************( Toolbar )************************************/
    ToolBarLayout {
        id: toolBar

        /****/
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                if (isTyping) xmppConnectivity.client.typingStop( xmppConnectivity.chatJid, messagesPage.resourceJid )
                pageStack.pop()
                vars.isChatInProgress = false
                statusBarText.text = "Contacts"
                xmppConnectivity.client.resetUnreadMessages( xmppConnectivity.chatJid )
                xmppConnectivity.chatJid = ""
            }
            onPlatformPressAndHold: {
                xmppConnectivity.client.closeChat(xmppConnectivity.chatJid )
            }
        }
        ToolButton {
            id: toolBarButtonSend
            iconSource: main.platformInverted ? "qrc:/toolbar/send_inverse" : "qrc:/toolbar/send"
            opacity: enabled ? 1 : 0.5
            enabled: txtMessage.text != ""
            onClicked: sendMessage()
        }
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            onClicked: {
                xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                xmppConnectivity.client.resetUnreadMessages( xmppConnectivity.chatJid ) //cleans unread count for this JID
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
            onClicked: msgOptions.open()
        }
    }
    /*********************************************************************/
    Menu {
        id: msgOptions
        platformInverted: main.platformInverted
        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Set resource")
                platformInverted: main.platformInverted
                onClicked: dlgResources.open()
            }

            MenuItem {
                text: "Archive"
                platformInverted: main.platformInverted
                onClicked: {
                    xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                    xmppConnectivity.page = 1
                    pageStack.replace("qrc:/pages/Archive")
                }
            }
            MenuItem {
                text: "Close chat"
                platformInverted: main.platformInverted
                onClicked: {
                    pageStack.pop()
                    vars.isChatInProgress = false
                    xmppConnectivity.client.closeChat(xmppConnectivity.chatJid )
                    statusBarText.text = "Contacts"
                    xmppConnectivity.client.resetUnreadMessages( xmppConnectivity.chatJid )
                    xmppConnectivity.chatJid = ""
                }
            }

            /*MenuItem {
                text: "Send attention"
                onClicked: xmppConnectivity.client.attentionSend( xmppConnectivity.chatJid, messagesPage.resourceJid )
            }*/
        }
    }
}
