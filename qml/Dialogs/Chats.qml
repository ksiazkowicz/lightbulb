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
import com.nokia.extras 1.1

SelectionDialog {
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
}
