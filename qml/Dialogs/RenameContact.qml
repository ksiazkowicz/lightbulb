/********************************************************************

qml/Dialogs/RenameContact.qml
-- dialog in which you can type new name for your contact

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
    titleText: qsTr("Rename contact")
    platformInverted: main.platformInverted

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]

    // Code for dynamic load
    Component.onCompleted: {
        open();
        main.splitscreenY = 0;
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && status === DialogStatus.Closed) { destroy() } }

    onButtonClicked: {
        if ((index === 0) && ( newNameText.text != "" )) {
           xmppConnectivity.client.renameContact( xmppConnectivity.chatJid, newNameText.text )
        }
    }

    content: Rectangle {
        width: parent.width-20
        height: 100
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Text {
            id: queryLabel;
            color: vars.textColor
            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 10 }
            text: qsTr("Choose new name:");
        }
        TextField {
            id: newNameText
            text: dialogName
            height: 50
            anchors { bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right }
            placeholderText: qsTr("New name")
        }
    }
}
