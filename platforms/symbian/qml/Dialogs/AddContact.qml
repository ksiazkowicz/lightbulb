/********************************************************************

qml/Dialogs/AddContact.qml
-- Dialog for adding contacts

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
    id: addContact
    titleText: qsTr("Add contact")
    property string accountId;
    property string bareJid

    platformInverted: main.platformInverted
    buttonTexts: [qsTr("OK"), qsTr("Cancel")]
    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: if (isCreated && addContact.status === DialogStatus.Closed) addContact.destroy()
    onButtonClicked: if (index === 0 && addName.text != "" && addJid.text != "") xmppConnectivity.useClient(accountId).addContact(addJid.text, addName.text, "", true)

    content: Column {
            spacing: platformStyle.paddingSmall
            anchors { left: parent.left; right: parent.right; margins: platformStyle.paddingSmall }

            Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Contact name:"); color: main.textColor }
            TextField {
                id: addName
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Name")
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "JID:"; color: main.textColor}
            TextField {
                id: addJid
                text: bareJid
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("example@server.com")
            }
        }
}
