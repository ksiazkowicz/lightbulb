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

    // Code for dynamic load
    Component.onCompleted: {
        open();
        main.splitscreenY = 0;
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: if (isCreated && joinMuc.status === DialogStatus.Closed) joinMuc.destroy()

    onButtonClicked: {
        if ((index === 0) && ( jidField.text != "" ) && ( nickField.text != "" )) {
           xmppConnectivity.joinMUC(accountId,jidField.text,nickField.text)
        }
    }

    content: Column {
        width: parent.width-20
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: jidLabel;
            color: vars.textColor
            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
            text: qsTr("Room JID:");
        }
        TextField {
            id: jidField
            height: 50
            anchors { left: parent.left; right: parent.right }
            placeholderText: qsTr("room@conference.example.com")
        }
        Text {
            id: nickLabel
            color: vars.textColor
            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
            text: qsTr("Your nick:");
        }
        TextField {
            id: nickField
            height: 50
            anchors { left: parent.left; right: parent.right }
            placeholderText: qsTr("Nick")
        }
    }
}
