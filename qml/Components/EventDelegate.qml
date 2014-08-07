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
    boundsBehavior: Flickable.DragOverBounds
    contentWidth: wrapper.width *2

    function isActionPossible() {
        switch (type) {
        case 32: return true;
        case 34: return true;
        case 35: return true;
        default: return false;
        }
    }

    function getIcon() {
        switch (type) {
        case 32: return xmppConnectivity.getAvatarByJid(bareJid); // unread message
        case 33: // connection state change
        case 34: // subscription request
        case 35: // muc invite
        case 36: // attention request
        case 37: // fav user status change
        case 38: // app update
        default: return "";
        }
    }

    onContentXChanged: {
        wrapper.opacity = 1-(contentX/(wrapper.width))
        if (wrapper.opacity <= 0)
            xmppConnectivity.events.removeEvent(bareJid,accountID,type)
    }

    Item {
        id: wrapper
        height: 56
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
                    anchors.fill: parent
                    sourceSize { height: height; width: width }
                    source: "qrc:/unread-count"
                    visible: (type == 32)

                    Text {
                        visible: parent.visible
                        width: 20; height: width
                        color: "#ffffff"
                        text: parent.visible ? xmppConnectivity.getUnreadCount(accountID,bareJid)+1 : ""
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors { right: parent.right; bottom: parent.bottom }
                        font.pixelSize: width*0.72
                    }
                }
            }
        Column {
            anchors { left: icon.right; leftMargin: 10; verticalCenter: notification.verticalCenter }
                Text {
                    color: vars.textColor
                    textFormat: Text.PlainText
                    width: mainPage.width - 25 - 90
                    maximumLineCount: 1
                    font.pixelSize: 20
                    text: description
                    wrapMode: Text.WrapAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    color: "#b9b9b9"
                    text: name
                    anchors { left: parent.left; right: parent.right }
                    horizontalAlignment: Text.AlignJustify
                    font.pixelSize: 20
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }
        MouseArea {
            id: maAccItem
            anchors { fill: parent }
            onClicked: {
                switch (type) {
                    case 32:
                        main.openChat(accountID,name,bareJid,xmppConnectivity.getChatType(accountID,bareJid));
                        break;
                }
            }
        }
    }
    Item { height: 1; width: wrapper.width; anchors.right: parent.right; }
}
