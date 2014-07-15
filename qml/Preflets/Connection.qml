/********************************************************************

qml/Preflets/Connection.qml
-- Preflet with connection options

Copyright (c) 2013-2014 Maciej Janiszewski

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

Item {
    height: content.height

    Column {
        id: content
        spacing: 5
        width: parent.width
        anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
        CheckBox {
            id: cbNeedReconnect
            text: qsTr("Reconnect on error")
            anchors { left: parent.left; leftMargin: 10; }
            checked: settings.gBool("behavior", "reconnectOnError")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                console.log("Reconnect on error: checked="+checked)
                settings.sBool(checked,"behavior", "reconnectOnError")
            }
        }
        Text {
            text: qsTr("Keep alive interval (secs)")
            font.pixelSize: 20
            font.bold: true
            color: vars.textColor
            anchors { left: parent.left; leftMargin: 10; }
        }
        TextField {
            id: tiKeepAlive
            anchors.horizontalCenter: parent.horizontalCenter
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            width: content.width-20
            height: 50
            Component.onCompleted: {
                tiKeepAlive.text = settings.gInt("behavior", "keepAliveInterval")
            }
            onActiveFocusChanged: {
                main.splitscreenY = 0
            }

            onTextChanged: {
                var interval = parseInt(tiKeepAlive.text)
                xmppConnectivity.client.keepAlive = interval
                settings.sInt(interval,"behavior", "keepAliveInterval")
            }
        }

        SelectionListItem {
            id: iapSelection
            platformInverted: main.platformInverted
            subTitle: settings.gInt("behavior","internetAccessPoint") >= 1
                      ? network.getIAPNameByID(settings.gInt("behavior","internetAccessPoint"))
                      : "Use default"
            anchors { left: parent.left; right: parent.right }
            title: "Internet Access Point"

            onClicked: dialog.create("qrc:/dialogs/AccessPointSelector")
            Connections {
                target: network
                onCurrentIAPChanged: {
                    iapSelection.subTitle = settings.gInt("behavior","internetAccessPoint") >= 1
                              ? network.getIAPNameByID(settings.gInt("behavior","internetAccessPoint"))
                              : "Use default"
                }
            }

        }

    }
}

