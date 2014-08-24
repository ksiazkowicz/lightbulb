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

    // muc
    property int    chatType
    property int availableActions

    // archive
    property int    archivePage
    property int    totalArchivePages
    property int    beginID:           -1
    property int    endID:             -1
    property bool   logGenerationMode: false
    onLogGenerationModeChanged: {
        showToolBar = !logGenerationMode
    }

    onArchivePageChanged: {
        // update list model when page changes
        listViewMessages.model = xmppConnectivity.getSqlMessagesByPage(accountId,contactJid,archivePage)
    }

    ListView {
        id: listViewMessages
        anchors { fill: parent; bottomMargin: isInArchiveMode ? logButtons.height : msgInputField.height }

        property int oldHeight;

        delegate: Loader {
            source: isInArchiveMode ? ":/Components/Convo/ArchiveDelegate" : (msgType == 4 ? ":/Components/Convo/InformationDelegate" : (isMine ? ":/Components/Convo/OutcomingDelegate" : ":/Components/Convo/IncomingDelegate"))
            property string _msgText: msgText
            property string _msgResource: !isInArchiveMode ? msgResource : ""
            property int _msgType: !isInArchiveMode ? msgType : 0
            property string _contactName: contactName
            property string _contactJid: contactJid
            property string _dateTime: dateTime
            property bool _msgUnreadState: !isInArchiveMode ? msgUnreadState : false
            property bool _isMine: isMine
            property int _id: isInArchiveMode ? id : 0
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
            listViewMessages.model = xmppConnectivity.getMessages(contactJid)
        } else {
            archivePage = 1
            totalArchivePages = xmppConnectivity.getPagesCount(accountId,contactJid)
        }

        // if not MUC, get resources
        if (chatType != 3) {
            // get resources
            listModelResources.clear()

            listModelResources.append({resource:qsTr("(by default)"), checked:(contactResource == "")})

            if (notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accountId)) != "Offline") {
                var listResources = xmppConnectivity.useClient(accountId).getResourcesByJid(contactJid)
                for( var z=0; z<listResources.length; z++ ) {
                    if (listResources[z] == "") { continue; }
                    if (contactResource ==listResources[z]) listModelResources.append({resource:listResources[z], checked:true})
                    else listModelResources.append({resource:listResources[z], checked:false})
                }
            }
        } else availableActions = xmppConnectivity.useClient(accountId).getPermissionLevel(contactJid);
    }

    function sendMessage() {
        // disable chat states stuff
        waitForInactivity.running = false
        isTyping = false

        // check if function should be called
        if (isInArchiveMode || msgInputField.text == "")
            return;

        var messageWasSent = xmppConnectivity.useClient(accountId).sendMessage(contactJid,contactResource,msgInputField.text,1,chatType);
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
                if (chatType != 3)
                    xmppConnectivity.useClient(accountId).sendMessage(contactJid,contactResource,"",5,2)
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
                if (chatType != 3)
                    xmppConnectivity.useClient(accountId).sendMessage(contactJid,contactResource,"",4,2)

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
                if (chatType != 3)
                    xmppConnectivity.useClient(accountId).sendMessage(contactJid,contactResource,"",2,0)

                // go back to previous page
                pageStack.pop()

                xmppConnectivity.preserveMsg(accountId,contactJid,msgInputField.text)
                xmppConnectivity.resetUnreadMessages(accountId,contactJid)
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

    ButtonRow {
        id: archiveButtons
        enabled: isInArchiveMode
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        z: isInArchiveMode ? 1 : -1
        visible: isInArchiveMode

        ToolButton {
            iconSource: "toolbar-previous"
            enabled: totalArchivePages - archivePage > 0
            opacity: enabled ? 1 : 0.2
            onClicked: archivePage++
            platformInverted: main.platformInverted
        }
        ToolButton {
            iconSource: "toolbar-next"
            enabled: archivePage > 1
            opacity: enabled ? 1 : 0.2
            onClicked: archivePage--
            platformInverted: main.platformInverted
        }
    }

    ToolBar {
        id: logButtons
        enabled: logGenerationMode
        anchors.bottom: parent.bottom
        z: logGenerationMode ? 1 : -1
        visible: logGenerationMode
        height: visible ? 60 : 0

        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/ok_inverse" : "qrc:/toolbar/ok"
            anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
            text: "Done"
            width: parent.width/2 - 2*platformStyle.paddingSmall
            platformInverted: main.platformInverted
            enabled: logGenerationMode
            onClicked: {
                pageStack.replace("qrc:/pages/LogView",{"logText":xmppConnectivity.generateLog(accountId,contactJid,contactName,beginID,endID)});
                logGenerationMode = false;
                beginID = -1;
                endID = -1;
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
            text: "Cancel"
            width: parent.width/2 - 2*platformStyle.paddingSmall
            anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
            platformInverted: main.platformInverted
            enabled: logGenerationMode
            onClicked: {
                logGenerationMode = false;
                beginID = -1;
                endID = -1;
            }
        }
    }

    // Code for destroying the page after pop
    onStatusChanged: if (conversationPage.status === PageStatus.Inactive) conversationPage.destroy()
}
