/********************************************************************

qml/Pages/ConversationPage.qml
-- contains conversation view, interfaces with XmppConnectivity to
-- display and send messages

Copyright (c) 2014 Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Page {
    id: conversationPage

    /******************************************
      TODO:
        - handle resources
        - add a menu
        - handle different types of messages
        - handle unread and read messages
        - handle switching between archive and chat mode
        - ...

      ****************************************/

    // conversation page properties
    property string pageName:        contactName
    property string contactName:     "Some guy"
    property string contactJid:      "something@got.broken"
    property string contactResource: ""
    property string accountId:       "/dev/null"
    property bool   isInArchiveMode: false
    property bool   isAChatPage:     true
    property bool   isTyping:        false
    property int    chatType:        0

    Component {
        id: msgComponent
        Item {
        MouseArea {
            anchors.fill: parent
            onPressAndHold: dialog.createWithProperties("qrc:/menus/MessageContext", {"msg": msgText})
        }
        id: wrapper
        width: listViewMessages.width - 10
        height: triangleTop.height + bubbleTop.height/2 + message.height + bubbleBottom.height/2 + triangleBottom.height

        property int marginRight: isMine == true ? platformStyle.paddingLarge*3 : platformStyle.paddingSmall
        property int marginLeft: isMine == true ? platformStyle.paddingSmall : platformStyle.paddingLarge*3

        anchors.horizontalCenter: parent.horizontalCenter
        Image {
            id: triangleTop
            anchors { top: parent.top; right: parent.right; rightMargin: platformStyle.paddingMedium*2 }
            source: isMine == true ? "" : "qrc:/images/bubble_incTriangle.png"
            width: platformStyle.paddingLarge
            height: isMine == true ? 0 : platformStyle.paddingLarge
        }
        Rectangle {
            id: bubbleTop
            anchors { top: triangleTop.bottom;
                left: parent.left;
                right: parent.right;
                rightMargin: wrapper.marginRight
                leftMargin: wrapper.marginLeft
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
                    rightMargin: wrapper.marginRight
                    leftMargin: wrapper.marginLeft
                }
                height: 20
                gradient: Gradient {
                    GradientStop { position: 0.0; color: isMine == true ? "#56565b" : "#e6e6eb" }
                    GradientStop { position: 0.5; color: isMine == true ? "#56565b" : "#e6e6eb" }
                    GradientStop { position: 1.0; color: isMine == true ? "#46464b" : "#b9b8bd" }
                }

                radius: 8
                smooth: true
            }
            Rectangle {
                id: bubbleCenter
                anchors {
                    top: bubbleTop.top;
                    topMargin: 10;
                    rightMargin: wrapper.marginRight;
                    leftMargin: wrapper.marginLeft;
                    left: wrapper.left;
                    right: wrapper.right;
                    bottom: bubbleBottom.bottom;
                    bottomMargin: 10
                }
                color: isMine == true ? "#56565b" : "#e6e6eb"
                Text {
                      id: message
                      anchors { top: parent.top; left: parent.left; leftMargin: platformStyle.paddingSmall; right: parent.right; rightMargin: platformStyle.paddingSmall }
                      property string messageText: vars.areEmoticonsDisabled ? msgText : emoticon.parseEmoticons(msgText)
                      property string date: dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? dateTime.substr(9,5) : dateTime
                      property string name: isMine == true ? qsTr("Me") : msgType !== 3 ? (contactName === "" ? xmppConnectivity.chatJid : contactName) : msgResource

                      text: "<font color='#009FEB'>" + name + ":</font> " + messageText + "<div align='right' style='color: \"#999999\"'>"+ date + "</div>"
                      color: isMine == true ? platformStyle.colorNormalLight : platformStyle.colorNormalDark
                      font.pixelSize: platformStyle.fontSizeSmall
                      wrapMode: Text.WordWrap
                      onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
                }
            }

            Image {
                id: triangleBottom
                anchors { bottom: parent.bottom;
                    left: parent.left;
                    leftMargin: platformStyle.paddingMedium*2
                }
                source: isMine == true ? "qrc:/images/bubble_outTriangle.png" : ""
                width: platformStyle.paddingLarge
                height: isMine == true ? platformStyle.paddingLarge : 0
            }
        }
    }


    ListView {
        id: listViewMessages
        anchors { left: parent.left; right: parent.right; bottom: msgInputField.top; top: parent.top }
        model: isInArchiveMode ? xmppConnectivity.messagesByPage : xmppConnectivity.cachedMessages

        delegate: msgComponent

        spacing: 5
        onHeightChanged: positionViewAtEnd();
        onCountChanged: goToEnd()

        function goToEnd() {
            anim.from = contentY;
            positionViewAtEnd();
            var destination = contentY;
            anim.to = destination
            anim.running = true;
        }

        NumberAnimation { id: anim; target: listViewMessages; property: "contentY"; duration: 100 }
    }

    Component.onCompleted: {
        // sending a chat state meaning that chat is active if not in archive mode
        if (!isInArchiveMode) {
            xmppConnectivity.openChat( accountId,contactJid )
        }

        // get messages for jid
        xmppConnectivity.chatJid = contactJid
    }

    function sendMessage() {
        // disable chat states stuff
        waitForInactivity.running = false
        isTyping = false

        // check if function should be called
        if (isInArchiveMode || msgInputField.text == "")
            return;

        var messageWasSent = xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,msgInputField.text,1,chatType);
        if (messageWasSent) {
            msgInputField.text = ""
            notify.notifySndVibr("MsgSent")
        } else avkon.displayGlobalNote("Something went wrong while sending a message.",true);
    }


    // timer for handling "stopped" notifications
    Timer {
        id: waitForInactivity
        interval: 9000 //OVER 9000!!!!!11111111111
        repeat: false
        onTriggered: {
            if (isTyping) {
                isTyping = false;
                xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",5)
            }
        }
    }

    // text input field
    TextArea {
        id: msgInputField
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        placeholderText: qsTr( "Tap here to enter a message..." )
        visible: !isInArchiveMode
        enabled: visible

        onTextChanged: {
            if (text.length > 0 && !isTyping) {
                isTyping = true
                // sending a chat state
                xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",4)

                // wait for inactivity
                waitForInactivity.running = false
                waitForInactivity.running = true
            }

            if (text.charCodeAt(text.length-1) === 10) {
                text = text.substring(0,text.length-1)
                sendMessage()
            }
        }
        Component.onCompleted: text = xmppConnectivity.getPreservedMsg(contactJid);
    }

    // toolbar
    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                // send a chatstate
                xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",2,0)

                // go back to previous page
                pageStack.pop()

                xmppConnectivity.preserveMsg(contactJid,msgInputField.text)
                xmppConnectivity.resetUnreadMessages(accountId,contactJid)

                // unload messages, deselect contact
                xmppConnectivity.chatJid = ""
            }
            onPlatformPressAndHold: xmppConnectivity.closeChat(contactJid)
        }
        ToolButton {
            id: toolBarButtonSend
            iconSource: main.platformInverted ? "qrc:/toolbar/send_inverse" : "qrc:/toolbar/send"
            opacity: enabled ? 1 : 0.5
            enabled: msgInputField.text != ""
            onClicked: sendMessage()
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
            enabled: false
            onClicked: {
                /*xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                dialog.createWithProperties("qrc:/menus/Messages",{"contactName":contactName})*/
            }
        }
    }

    /*tools: ToolBarLayout {
            ToolButton {
                iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
                onClicked: {
                    pageStack.pop("qrc:/pages/Messages")
                    xmppConnectivity.chatJid = ""
                    xmppConnectivity.page = 1
                }
            }
            ButtonRow {
                ToolButton {
                    iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
                    enabled: xmppConnectivity.messagesCount - xmppConnectivity.page> 0
                    opacity: enabled ? 1 : 0.2
                    onClicked: xmppConnectivity.page++;
                }
                ToolButton {
                    iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
                    enabled: xmppConnectivity.page > 1
                    opacity: enabled ? 1 : 0.2
                    onClicked: {
                        xmppConnectivity.page--;
                        flickable.contentY = flickable.contentHeight-flickable.height;
                    }
                }
            }
            ToolButton {
                iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
                onClicked: dialog.create("qrc:/dialogs/Chats")
                Image {
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
                    text: vars.globalUnreadCount
                    font.pixelSize: 16
                    anchors.centerIn: parent
                    visible: vars.globalUnreadCount != 0
                    z: 1
                    color: main.platformInverted ? "white" : "black"
                 }
            }
           }


    // Code for destroying the page after pop
    onStatusChanged: if (conversationPage.status === PageStatus.Inactive) conversationPage.destroy()
}
*/
}
