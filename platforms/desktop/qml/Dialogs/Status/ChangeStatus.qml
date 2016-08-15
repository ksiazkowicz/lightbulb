/********************************************************************

qml/Dialogs/ChangeStatus.qml
-- dialog in which you can change your status

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

import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import lightbulb 1.0
import "../../Components"


Window {
    id: statusDialog
    Component.onCompleted: selectionDialog.currentIndex = vars.lastUsedStatus
    visible: true
    modality: Qt.ApplicationModal
    width: main.width - PlatformStyle.paddingMedium*2
    height: flickable.height
    x: main.x + PlatformStyle.paddingMedium

    property bool storeStatus: settings.gBool("behavior","storeLastStatus")
    property string accountId: ""

    Flickable {
        id: flickable
        height: Math.min(column.height+PlatformStyle.paddingMedium, 400)
        width: parent.width - 2*PlatformStyle.paddingLarge
        contentHeight: column.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        interactive: contentHeight > height

        onInteractiveChanged: contentY = wrapperTextEdit.y

        anchors { horizontalCenter: parent.horizontalCenter; topMargin: PlatformStyle.paddingMedium; bottomMargin: PlatformStyle.paddingMedium }
        Column {
            id: column
            width: parent.width
            height: column.implicitHeight

            spacing: 5

            Rectangle { color: "transparent"; height: PlatformStyle.paddingSmall; width: 1 }

            Label {
                anchors { margins: PlatformStyle.paddingMedium }
                text: "ZMIEŃ STATUS"
                font.bold: true
            }

            ComboBox {
                id: selectionDialog
                anchors { left: parent.left; right: parent.right }
                model: ["Online", "Chatty", "Away", "Extended Away", "Do not disturb", "Offline"]
            }

            TextField {
                id: wrapperTextEdit
                anchors {left: parent.left; right: parent.right }
                placeholderText: qsTr("Status text")
                text: vars.lastStatus
            }

            GridLayout {
                anchors {left: parent.left; right: parent.right }
                columns: 2
                Button {
                    text: "OK"
                    Layout.fillWidth: true
                    onClicked: {
                        var ret = ""

                        // convert index to status
                        switch (selectionDialog.currentIndex) {
                        case 0: ret = XmppClient.Online; break;
                        case 1: ret = XmppClient.Chat; break;
                        case 2: ret = XmppClient.Away; break;
                        case 3: ret = XmppClient.XA; break;
                        case 4: ret = XmppClient.DND; break;
                        case 5: ret = XmppClient.Offline; break;
                        default: ret = XmppClient.Unknown; break;
                        }

                        // reopen connection if it's not available
                        //if (!network.connectionStatus)
                        //    network.openConnection()

                        xmppConnectivity.useClient(accountId).connectToXmppServer()
                        //xmppConnectivity.useClient(accountId).setPresence(ret, wrapperTextEdit.text)

                        vars.lastUsedStatus = selectionDialog.currentIndex

                        vars.lastStatus = wrapperTextEdit.text

                        if (storeStatus) settings.sStr(wrapperTextEdit.text,"behavior","lastStatusText")
                        else settings.sStr("","behavior","lastStatusText")

                        statusDialog.destroy()
                    }
                }
                Button {
                    text: "Poniechaj"
                    Layout.fillWidth: true
                    onClicked: statusDialog.destroy()
                }
            }
        }
    }
}
