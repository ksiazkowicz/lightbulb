/********************************************************************

qml/Dialogs/Chats.qml
-- Dialog for switching between chats

Copyright (c) 2013 Maciej Janiszewski

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
import com.nokia.symbian 1.1

/*SelectionDialog {
    titleText: qsTr("Chats")
    selectedIndex: -1
    platformInverted: main.platformInverted
    privateCloseIcon: true
    model: xmppConnectivity.client.chats

    Component.onCompleted: open()

    onSelectedIndexChanged: {
        if (selectedIndex > -1 && xmppConnectivity.chatJid != xmppConnectivity.client.getPropertyByChatID(selectedIndex, "jid")) {
            xmppConnectivity.chatJid = xmppConnectivity.client.getPropertyByChatID(selectedIndex, "jid")
            vars.contactName = xmppConnectivity.client.getPropertyByChatID(selectedIndex, "name")
            vars.globalUnreadCount = vars.globalUnreadCount - parseInt(xmppConnectivity.client.getPropertyByChatID(selectedIndex, "unreadMsg"))
            main.openChat()
        }
    }
}*/

CommonDialog {
    privateCloseIcon: true
    titleText: qsTr("Chats")

    platformInverted: main.platformInverted
    height: 250

    content: ListView {
        id: listViewChats
        clip: true
        anchors { fill: parent }
        delegate: Component {
            Rectangle {
                id: wrapper
                clip: true
                width: parent.width
                height: 48
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
                /*Image {
                    id: imgPresence
                    source: rosterLayoutAvatar ? xmppConnectivity.client.getAvatarByJid(jid) : presence
                    sourceSize.height: rosterItemHeight-4
                    sourceSize.width: rosterItemHeight-4
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                    height: rosterItemHeight-4
                    width: rosterItemHeight-4
                    Image {
                        id: imgUnreadMsg
                        source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                        sourceSize.height: wrapper.height
                        sourceSize.width: wrapper.height
                        smooth: true
                        visible: markUnread ? unreadMsg != 0 : false
                        anchors.centerIn: parent
                        opacity: unreadMsg != 0 ? 1 : 0
                        Image {
                            id: imgUnreadCount
                            source: "qrc:/unread-count"
                            sourceSize.height: wrapper.height
                            sourceSize.width: wrapper.height
                            smooth: true
                            visible: showUnreadCount ? unreadMsg != 0 : false
                            anchors.centerIn: parent
                            opacity: unreadMsg != 0 ? 1 : 0
                        }
                        Rectangle {
                            color: "transparent"
                            width: wrapper.height * 0.30
                            height: width
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: showUnreadCount ? unreadMsg != 0 : false
                            Text {
                                id: txtUnreadMsg
                                text: unreadMsg
                                font.pixelSize: 0.72*parent.width
                                anchors.centerIn: parent
                                z: 1
                                color: "white"
                            }
                        }
                    }
                }*/
                Text {
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: 5; leftMargin: 5 }
                    text: name
                    font.pixelSize: 18
                    clip: true
                    color: vars.textColor
                }
                states: State {
                    name: "Current"
                    when: wrapper.ListView.isCurrentItem
                    PropertyChanges { target: wrapper; gradient: gr_press }
                }
                MouseArea {
                    id: maAccItem
                    anchors.fill: parent
                    onClicked: {
                        wrapper.ListView.view.currentIndex = index
                        if (xmppConnectivity.currentAccount != account) xmppConnectivity.currentAccount = account
                        if (index > -1 && xmppConnectivity.chatJid != jid) {
                            xmppConnectivity.chatJid = jid
                            vars.contactName = name
                            vars.globalUnreadCount = vars.globalUnreadCount - parseInt(xmppConnectivity.client.getPropertyByJid(jid, "unreadMsg"))
                            main.openChat()
                        }
                        close()
                    }
                }
            }
         }
        model: xmppConnectivity.chats
    }

    Component.onCompleted: open()
}

