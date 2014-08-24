/********************************************************************

qml/Dialogs/AccountSwitcher.qml
-- dialog in which you can switch between accounts

Copyright (c) 2013-2014 Maciej Janiszewski

This file is part of Lightbulb and was derived from MeegIM.

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
    id: accountSwitcher
    privateCloseIcon: true
    titleText: qsTr("Select context")
    height: 320

    platformInverted: main.platformInverted

    content: ListView {
        id: listViewAccounts
        clip: true
        anchors { fill: parent }

        delegate: Component {
            Rectangle {
                id: wrapper
                clip: true
                width: parent.width
                height: 48
                gradient: gr_free
                Gradient {
                    id: gr_free
                    GradientStop { id: gr1; position: 0; color: "transparent" }
                    GradientStop { id: gr3; position: 1; color: "transparent" }
                }
                Gradient {
                    id: gr_press
                    GradientStop { position: 0; color: "#1C87DD" }
                    GradientStop { position: 1; color: "#51A8FB" }
                }
                Image {
                    id: imgPresence
                    source: "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
                    sourceSize.height: 24
                    sourceSize.width: 24
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                    height: 24
                    width: 24
                }
                Text {
                    anchors { verticalCenter: parent.verticalCenter; left: imgPresence.right; right: parent.right; rightMargin: 10; leftMargin: 10 }
                    text: xmppConnectivity.getAccountName(accGRID)
                    font.pixelSize: 18
                    clip: true
                    color: main.textColor
                }
                Image {
                    id: imgAccount
                    source: "qrc:/accounts/" + accIcon
                    sourceSize.height: 24
                    sourceSize.width: 24
                    anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 10 }
                    height: 24
                    width: 24
                }
                states: State {
                    name: "Current"
                    when: vars.context == accGRID
                    PropertyChanges { target: wrapper; gradient: gr_press }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wrapper.ListView.view.currentIndex = index
                        vars.context = accGRID
                        close()
                    }
                }
            }
         }
        model: settings.accounts
    }


    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: if (isCreated && accountSwitcher.status === DialogStatus.Closed) {
                         vars.awaitingContext = false;
                         accountSwitcher.destroy()
                     }
}
