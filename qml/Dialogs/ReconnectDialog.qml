/********************************************************************

qml/Dialogs/ReconnectDialog.qml
-- dialog which appears every time connection breaks down and
-- attempts to restore it after 10 second delay

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
import lightbulb 1.0

CommonDialog {
    id: reconDialog
    titleText: qsTr("Connection lost")
    property int timeLeft: 10
    platformInverted: main.platformInverted

    buttonTexts: [qsTr("Cancel")]

    Component.onCompleted: open()

    onButtonClicked: {
        timeLeftTimer.running = false
    }



    Timer {
        id: timeLeftTimer
        running: true; repeat: true
        onTriggered: {
            if (timeLeft > 0) {
                timeLeft--
            } else {
                var ret = ""

                switch (main.lastUsedStatus) {
                    case 0: ret = XmppClient.Online; break;
                    case 1: ret = XmppClient.Chat; break;
                    case 2: ret = XmppClient.Away; break;
                    case 3: ret = XmppClient.XA; break;
                    case 4: ret = XmppClient.DND; break;
                    case 5: ret = XmppClient.Offline; break;
                    default: ret = XmppClient.Unknown; break;
                }
                xmppConnectivity.client.setMyPresence( ret, main.laststatus )
                reconDialog.close()
                running = false
            }
        }
    }

    content: Text {
        color: vars.textColor
        id: reconLabel;
        wrapMode: Text.Wrap;
        anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin:10; verticalCenter: parent.verticalCenter }
        text: qsTr("Attempting to reconnect in ")+timeLeft+qsTr(" seconds.")
    }
}
