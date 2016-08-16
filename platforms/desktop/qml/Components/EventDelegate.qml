/********************************************************************

qml/Components/EventDelegate.qml
-- delegate for event on Events page

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
import lightbulb 1.0
import "."

Flickable {
    id: flick
    height: 64
    flickableDirection: Flickable.HorizontalFlick
    boundsBehavior: Flickable.DragOverBounds
    contentWidth: wrapper.width *2

    property int transferProgress;
    property int transferState;
    property bool progressEnabled: transferState == 2;

    Connections {
        target: xmppConnectivity.useClient(accountID)
        onProgressChanged: if (jobId == transferJob) transferProgress = progress;
        onTransferStateChanged: if (jobId == transferJob) transferState = state;
    }

    function getIcon() {
        switch (type) {
        case 32: { if (xmppConnectivity.getChatType(accountID,bareJid) == 3) return "qrc:/muc"; else return xmppConnectivity.getAvatarByJid(bareJid); } // unread message
        case 33: return "qrc:/accounts/" + xmppConnectivity.getAccountIcon(accountID); // connection state change
        case 34: return "qrc:/subRequestIcon"; // subscription request
        case 35: return "qrc:/muc"; // muc invite, change it to something else later
        case 36: return "qrc:/attention"; // attention request
        case 37: return xmppConnectivity.getAvatarByJid(bareJid); // fav user status change
        case 38: return "qrc:/updateIcon"; // app update
        case 39: return "qrc:/errorIcon"; // connection error
        case 40: return "qrc:/incomingTransfer" // incoming transfer
        case 41: return "qrc:/outcomingTransfer" // outcoming transfer
        default: return "";
        }
    }

    function makeAction() {
        switch (type) {
        case 32: main.openChat(accountID,name,bareJid,xmppConnectivity.restoreResource(accountID,bareJid),xmppConnectivity.getChatType(accountID,bareJid)); break;
        case 34: { xmppConnectivity.useClient(accountID).acceptSubscription(bareJid); dialog.createWithProperties("qrc:/dialogs/Contact/Add",{"accountId": accountID, "bareJid": bareJid}); xmppConnectivity.events.removeEvent(index); break; }
        case 35: { dialog.createWithProperties("qrc:/dialogs/MUC/Join",{"accountId":accountID,"mucJid":bareJid}); xmppConnectivity.events.removeEvent(index)}; break;
        case 38: if (updater.isUpdateAvailable) dialog.createWithProperties("qrc:/menus/UrlContext", {"url": updater.updateUrl}); break;
        case 40: {
            switch (transferState) {
            case 0: xmppConnectivity.useClient(accountID).acceptTransfer(transferJob,vars.receivedFilesPath); break;
            case 3: xmppConnectivity.useClient(accountID).openLocalTransferPath(transferJob); break;
            }
            break;
        }
        default: return false;
        }
    }

    function makeAltAction() {
        switch (type) {
        case 32: { xmppConnectivity.resetUnreadMessages(accountID,bareJid); break; }
        case 34: xmppConnectivity.useClient(accountID).rejectSubscription(bareJid); return true;
        case 40:
        case 41: xmppConnectivity.useClient(accountID).abortTransfer(transferJob); break;
        default: return false;
        }
    }

    function getMiniIcon() {
        // used if type == 33 to determine which icon should be displayed
        switch (type) {
        case 33: {
            if (description.substring(0,7) == "Current")
                return ("qrc:/Presence/" + Helper.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accountID)));
        }; break;
        case 37: return xmppConnectivity.getPropertyByJid(accountID,"presence",bareJid);
        default: return "";
        }
    }

    function getDescription() {
        switch (type) {
        case 32: // unread message
        case 33: // connection state change
        case 37: // fav user status change
        case 38: // app update
        case 39: return description; // connection error

        case 34: return "Tap to subscribe contact."; // sub request
        case 35: return "I invited you to join chat at " + bareJid; // muc invite

        case 40: // incoming transfer
        case 41: { // outcoming transfer
            switch (transferState) {
            case 0: if (type == 41) return filename + ". Waiting for user."; else return filename + ". Tap to <b>accept</b>."
            case 1: case 2: case 3: return filename;
            }
        }
        case 36: return (count > 1) ? "You received " + count + " attention requests" : "You received an attention request."; // attention request
        default: return "";
        }
    }

    function getSecondRow() {
        switch (type) {
        case 32: case 33: case 35: case 36: case 37: case 38: case 39:
                                                                  return name
                                                              case 40: case 41:
                                                                           return transferState == 3 ? "Finished." + (type == 40 ? " Tap to <b>open</b>." : "") : transferState == 1 ? "Connecting..." :  name
        }
    }

    onContentXChanged: {
        wrapper.opacity = 1-(contentX/(wrapper.width))
        if (wrapper.opacity <= 0) {
            makeAltAction()
            xmppConnectivity.events.removeEvent(index)
        }
    }

    NumberAnimation {
        id: animation
        target: flick
        property: "contentX"
        to: 1.0
        duration: 250
        easing.type: Easing.Linear
        running: false
    }

    onMovingChanged: {
        if (!flicking && !moving) {
            if ((contentX/(wrapper.width)) >= 0.5) {
                animation.to = wrapper.width;
                animation.from = contentX;
                animation.running = true;
            } else {
                animation.to = 0;
                animation.from = contentX;
                animation.running = true;
            }
        }
    }

    Item {
        id: wrapper
        height: 60
        width: flick.width
        anchors.left: parent.left;
        Rectangle {
            anchors.fill: parent
            z: -1
            color: "transparent"
        }
        Image {
            id: icon
            width: parent.height
            height: parent.height
            sourceSize { height: height; width: width }
            smooth: true
            source: getIcon()

            Rectangle { anchors.fill: parent; color: (type == 32 || type == 37) ? "black" : "transparent"; z: -1 }
            Image {
                anchors.fill: parent
                smooth: true
                source: "qrc:/avatar-mask"
                sourceSize { width: 64; height: 64 }
                visible: (type == 32 && icon.source != "qrc:/muc") || (type == 37)
            }
            Image {
                id: mark
                z: 1
                anchors { bottom: parent.bottom; right: parent.right }
                width: type == 32 ? 64 : 24
                height: width
                sourceSize { height: height; width: width }
                source: type == 32 ? "qrc:/unread-count" : (type == 33 || type == 37) ? getMiniIcon() : ""
                visible: (type == 32) || (type == 33) || (type == 37)

                Label {
                    visible: type == 32
                    width: 20; height: width
                    color: PlatformStyle.colorNormalLight
                    text: type == 32 ? xmppConnectivity.getUnreadCount(accountID,bareJid)+1 : ""
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors { right: parent.right; bottom: parent.bottom }
                    font.pixelSize: width*0.72
                }
            }
        }
        ProgressBar {
            from: 0
            to: 100
            value: transferProgress
            visible: progressEnabled

            // adjust geometry all by yourself cause anchors get broken in this case
            anchors { right: parent.right; rightMargin: PlatformStyle.paddingSmall }
            y: descriptionRow.y + PlatformStyle.paddingMedium
            width: descriptionRow.width
        }
        Column {
            anchors { left: icon.right; leftMargin: PlatformStyle.paddingSmall; right: wrapper.right; rightMargin: PlatformStyle.paddingSmall; verticalCenter: wrapper.verticalCenter }
            height: text.height + PlatformStyle.paddingSmall + descriptionRow.height
            Label {
                id: text
                width: mainPage.width - 25 - 90
                maximumLineCount: 2
                font.pixelSize: 18
                text: getDescription()
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }
            Row {
                id: descriptionRow
                anchors { left: parent.left; right: parent.right }
                spacing: PlatformStyle.paddingSmall
                height: text.font.pixelSize

                Label {
                    color: "#666"
                    text: getSecondRow()
                    width: parent.width-parent.spacing-dateText.paintedWidth
                    horizontalAlignment: Text.AlignJustify
                    font.pixelSize: parent.height
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    clip: true
                    visible: !progressEnabled
                }
                Text {
                    id: dateText
                    text: Qt.formatDateTime(date, "~hh:mm")
                    color: "#666"
                    font { pixelSize: parent.height; italic: true }
                    horizontalAlignment: Text.AlignRight
                    visible: !progressEnabled
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: makeAction()
        }
    }
    Item { height: 1; width: wrapper.width; anchors.right: parent.right; }
}
