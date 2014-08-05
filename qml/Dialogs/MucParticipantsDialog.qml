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

    height: (listView.model.count()+1)*48

    onStatusChanged: { if (isCreated && dlgParticipants.status === DialogStatus.Closed) { dlgParticipants.destroy() } }

    content: ListView {
                id: listView
                anchors.fill: parent
                model: xmppConnectivity.useClient(accountId).getParticipants(contactJid)
                clip: true
                delegate: Component {
                              Rectangle {
                                  id: wrapper
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
                                      source: presence
                                      sourceSize.height: 24
                                      sourceSize.width: 24
                                      anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                                      height: 24
                                      width: 24
                                  }
                                  /*Image {
                                      id: imgRole
                                      source:
                                      sourceSize.height: 24
                                      sourceSize.width: 24
                                      anchors { verticalCenter: parent.verticalCenter; right: closeBtn.left; rightMargin: 10 }
                                      height: 24
                                      width: 24
                                  }*/
                                  Text {
                                      id: partName
                                      anchors { verticalCenter: parent.verticalCenter; left: imgPresence.right; right: parent.right; rightMargin: 5; leftMargin: 10 }
                                      text: name
                                      font.pixelSize: 18
                                      clip: true
                                      color: vars.textColor
                                      elide: Text.ElideRight
                                  }
                                  states: [ State {
                                      when: itemResource.ListView.isCurrentItem
                                      PropertyChanges { target: wrapper; gradient: gr_press }
                                      PropertyChanges { target: partName; color: platformStyle.colorNormalLight }
                                  },
                                  State {
                                    when: !itemResource.ListView.isCurrentItem
                                    PropertyChanges { target: wrapper; gradient: gr_free }
                                    PropertyChanges { target: partName; color: vars.textColor }
                                  }]
                              }
                           }
            }
}
