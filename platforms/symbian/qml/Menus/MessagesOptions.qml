/********************************************************************

qml/Menus/MessagesOptions.qml
-- contains messages options menu

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
    id: msgOptions
    platformInverted: main.platformInverted

    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false
    property string contactJid
    property string contactResource
    property string accountId
    property bool isFacebook: xmppConnectivity.useClient(accountId).isFacebook()

    onStatusChanged: { if (isCreated && msgOptions.status === DialogStatus.Closed) { msgOptions.destroy() } }
    // define the items in the menu and corresponding actions
    content: MenuLayout {
        MenuItem {
            text: qsTr("Set resource")
            platformInverted: main.platformInverted
            onClicked: dialog.create("qrc:/dialogs/Resources")
            enabled: !isFacebook
        }
        MenuItem {
            text: qsTr("Request attention")
            platformInverted: main.platformInverted
            onClicked: xmppConnectivity.useClient(accountId).requestAttention(contactJid,contactResource)
            enabled: !isFacebook
        }

        MenuItem {
            text: "Close chat"
            platformInverted: main.platformInverted
            onClicked: {
                pageStack.pop()
                xmppConnectivity.closeChat(accountId,contactJid)
            }
        }
    }
}
