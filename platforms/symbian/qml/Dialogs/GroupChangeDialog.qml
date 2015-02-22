/********************************************************************

qml/Dialogs/GroupChangeDialog.qml
-- Dialog which enables user to change contacts group

Copyright (c) 2015 Maciej Janiszewski

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

    buttonTexts: ["Custom group","Cancel"]

    signal unselectAll;

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true
    }
    property bool isCreated:      false
    property string accountId:    ""
    property string contactName:  ""
    property string contactJid:   ""
    property string contactGroup: ""

    onButtonClicked: if (index === 0) {
                         main.splitscreenY = 0;
                         customGroup.isCreated = true
                         customGroup.open();
                     }

    onStatusChanged: { if (isCreated && dlgGroups.status === DialogStatus.Closed && customGroup.status === DialogStatus.Closed) { dlgGroups.destroy() } }

    content: ListView {
        id: data
        anchors.fill: parent
        highlightFollowsCurrentItem: false
        model: xmppConnectivity.useClient(accountId).groups
        delegate: Component {
            Rectangle {
                id: groupItem
                height: platformStyle.graphicSizeMedium
                width: parent.width
                gradient: gr_normal

                // item highlighting
                function unselect() { checked = false }
                Connections { target: dlgGroups; onUnselectAll: unselect(); }
                property bool checked: contactGroup == modelData

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
                    id: groupText
                    text: modelData != "" ? modelData : "<i>-- none --</i>"
                    font.pixelSize: platformStyle.fontSizeMedium
                    anchors { left: parent.left; leftMargin: platformStyle.graphicSizeMedium+platformStyle.paddingLarge; verticalCenter: parent.verticalCenter; }
                    color: main.textColor
                    font.bold: false
                }
                states: [ State {
                        when: checked
                        PropertyChanges { target: groupItem; gradient: gr_press }
                        PropertyChanges { target: groupText; color: platformStyle.colorNormalLight }
                        PropertyChanges { target: groupText; font.bold: true }
                    },
                    State {
                        when: !checked
                        PropertyChanges { target: groupItem; gradient: gr_normal }
                        PropertyChanges { target: groupText; color: main.textColor }
                        PropertyChanges { target: groupText; font.bold: false }
                    }
                ]

                //
                Image {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: platformStyle.paddingLarge }
                    source: checked ? "qrc:/toolbar/ok" + (main.platformInverted ? "_inverse" : "") : ""
                    sourceSize { width: platformStyle.graphicSizeSmall; height: platformStyle.graphicSizeSmall }
                    width: platformStyle.graphicSizeSmall
                    height: platformStyle.graphicSizeSmall
                }


                MouseArea {
                    id: groupTapArea
                    anchors.fill: parent
                    onClicked: {
                        // unselect all
                        dlgGroups.unselectAll()

                        // highlight the item
                        parent.checked = true

                        // change group
                        xmppConnectivity.useClient(accountId).setContactGroup(contactJid,modelData)

                        // show popup to let user know we've changed something
                        if (modelData != "")
                            avkon.showPopup(contactName,"moved to group " + modelData)
                        else
                            avkon.showPopup(contactName,"removed from group " + contactGroup)

                        // close dialog
                        dlgGroups.close()
                    } //onClicked
                } //MouseArea
            }
        } //Component
    }


    CommonDialog {
        id: customGroup
        titleText: qsTr("Custom group name")
        platformInverted: main.platformInverted

        buttonTexts: [qsTr("OK"), qsTr("Cancel")]

        // Code for dynamic load
        property bool isCreated: false

        onStatusChanged: if (isCreated && customGroup.status === DialogStatus.Closed) { dlgGroups.destroy(); customGroup.destroy() }

        onButtonClicked: {
            if ((index === 0) && (newGroup.text != "" ))
                xmppConnectivity.useClient(accountId).setContactGroup(contactJid,newGroup.text)
        }

        content: TextField {
            id: newGroup
            text: contactGroup
            placeholderText: qsTr("Enter group name")
            width: parent.width - 2*platformStyle.paddingLarge
            anchors { centerIn: parent }
        }
    }
}
