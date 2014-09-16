/********************************************************************

qml/Components/ChatDelegate.qml
-- delegate for chat on Events page

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
    height: 56
    flickableDirection: Flickable.HorizontalFlick
    boundsBehavior: Flickable.DragOverBounds
    contentWidth: wrapper.width *2

    onContentXChanged: {
        wrapper.opacity = 1-(contentX/(wrapper.width))
        if (wrapper.opacity <= 0)
            xmppConnectivity.closeChat(account,jid)
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
        height: 56
        width: flick.width
        anchors.left: parent.left;
        Rectangle {
            anchors.fill: parent
            z: -1
            gradient: gr_free

            Gradient {
                id: gr_free
                GradientStop { id: gr1; position: 0; color: "transparent" }
                GradientStop { id: gr3; position: 1; color: "transparent" }
            }
            Gradient {
                id: gr_press
                GradientStop { position: 0; color: "#1C87DD" }
                GradientStop { position: 1; color: "#51A8FB" }
            }
        }
        Image {
            id: avatarIcon
            anchors { left: wrapper.left; verticalCenter: parent.verticalCenter }
            width: 48
            height: 48
            smooth: true
            source: chatType == 3 ? "qrc:/muc" : xmppConnectivity.getAvatarByJid(jid)
            Rectangle { anchors.fill: parent; color: "black"; z: -1 }
            Image {
                anchors.fill: parent
                sourceSize { width: 48; height: 48 }
                smooth: true
                source: main.platformInverted ? "qrc:/avatar-mask_inverse" : "qrc:/avatar-mask"
                visible: chatType !== 3
            }
            opacity: wrapper.opacity

            Connections {
                target: xmppConnectivity
                onAvatarUpdatedForJid: if (bareJid == jid) avatarIcon.source = xmppConnectivity.getAvatarByJid(jid)
            }
        }
        Image {
            id: imgPresence
            source: chatType !== 3 ? xmppConnectivity.getPropertyByJid(account,"presence",jid) : ""
            sourceSize { height: 16; width: 16 }
            anchors { verticalCenter: parent.verticalCenter; right: wrapper.right; rightMargin: 5 }
            height: chatType !== 3 ? 16 : 0
            width: chatType !== 3 ? 16 : 0
            opacity: wrapper.opacity
        }
        Text {
            anchors { verticalCenter: parent.verticalCenter; left: avatarIcon.right; right: wrapper.right; leftMargin: 10 }
            text: (name === "" ? jid : name)
            font.pixelSize: 22
            clip: true
            color: main.textColor
            elide: Text.ElideRight
            opacity: wrapper.opacity
        }
        states: State {
            name: "Current"
            PropertyChanges { target: chatElement; gradient: gr_press }
        }
        MouseArea {
            id: maAccItem
            anchors { fill: parent }
            onClicked: main.openChat(account,name,jid,chatType)
        }

        Connections {
            target: xmppConnectivity
            onXmppPresenceChanged: {
                if (m_accountId == account && bareJid == jid)
                    imgPresence.source = picStatus
            }
        }
    }
    Item { height: 1; width: wrapper.width; anchors.right: parent.right; }
}
