/********************************************************************

qml/Dialogs/ResourcesDialog.qml
-- Dialog for switching between resources

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
import "../../Components"

CommonDialog {
    id: dlgParticipants
    titleText: qsTr("Participants")
    privateCloseIcon: true
    platformInverted: main.platformInverted

    property string contactJid
    property string accountId
    property bool kick
    property bool permission

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true
    }
    property bool isCreated: false

    height: (repeater.model.count()+1)*48
    onStatusChanged: { if (isCreated && dlgParticipants.status === DialogStatus.Closed) { dlgParticipants.destroy() } }

    content: Flickable {
        id: listView
        anchors.fill: parent
        contentHeight: columnContent.height
        contentWidth: columnContent.width
        clip: true

        flickableDirection: Flickable.VerticalFlick
        Column {
            id: columnContent
            spacing: 0

            Repeater {
                id: repeater
                model: xmppConnectivity.useClient(accountId).getParticipants(contactJid)
                delegate: MucParticipantDelegate {
                    width: listView.width
                    kick: dlgParticipants.kick;
                    permission: dlgParticipants.permission;
                    accountId: dlgParticipants.accountId;
                    contactJid: dlgParticipants.contactJid
                }
            }
        }
    }
}
