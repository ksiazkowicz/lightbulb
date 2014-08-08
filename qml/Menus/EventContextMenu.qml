/********************************************************************

qml/Menus/EventContextMenu.qml
-- contains event context menu, which appears on tap

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

ContextMenu {
    id: eventContextMenu
    platformInverted: main.platformInverted
    property string bareJid
    property string accountId
    property string name
    property int type

    MenuLayout {
        MenuItem {
            platformInverted: main.platformInverted
            text: type == 32 ? "Open chat" : ""
            onClicked: main.openChat(accountId,name,bareJid,xmppConnectivity.getChatType(accountId,bareJid));
        }
        MenuItem {
            text: type == 32 ? "Mark as read" : ""
            platformInverted: main.platformInverted
            onClicked: xmppConnectivity.resetUnreadMessages(accountId,bareJid)
        }
    }

    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && eventContextMenu.status === DialogStatus.Closed) { eventContextMenu.destroy() } }
}
