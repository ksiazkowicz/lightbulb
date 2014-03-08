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
    id: dlgResources
    titleText: qsTr("Resources")
    privateCloseIcon: true
    platformInverted: main.platformInverted

    Component.onCompleted: {
        open()
    }

    content: ListView {
                anchors.fill: parent
                height: (listModelResources.count*48)+1
                highlightFollowsCurrentItem: false
                model: listModelResources
                delegate: Component {
                    Rectangle {
                        id: itemResource
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
                            id: textResource
                            text: resource
                            font.pixelSize: itemResource.height/2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color: vars.textColor
                            font.bold: false
                        }
                        states: State {
                            name: "Current"
                            when: itemResource.ListView.isCurrentItem
                            PropertyChanges { target: itemResource; gradient: gr_press }
                            PropertyChanges { target: textResource; color: platformStyle.colorNormalLight }
                            PropertyChanges { target: textResource; font.bold: true }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                itemResource.ListView.view.currentIndex = index

                                if( index == 0 ) vars.resourceJid = ""
                                else vars.resourceJid = resource

                                for (var i=0; i<listModelResources.count; i++) {
                                    if(index == i) listModelResources.get(index).checked = true
                                    else listModelResources.get(index).checked = false
                                }
                                dlgResources.close()
                            } //onClicked
                        } //MouseArea
                    }
                } //Component
            }
}
