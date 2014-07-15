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
    id: dlgIAP
    titleText: qsTr("Available Access Points")
    privateCloseIcon: true
    platformInverted: main.platformInverted
    height: data.contentHeight+48 > parent.height-64 ? parent.height - 64 : data.contentHeight+48

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    onStatusChanged: { if (isCreated && dlgIAP.status === DialogStatus.Closed) { dlgIAP.destroy() } }

    content: ListView {
                id: data
                anchors.fill: parent
                highlightFollowsCurrentItem: false
                model: network.configurations
                delegate: Component {
                    Rectangle {
                        id: itemConfig
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
                        Image {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
                            source: "qrc:/networks/" + bearer + (main.platformInverted ? "_inverse" : "")
                            sourceSize { width: 32; height: 32 }
                            width: 32
                            height: 32

                        }

                        Text {
                            id: textConfig
                            text: name
                            font.pixelSize: platformStyle.fontSizeSmall
                            anchors { left: parent.left; leftMargin: 64; verticalCenter: parent.verticalCenter; }
                            color: vars.textColor
                            font.bold: false
                        }
                        states: State {
                            name: "Current"
                            when: settings.gInt("behavior", "internetAccessPoint") === id
                            PropertyChanges { target: itemConfig; gradient: gr_press }
                            PropertyChanges { target: textConfig; color: platformStyle.colorNormalLight }
                            PropertyChanges { target: textConfig; font.bold: true }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settings.sInt(id,"behavior", "internetAccessPoint")
                                network.currentIAP = id
                                dlgIAP.close()
                            } //onClicked
                        } //MouseArea
                    }
                } //Component
            }
}
