/********************************************************************

qml/Menus/MucMenu.qml
-- contains a menu with MUC-specific options

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
import com.nokia.symbian 1.1

Menu {
    id: mucOptions
    platformInverted: main.platformInverted

    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false
    property string contactJid
    property string accountId
    property bool hasModPermissions
    property bool hasOwnerPermissions

    onStatusChanged: { if (isCreated && mucOptions.status === DialogStatus.Closed) { mucOptions.destroy() } }
    // define the items in the menu and corresponding actions
    content: MenuLayout {
        MenuItem {
            text: qsTr("Participants")
            enabled: false
            platformInverted: main.platformInverted
            onClicked: dialog.create("qrc:/dialogs/MUC/Participants")
        }
        MenuItem {
            text: qsTr("Leave room")
            enabled: false
            platformInverted: main.platformInverted
            onClicked: {
                pageStack.pop()
                xmppConnectivity.closeChat(accountId,contactJid)
                xmppConnectivity.leaveMUCRoom(accountId,contactJid)
                xmppConnectivity.resetUnreadMessages(accountId,contactJid)
                xmppConnectivity.chatJid = ""
            }
        }
        MenuItem {
            text: qsTr("Change subject")
            enabled: hasModPermissions
            platformInverted: main.platformInverted
        }
        MenuItem {
            text: qsTr("Bookmark this room")
            enabled: false
            platformInverted: main.platformInverted
        }
    }
}
