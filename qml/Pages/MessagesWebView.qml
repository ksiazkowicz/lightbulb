import QtQuick 1.1
import com.nokia.symbian 1.1
import QtWebKit 1.0

Page {
    id: messagesPage
    tools: toolBar
    /************************************************************/
    property string resourceJid: ""
    property bool isTyping: false

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
    }
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
    }

    /* --------------------( Messages view )-------------------- */

    Flickable{
        id: flickable
        width: parent.width
        height: 640
        signal gotFocus
        signal lostFocus
        anchors{top: parent.top; bottom: txtMessage.top; right: parent.right;left:parent.left}
        contentWidth: Math.max(parent.width,webView.width)
        contentHeight: Math.max(parent.height,webView.height)
        maximumFlickVelocity: 6000
        flickDeceleration: 3000
        boundsBehavior: "StopAtBounds"
        flickableDirection: Flickable.HorizontalFlick
       WebView{
           id: webView
           smooth: false
           //url: "test.html"
           focus: true
           html: "<b>kurwa T_T</b>"
           settings.offlineStorageDatabaseEnabled : true
           settings.offlineWebApplicationCacheEnabled : true
           settings.javascriptCanOpenWindows: true
           settings.localStorageDatabaseEnabled : true
           settings.localContentCanAccessRemoteUrls: true
           settings.minimumFontSize: 16
           settings.javascriptEnabled: true
           settings.minimumLogicalFontSize: 16
           settings.javascriptCanAccessClipboard: true
           settings.autoLoadImages: true
           settings.defaultFontSize: 16
           preferredHeight: flickable.height
           preferredWidth: flickable.width
           //This is where you put whatever function you want it to do
           // The function needs to be called like this: window.qml.qmlCall();
           //you can change qmlCall to whatever you want, the project with compile with a working offline html example
           javaScriptWindowObjects: QtObject {
                    WebView.windowObjectName: "qml"
                    function kurwiu() { webView.html = "<b>kurwa T_T</b>"; }
                    function qmlCall() {console.log(webView.url)}
                        function appCall (){console.log ("Hello, you can put whatever function you desire here ")}
           }
           onDoubleClick: {
               //whatever you want
           }
           onUrlChanged: {
               //looses focus sometimes when the URL is changed
               webView.focus = true;
           }
       }


    }
    /*--------------------( Text input field )--------------------*/
    TextArea {
              id: txtMessage
              anchors.bottom: splitViewInput.top
              anchors.left: parent.left;
              anchors.right: parent.right;
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
