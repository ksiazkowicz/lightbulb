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
        - handle switching between archive and chat mode
        - handle attachments
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

    ListView {
        id: listViewMessages
        anchors { fill: parent; bottomMargin: msgInputField.height }
        model: isInArchiveMode ? xmppConnectivity.messagesByPage : xmppConnectivity.cachedMessages

        property int oldHeight;

        delegate: Loader {
            source: isInArchiveMode ? ":/Components/Convo/ArchiveDelegate.qml" : (msgType == 4 ? ":/Components/Convo/InformationDelegate" : (isMine ? ":/Components/Convo/OutcomingDelegate" : ":/Components/Convo/IncomingDelegate"))
            property string _msgText: msgText
            property string _msgResource: msgResource
            property int _msgType: msgType
            property string _contactName: contactName
            property string _contactJid: contactJid
            property string _dateTime: dateTime
            property bool _msgUnreadState: msgUnreadState
            height: sourceComponent.height
            width: listViewMessages.width
        }

        spacing: 5
        Component.onCompleted: {
            oldHeight = height;
            goToEnd()
        }
        onHeightChanged: {
            if (oldHeight - height > 0) {
                contentY+= (oldHeight - height)
            }
            oldHeight = height;
        }
        onCountChanged: goToEnd()

        function goToEnd(animDestination) {
            anim.from = contentY;
            positionViewAtEnd();
            var destination = contentY;
            anim.to = destination
            if ((anim.to - anim.from) - height < 0)
                anim.running = true;
        }

        NumberAnimation { id: anim; target: listViewMessages; property: "contentY"; duration: 100 }
    }

    Component.onCompleted: {
        // sending a chat state meaning that chat is active if not in archive mode
        if (!isInArchiveMode) {
            xmppConnectivity.openChat( accountId,contactJid )
        } else {
            xmppConnectivity.page = 1;
        }

        // get messages for jid
        xmppConnectivity.chatJid = contactJid

        // if not MUC, get resources
        if (chatType != 3) {
            // get resources
            listModelResources.clear()

            listModelResources.append({resource:qsTr("(by default)"), checked:(contactResource == "")})

            if (notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accountId)) != "Offline") {
                var listResources = xmppConnectivity.getResourcesByJid(accountId,contactJid)
                for( var z=0; z<listResources.length; z++ ) {
                    if (listResources[z] == "") { continue; }
                    if (contactResource ==listResources[z]) listModelResources.append({resource:listResources[z], checked:true})
                    else listModelResources.append({resource:listResources[z], checked:false})
                }
            }
        } else {
            console.log("--Current permission level--")
            console.log("Subject changing: " + xmppConnectivity.canIChangeMucSubject(accountId,contactJid))
            console.log("Room configuration changing: " + xmppConnectivity.canIChangeMucConfiguration(accountId,contactJid))
            console.log("Enumerating permissions: " + xmppConnectivity.canIRequestPermissions(accountId,contactJid))
            console.log("Kicking users: " + xmppConnectivity.canIKickSomeone(accountId,contactJid))
        }
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

        xmppConnectivity.resetUnreadMessages(accountId,contactJid)
    }


    // timer for handling "stopped" notifications
    Timer {
        id: waitForInactivity
        interval: 9000 //OVER 9000!!!!!11111111111
        repeat: false
        onTriggered: {
            if (isTyping) {
                isTyping = false;
                xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",5,2)
            }
            xmppConnectivity.resetUnreadMessages(accountId,contactJid)
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
                xmppConnectivity.sendAMessage(accountId,contactJid,contactResource,"",4,2)

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

                xmppConnectivity.preserveMsg(accountId,contactJid,msgInputField.text)
                xmppConnectivity.resetUnreadMessages(accountId,contactJid)

                // unload messages, deselect contact
                xmppConnectivity.chatJid = ""
            }
            onPlatformPressAndHold: xmppConnectivity.closeChat(accountId,contactJid)
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
            onClicked: {
                xmppConnectivity.preserveMsg(accountId,contactJid,msgInputField.text)

                var menuPath = "qrc:/menus/Messages";
                if (isInArchiveMode)
                    menuPath = "qrc:/menus/Archive";
                if (chatType == 3) {
                    menuPath = "qrc:/menus/MucOptions"
                }
                dialog.createWithProperties(menuPath,{"accountId":accountId,"contactJid":contactJid})
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
           }


    // Code for destroying the page after pop
    onStatusChanged: if (conversationPage.status === PageStatus.Inactive) conversationPage.destroy()
}
*/
}
