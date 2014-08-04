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

CommonDialog {
    id: dlgParticipants
    titleText: qsTr("Participants")
    privateCloseIcon: true
    platformInverted: main.platformInverted

    height: (listView.model.count+1)*48

    property string contactJid
    property string accountId
    property bool hasModPermissions
    property bool hasOwnerPermissions

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true
    }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && dlgParticipants.status === DialogStatus.Closed) { dlgParticipants.destroy() } }

    content: ListView {
                id: listView
                anchors.fill: parent
                model: xmppConnectivity.getMUCParticipants(accountId,contactJid)
                clip: true
                delegate: Component {
                    Rectangle {
                        id: itemParticipant
                        height: 48
                        width: parent.width
                        gradient: gr_normal
                        Gradient {
                            id: gr_normal
                            GradientStop { position: 0; color: "transparent" }
                            GradientStop { position: 1; color: "transparent" }
                        }
                        Gradient {
                            id: gr_press
                            GradientStop { position: 0; color: "#1C87DD" }
                            GradientStop { position: 1; color: "#51A8FB" }
                        }
                        Text {
                            text: "[" + xmppConnectivity.getMUCParticipantAffiliationName(affiliation) + "] " + name
                            font.pixelSize: itemParticipant.height/2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: vars.textColor
                        }
                        states: State {
                            name: "Current"
                            when: itemParticipant.ListView.isCurrentItem
                            PropertyChanges { target: itemParticipant; gradient: gr_press }
                            PropertyChanges { target: itemParticipant; color: platformStyle.colorNormalLight }
                        }
                    }
                } //Component
            }
}
