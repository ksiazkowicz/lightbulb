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
        - handle copying messages to clipboard
        - handle switching between archive and chat mode
        - handle actually getting some data
        - handle emoticons
        - ...

      ****************************************/

    // conversation page properties
    property string pageName:        contactName
    property string contactName:     "Some guy"
    property string contactJid:      "something@got.broken"
    property string contactResource: ""
    property string accountId:       "/dev/null"
    property bool   isInArchiveMode: false
    property bool   isTyping:        false

    Button {
        text: "sjdklasjd"
        onClicked: isInArchiveMode = !isInArchiveMode
    }

    Component.onCompleted: {
        // sending a chat state if not in archive mode
        if (!isInArchiveMode)
            xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",1);
    }

    function sendMessage() {
        if (isInArchiveMode || msgInputField.text == "")
            return;

        xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,msgInputField.text,1);
        waitForInactivity.running = false
        isTyping = false
        msgInputField.text = ""
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
        placeholderText: qsTr( "Tap here to enter message..." )
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
    tools: isInArchiveMode ? archiveToolBar : chatToolBar

    ToolBarLayout {
        id: archiveToolBar // todo todo todo
    }
    ToolBarLayout {
        id: chatToolBar
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                // send a chatstate
                xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",2)

                // go back to previous page
                pageStack.pop()

                xmppConnectivity.preserveMsg(contactJid,msgInputField.text)
                xmppConnectivity.resetUnreadMessages(accountId,contactJid)

                /*vars.isChatInProgress = false
                xmppConnectivity.chatJid = ""*/
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
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            onClicked: {
                xmppConnectivity.preserveMsg(contactJid,msgInputField.text)
                xmppConnectivity.resetUnreadMessages(accountId,contactJid) //cleans unread count for this JID
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
                /*xmppConnectivity.preserveMsg(xmppConnectivity.chatJid,txtMessage.text)
                dialog.createWithProperties("qrc:/menus/Messages",{"contactName":contactName})*/
            }
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (conversationPage.status === PageStatus.Inactive) conversationPage.destroy()
}
