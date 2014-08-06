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
    property bool kick
    property bool permission

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
                delegate: Item {
                    id: mucPartDelegate
                    height: 48
                    width: listView.width
                    Image {
                        id: imgPresence
                        source: presence
                        sourceSize.height: 24
                        sourceSize.width: 24
                        anchors { verticalCenter: mucPartDelegate.verticalCenter; left: parent.left; leftMargin: 10; }
                        height: 24
                        width: 24
                    }
                    Flickable {
                        flickableDirection: Flickable.HorizontalFlick
                        interactive: (kick || permission)
                        //boundsBehavior: Flickable.DragOverBounds
                        height: 48
                        width: listView.width
                        contentWidth: wrapper.width + buttonRow.width
                        Item {
                            id: wrapper
                            width: listView.width
                            anchors.left: parent.left
                            height: 48
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
                                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: 5; leftMargin: 44 }
                                text: name
                                font.pixelSize: 18
                                clip: true
                                color: vars.textColor
                                elide: Text.ElideRight
                            }
                        }
                        ButtonRow {
                            id: buttonRow
                            anchors.left: wrapper.right;
                            ToolButton {
                                text: "Kick"
                                enabled: kick
                                onClicked: dialog.createWithProperties("qrc:/dialogs/MUC/Query",{"contactJid":contactJid,"accountId":accountId,"userJid":bareJid,"titleText":qsTr("Kick reason (optional)"),"actionType":1})
                            }
                            ToolButton {
                                text: "Ban"
                                enabled: permission
                                onClicked: dialog.createWithProperties("qrc:/dialogs/MUC/Query",{"contactJid":contactJid,"accountId":accountId,"userJid":bareJid,"titleText":qsTr("Ban reason (optional)"),"actionType":2})
                            }
                        }
                    }
                }
            }
}
