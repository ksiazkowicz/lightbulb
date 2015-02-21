// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

/********************************************************************

qml/Dialogs/AccessPointsDialog.qml
-- Dialog for selecting Internet Access Point

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
    id: dlgGroups
    privateCloseIcon: true
    titleText: qsTr("Available groups")
    platformInverted: main.platformInverted
    height: data.contentHeight+3*platformStyle.graphicSizeMedium > parent.height-(platformStyle.graphicSizeMedium+platformStyle.paddingLarge) ? parent.height - (platformStyle.graphicSizeMedium+platformStyle.paddingLarge) : data.contentHeight+3*platformStyle.graphicSizeMedium

    buttonTexts: ["Add group"]

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false
    property string accountId: ""
    property string contactName: ""
    property string contactJid:  ""

    onStatusChanged: { if (isCreated && dlgGroups.status === DialogStatus.Closed) { dlgGroups.destroy() } }

    content: ListView {
                id: data
                anchors.fill: parent
                highlightFollowsCurrentItem: false
                model: xmppConnectivity.useClient(accountId).groups
                delegate: Component {
                    Rectangle {
                        id: itemConfig
                        height: platformStyle.graphicSizeMedium
                        width: parent.width
                        gradient: gr_normal

                        property bool checked;

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
                            id: textConfig
                            text: modelData != "" ? modelData : "<i>-- none --</i>"
                            font.pixelSize: platformStyle.fontSizeMedium
                            anchors { left: parent.left; leftMargin: platformStyle.graphicSizeMedium+platformStyle.paddingLarge; verticalCenter: parent.verticalCenter; }
                            color: main.textColor
                            font.bold: false
                        }
                        states: State {
                            name: "Current"
                            when: checked
                            PropertyChanges { target: itemConfig; gradient: gr_press }
                            PropertyChanges { target: textConfig; color: platformStyle.colorNormalLight }
                            PropertyChanges { target: textConfig; font.bold: true }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                parent.checked = true
                                xmppConnectivity.useClient(accountId).setContactGroup(contactJid,modelData)
                                dlgGroups.close()
                                /*settings.sInt(id,"behavior", "internetAccessPoint")
                                network.currentIAP = id
                                settings.sBool(true,"behavior","isIAPSet")
                                dlgIAP.close()*/
                            } //onClicked
                        } //MouseArea
                    }
                } //Component
            }
}
