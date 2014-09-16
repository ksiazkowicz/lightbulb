/********************************************************************

qml/Dialogs/MucQueryDialog.qml
-- dialog in which you can write stuff

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
    id: queryMuc
    platformInverted: main.platformInverted
    property int actionType: 0
    // available action types
    // 0 - new subject
    // 1 - kick reason
    // 2 - ban reason

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]
    property string accountId
    property string contactJid
    property string userJid
    property string textFieldCrap: actionType == 0 ? xmppConnectivity.useClient(accountId).getMUCSubject(contactJid) : ""

    // Code for dynamic load
    Component.onCompleted: {
        open();
        main.splitscreenY = 0;
        isCreated = true
    }
    property bool isCreated: false

    onStatusChanged: if (isCreated && queryMuc.status === DialogStatus.Closed) queryMuc.destroy()

    onButtonClicked: {
        if (index === 0) {
            switch (actionType) {
            case 0: xmppConnectivity.useClient(accountId).setMUCSubject(contactJid,textArea.text); break;
            case 1: xmppConnectivity.useClient(accountId).kickMUCUser(contactJid,userJid,textArea.text); break;
            case 2: xmppConnectivity.useClient(accountId).banMUCUser(contactJid,userJid,textArea.text); break;
            }
        }
    }

    height: 300

    content: TextArea {
        id: textArea
        anchors { fill: parent; margins: platformStyle.paddingMedium; }
        text: textFieldCrap
    }
}
