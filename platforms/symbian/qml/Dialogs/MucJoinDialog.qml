/********************************************************************

qml/Dialogs/MucJoinDialog.qml
-- dialog in which you can specify MUC jid and your nick

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

CommonDialog {
    id: joinMuc
    titleText: qsTr("Join Multi-User Chat")
    platformInverted: main.platformInverted

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]
    property string accountId;
    property string mucJid;

    // Code for dynamic load
    Component.onCompleted: {
        open();
        main.splitscreenY = 0;
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: if (isCreated && joinMuc.status === DialogStatus.Closed) joinMuc.destroy()

    onButtonClicked: {
        if ((index === 0) && ( jidField.text != "" ) && ( nickField.text != "" )) {
            xmppConnectivity.useClient(accountId).joinMUCRoom(jidField.text,nickField.text,passField.text)
        }
    }

    content: Flickable {
        id: flickable
        height: Math.min(column.height +platformStyle.paddingMedium, platformContentMaximumHeight)
        width: parent.width - 2*platformStyle.paddingLarge
        contentHeight: column.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        interactive: contentHeight > height
        onHeightChanged: {
            if (jidField.focus && interactive) contentY = jidField.y-(platformStyle.fontSizeSmall+platformStyle.paddingMedium)
            if (nickField.focus && interactive) contentY = nickField.y-(platformStyle.fontSizeSmall+platformStyle.paddingMedium)
            if (passField.focus && interactive) contentY = flickable.contentHeight
        }

        anchors { horizontalCenter: parent.horizontalCenter; topMargin: platformStyle.paddingMedium }
        Column {
            id: column
            spacing: platformStyle.paddingMedium
            height: content.height
            width: parent.width

            Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Room JID:"); color: main.textColor }
            TextField {
                id: jidField
                text: mucJid
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("room@conference.example.com")
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Your nick:"); color: main.textColor }
            TextField {
                id: nickField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Nick")
                text: vars.defaultMUCNick != "false" ? vars.defaultMUCNick : ""
            }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Room password (optional):"); color: main.textColor }
            TextField {
                id: passField
                anchors { left: parent.left; right: parent.right }
                echoMode: TextInput.Password
            }
        }
    }
}
