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

import QtQuick 1.1
import lightbulb 1.0

Flickable {
    id: flick
    height: 64
    flickableDirection: Flickable.HorizontalFlick
    flickDeceleration: 10
    boundsBehavior: Flickable.DragOverBounds
    contentWidth: wrapper.width *2

    function getIcon() {
        switch (type) {
        case 32: { if (xmppConnectivity.getChatType(accountID,bareJid) == 3) return "qrc:/muc"; else return xmppConnectivity.getAvatarByJid(bareJid); } // unread message
        case 33: return "qrc:/accounts/" + xmppConnectivity.getAccountIcon(accountID); // connection state change
        case 34: // subscription request
        case 35: // muc invite
        case 36: return "qrc:/attention"; // attention request
        case 37: // fav user status change
        case 38: return "qrc:/updateIcon"; // app update
        case 39: return "qrc:/errorIcon"; // connection error
        default: return "";
        }
    }

    function makeAction() {
        switch (type) {
        case 32: main.openChat(accountID,name,bareJid,xmppConnectivity.getChatType(accountID,bareJid)); break;
        case 34: { xmppConnectivity.useClient(accountID).acceptSubscription(bareJid); dialog.createWithProperties("qrc:/dialogs/Contact/Add",{"accountId": accountID, "bareJid": bareJid}); xmppConnectivity.events.removeEvent(bareJid,accountID,type); break; }
        case 35: return true;
        case 38: if (updater.isUpdateAvailable) dialog.createWithProperties("qrc:/menus/UrlContext", {"url": updater.updateUrl}); break;
        default: return false;
        }
    }

    function makeAltAction() {
        switch (type) {
        case 32: xmppConnectivity.resetUnreadMessages(accountID,bareJid); break;
        case 34: xmppConnectivity.useClient(accountID).rejectSubscription(bareJid); return true;
        case 35: return true;
        default: return false;
        }
    }

    function getMiniIcon() {
        // used if type == 33 to determine which icon should be displayed
        if (description.substring(0,7) == "Current") return ("qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accountID)));
        return "";
    }

    onContentXChanged: {
        wrapper.opacity = 1-(contentX/(wrapper.width))
        if (wrapper.opacity <= 0) {
            xmppConnectivity.events.removeEvent(bareJid,accountID,type)
            makeAltAction()
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

                Rectangle { anchors.fill: parent; color: (type == 32) ? "black" : "transparent"; z: -1 }
                Image {
                    anchors.fill: parent
                    smooth: true
                    source: main.platformInverted ? "qrc:/avatar-mask_inverse" : "qrc:/avatar-mask"
                    sourceSize { width: 64; height: 64 }
                    visible: (type == 32)
                }
                Image {
                    id: mark
                    z: 1
                    anchors { bottom: parent.bottom; right: parent.right }
                    width: type == 32 ? 64 : 24
                    height: width
                    sourceSize { height: height; width: width }
                    source: type == 32 ? "qrc:/unread-count" : type == 33 ? getMiniIcon() : ""
                    visible: (type == 32) || (type == 33)

                    Text {
                        visible: type == 32
                        width: 20; height: width
                        color: "#ffffff"
                        text: type == 32 ? xmppConnectivity.getUnreadCount(accountID,bareJid)+1 : ""
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors { right: parent.right; bottom: parent.bottom }
                        font.pixelSize: width*0.72
                    }
                }
            }
        Column {
            anchors { left: icon.right; leftMargin: platformStyle.paddingSmall; right: wrapper.right; rightMargin: platformStyle.paddingSmall; verticalCenter: wrapper.verticalCenter }
            height: text.height + platformStyle.paddingSmall + descriptionRow.height
                Text {
                    id: text
                    color: main.textColor
                    width: mainPage.width - 25 - 90
                    maximumLineCount: 2
                    font.pixelSize: 18
                    text: description
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                }
                Row {
                    id: descriptionRow
                    anchors { left: parent.left; right: parent.right }
                    spacing: platformStyle.paddingSmall
                    height: text.font.pixelSize
                    Text {
                        color: "#b9b9b9"
                        text: name
                        width: parent.width-parent.spacing-dateText.paintedWidth
                        horizontalAlignment: Text.AlignJustify
                        font.pixelSize: parent.height
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        clip: true
                    }
                    Text {
                        id: dateText
                        text: Qt.formatDateTime(date, "~hh:mm")
                        color: "#a9a9a9"
                        font.pixelSize: parent.height
                        horizontalAlignment: Text.AlignRight
                        font.italic: true
                    }
                }
        }
        MouseArea {
            id: maAccItem
            anchors { fill: parent }
            onClicked: makeAction()
        }
    }
    Item { height: 1; width: wrapper.width; anchors.right: parent.right; }
}
