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
                Image {
                    id: imgPresence
                    source: xmppConnectivity.getPropertyByJid(account,"presence",jid)
                    sourceSize.height: 24
                    sourceSize.width: 24
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                    height: 24
                    width: 24
                }
                Text {
                    anchors { verticalCenter: parent.verticalCenter; left: imgPresence.right; right: parent.right; rightMargin: 5; leftMargin: 10 }
                    property int unreadMsg: parseInt(xmppConnectivity.getPropertyByJid(account,"unreadMsg",jid))
                    text: unreadMsg > 0 ? "[" + xmppConnectivity.getPropertyByJid(account,"unreadMsg",jid) + "] " + name : name
                    font.pixelSize: 18
                    clip: true
                    color: vars.textColor
                }
                states: State {
                    name: "Current"
                    when: jid == xmppConnectivity.chatJid
                    PropertyChanges { target: wrapper; gradient: gr_press }
                }
                MouseArea {
                    id: maAccItem
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; right: closeBtn.left }
                    onClicked: {
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
                ToolButton {
                    id: closeBtn;
                    iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    onClicked: {
                        xmppConnectivity.client.closeChat(jid)
                        xmppConnectivity.client.resetUnreadMessages(jid)
                        if (jid == xmppConnectivity.chatJid) {
                            vars.isChatInProgress = false
                            xmppConnectivity.chatJid = ""
                            statusBarText.text = "Contacts"
                            pageStack.pop();
                        }
                    }
                    scale: 0.7
                    smooth: true
                }
            }
         }
        model: xmppConnectivity.chats
    }

    Component.onCompleted: open()
}

