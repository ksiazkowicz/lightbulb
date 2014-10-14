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

import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0

CommonDialog {
    id: statusDialog
    titleText: qsTr("Set status")
    buttonTexts: ["OK"]
    privateCloseIcon: true

    property bool storeStatus: settings.gBool("behavior","storeLastStatus")
    property string accountId: ""

    // facebook is retarded
    property bool   isFacebook: xmppConnectivity.useClient(accountId).isFacebook()

    platformInverted: main.platformInverted

    // Code for dynamic load
    Component.onCompleted: {
        selectionDialog.selectedIndex = vars.lastUsedStatus
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: if (isCreated && statusDialog.status === DialogStatus.Closed) statusDialog.destroy()

    onButtonClicked: {
        var ret = ""

        switch (selectionDialog.selectedIndex) {
            case 0: ret = XmppClient.Online; break;
            case 1: ret = XmppClient.Chat; break;
            case 2: ret = XmppClient.Away; break;
            case 3: ret = XmppClient.XA; break;
            case 4: ret = XmppClient.DND; break;
            case 5: ret = XmppClient.Offline; break;
            default: ret = XmppClient.Unknown; break;
        }

        if (!network.connectionStatus)
            network.openConnection()

        xmppConnectivity.useClient(accountId).setPresence(ret, wrapperTextEdit.text)

        vars.lastStatus = wrapperTextEdit.text
        vars.lastUsedStatus = selectionDialog.selectedIndex

        if (storeStatus) settings.sStr(wrapperTextEdit.text,"behavior","lastStatusText")
        else settings.sStr("","behavior","lastStatusText")
    }

    content: Column {
        width: parent.width-20
        height: content.height
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 5

        SelectionListItem {
            id: statusSelection
            platformInverted: main.platformInverted
            subTitle: selectionDialog.selectedIndex >= 0
                      ? selectionDialog.model.get(selectionDialog.selectedIndex).name
                      : "Online, Chatty, Away..."
            anchors { left: parent.left; right: parent.right }
            title: "Status"

            onClicked: selectionDialog.open()

            SelectionDialog {
                id: selectionDialog
                titleText: "Available options"
                selectedIndex: -1
                platformInverted: main.platformInverted
                model: ListModel {
                    ListElement { name: "Online" }
                    ListElement { name: "Chatty" }
                    ListElement { name: "Away" }
                    ListElement { name: "Extended Away" }
                    ListElement { name: "Do not disturb" }
                    ListElement { name: "Offline" }
                }
            }
        }

        TextField {
            id: wrapperTextEdit
            height: !isFacebook ? 50 : 0
            enabled: !isFacebook
            anchors {left: parent.left; right: parent.right }
            placeholderText: qsTr("Status text")
            text: !isFacebook ? vars.lastStatus : ""
        }
    }
}
