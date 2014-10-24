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
    titleText: flickable.interactive ? "" : qsTr("Add contact")
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
    onButtonClicked: if (index === 0 && addName.text != "" && addJid.text != "") {
                         var result = xmppConnectivity.useClient(accountId).addContact(addJid.text, addName.text, "", true)
                         if (result)
                             avkon.showPopup("Contact "+addName.text,"added to contact list")
                         else avkon.showPopup("Error occured","while adding contact to list")
                     }

    content: Flickable {
        id: flickable
        height: Math.min(column.height +platformStyle.paddingMedium, platformContentMaximumHeight)
        width: parent.width - 2*platformStyle.paddingLarge
        contentHeight: column.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        interactive: contentHeight > height
        onInteractiveChanged: {
            if (addName.focus) flickable.contentY = addName.y-(platformStyle.fontSizeSmall+platformStyle.paddingMedium)
            if (addJid.focus) flickable.contentY = addJid.y-(platformStyle.fontSizeSmall+platformStyle.paddingMedium)
        }

        anchors { horizontalCenter: parent.horizontalCenter; topMargin: platformStyle.paddingMedium; bottomMargin: platformStyle.paddingMedium }
        Column {
            id: column
            spacing: platformStyle.paddingSmall
            height: content.height
            width: parent.width

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
}
