/********************************************************************

qml/Dialogs/ServicesDialog.qml
-- dialog in which you can specify for which JID you want to check services out

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
    id: servDialog
    titleText: qsTr("Server address")
    platformInverted: main.platformInverted

    buttonTexts: [qsTr("OK"), qsTr("Cancel")]
    property string accountId;

    // Code for dynamic load
    Component.onCompleted: {
        open();
        main.splitscreenY = 0;
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: if (isCreated && servDialog.status === DialogStatus.Closed) servDialog.destroy()

    onButtonClicked: {
        if ((index === 0) && ( jidField.text != "" )) {
            xmppConnectivity.useClient(accountId).askServer(jidField.text)
            main.pageStack.push("qrc:/pages/Services",{"accountId": accountId,"bareJid":jidField.text})
        }
    }

    content: TextField {
            id: jidField
            width: parent.width - 2*platformStyle.paddingLarge
            text: xmppConnectivity.useClient(accountId).getHost()
            anchors { centerIn: parent }
        }
}
