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

import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import lightbulb 1.0
import "../Components"

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

    // facebook is retarded
    property bool   isFacebook: xmppConnectivity.useClient(accountId).isFacebook()

    property bool isConnected: xmppConnectivity.useClient(accountId).isConnected

    onLogGenerationModeChanged: {
        showToolBar = !logGenerationMode
    }

    onArchivePageChanged: {
        // update list model when page changes
        listViewMessages.model = xmppConnectivity.getSqlMessagesByPage(accountId,contactJid,archivePage)
    }

    ListView {
        id: listViewMessages
        anchors { fill: parent; bottomMargin: isInArchiveMode ? logButtons.height : msgInputField.height + (msgInputField.focus ? PlatformStyle.paddingLarge : 0) }

        property int oldHeight;

        clip: true

        delegate: Loader {
            source: isInArchiveMode ? "qrc:/Components/Convo/ArchiveDelegate" : (msgType == 4 ? "qrc:/Components/Convo/InformationDelegate" : (isMine ? "qrc:/Components/Convo/OutcomingDelegate" : ":/Components/Convo/IncomingDelegate"))
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

        ScrollBar.vertical: ScrollBar { }
    }

    Component.onCompleted: {
        // sending a chat state meaning that chat is active if not in archive mode
        if (!isInArchiveMode) {
            xmppConnectivity.openChat(accountId,contactJid,contactResource)
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

            if (xmppConnectivity.getStatusByIndex(accountId) != 0) {
                var listResources = xmppConnectivity.useClient(accountId).getResourcesByJid(contactJid)
                for (var z=0; z<listResources.length; z++) {
                    if (listResources[z] !== "")
                        listModelResources.append({resource:listResources[z], checked:(contactResource == listResources[z])})
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
            //notify.notifySndVibr("MsgSent")
        } console.log("Something went wrong")//else avkon.displayGlobalNote("Something went wrong while sending a message.",true);

        xmppConnectivity.resetUnreadMessages(accountId,contactJid)
    }

    // timer for handling "stopped" notifications
    Timer {
        id: waitForInactivity
        interval: 100000
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
        Component.onCompleted: text = xmppConnectivity.getPreservedMsg(accountId,contactJid);
    }

    // toolbar
    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "\uE72B"
                font.family: "Segoe MDL2 Assets"
                onClicked: {
                    // send a chatstate
                    if (chatType != 3)
                        xmppConnectivity.useClient(accountId).sendMessage(contactJid,contactResource,"",2,0)

                    // go back to previous page
                    stack.pop()

                    xmppConnectivity.preserveMsg(accountId,contactJid,msgInputField.text)
                    xmppConnectivity.resetUnreadMessages(accountId,contactJid)
                }
                onPressAndHold: xmppConnectivity.closeChat(accountId,contactJid)
            }
            ToolButton {
                id: toolBarButtonSend
                text: "\uE724"
                font.family: "Segoe MDL2 Assets"
                opacity: enabled ? 1 : 0.5
                enabled: msgInputField.text != "" && isConnected
                onClicked: sendMessage()
            }
            ToolButton {
                text: "\uE723"
                font.family: "Segoe MDL2 Assets"
                opacity: enabled ? 1 : 0.5
                enabled: isConnected
                onClicked: {
                    dialog.createWithProperties("qrc:/dialogs/Attachment",{"accountId":accountId,"contactJid":contactJid,"contactResource":contactResource,"isFacebook":isFacebook})
                }
            }

            ToolButton {
                text: "\uE712"
                font.family: "Segoe MDL2 Assets"
                onClicked: {
                    xmppConnectivity.preserveMsg(accountId,contactJid,msgInputField.text)

                    var menuPath = "qrc:/menus/Messages";
                    if (isInArchiveMode)
                        menuPath = "qrc:/menus/Archive";
                    if (chatType == 3) {
                        menuPath = "qrc:/menus/MucOptions"
                    }
                    dialog.createWithProperties(menuPath,{"accountId":accountId,"contactJid":contactJid,"contactResource":contactResource})
                }
            }
        }
    }

    RowLayout {
        id: archiveButtons
        enabled: isInArchiveMode
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        z: isInArchiveMode ? 1 : -1
        visible: isInArchiveMode

        ToolButton {
            text: "\uE72B"
            font.family: "Segoe MDL2 Assets"
            enabled: totalArchivePages - archivePage > 0
            opacity: enabled ? 1 : 0.2
            onClicked: archivePage++
        }
        ToolButton {
            text: "\uE72A"
            font.family: "Segoe MDL2 Assets"
            enabled: archivePage > 1
            opacity: enabled ? 1 : 0.2
            onClicked: archivePage--
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
            //iconSource: main.platformInverted ? "qrc:/toolbar/ok_inverse" : "qrc:/toolbar/ok"
            anchors { left: parent.left; leftMargin: PlatformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
            text: "Done"
            width: parent.width/2 - 2*PlatformStyle.paddingSmall
            enabled: logGenerationMode
            onClicked: {
                stack.replace("qrc:/Pages/LogView",{"logText":xmppConnectivity.generateLog(accountId,contactJid,contactName,beginID,endID)});
                logGenerationMode = false;
                beginID = -1;
                endID = -1;
            }
        }
        ToolButton {
            //iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
            text: "Cancel"
            width: parent.width/2 - 2*PlatformStyle.paddingSmall
            anchors { right: parent.right; rightMargin: PlatformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
            enabled: logGenerationMode
            onClicked: {
                logGenerationMode = false;
                beginID = -1;
                endID = -1;
            }
        }
    }
}
