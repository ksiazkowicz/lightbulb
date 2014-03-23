/********************************************************************

qml/Preflets/Widget.qml
-- Preflet with homescreen widget options

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
import lightbulb 1.0

Item {
    SelectorHandler { id: selector }
    height: column.height

    Column {
        id: column
        spacing: platformStyle.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter;
        width: parent.width

        Item {
            width: parent.width
            height: enableWgText.height + platformStyle.paddingSmall
            Text {
                id: enableWgText
                property string color2: main.platformInverted ? "#333333" : "#888888"
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: enableWg.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: vars.textColor
                text: qsTr("Enable homescreen widget") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("If enabled, you'll be able to add widget with notifications to your homescreen.")  + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: enableWg
                checked: settings.gBool("widget","enableHsWidget")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"widget","enableHsWidget")
                    if (checked) notify.registerWidget();
                    else notify.removeWidget()
                }
            }
        }

        Rectangle {
            height: 1
            anchors { left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: vars.textColor
            opacity: 0.2
        }

        Text {
            property string color2: main.platformInverted ? "#333333" : "#888888"
            anchors { left: parent.left; right: parent.right; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
            color: vars.textColor
            text: qsTr("Widget skin") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("Tap on one of the list items below to change widget skin.")  + "</font>"
            font.pixelSize: 20
            wrapMode: Text.WordWrap
        }

        ListView {
            id: list;
            anchors { left: parent.left; right: parent.right }
            height: 196
            model: selector.skins
            contentHeight: wrapper.height*list.count
            clip: true
            delegate: ListItem {
                    id: wrapper
                    height: 48
                    Text {
                        anchors { fill: parent; margins: 10 }
                        text: selector.getSkinName(modelData)
                        color: vars.textColor
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            settings.sStr("C:\\data\\.config\\Lightbulb\\widgets\\" + modelData,"widget","skin")
                            notify.updateSkin()
                            notify.postInfo("Skin changed to " + modelData + ".");
                        }
                    }
            }
        }

        Rectangle {
            height: 1
            anchors { left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: vars.textColor
            opacity: 0.2
        }

        Item {
            width: parent.width
            height: showUnreadCountChat.height + platformStyle.paddingSmall
            Text {
                id: showUnreadCountChat
                property string color2: main.platformInverted ? "#333333" : "#888888"
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: showUnreadCountChatSw.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: vars.textColor
                text: qsTr("Unread count for each contact") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("If enabled, you will see unread count for each contact on the list on the widget, next to its name.")  + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: showUnreadCountChatSw
                checked: settings.gBool("widget","showUnreadCntChat")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"widget","showUnreadCntChat")
                    notify.updateWidget()
                }
            }
        }

        Rectangle {
            height: 1
            anchors { left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: vars.textColor
            opacity: 0.2
        }

        Item {
            width: parent.width
            height: showGlobalUnreadCount.height + platformStyle.paddingSmall
            Text {
                id: showGlobalUnreadCount
                property string color2: main.platformInverted ? "#333333" : "#888888"
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: showGlobalUnreadCountSw.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: vars.textColor
                text: qsTr("Show global unread count") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("If enabled, you will see global unread count over the status icon.")  + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: showGlobalUnreadCountSw
                checked: settings.gBool("widget","showGlobalUnreadCnt")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"widget","showGlobalUnreadCnt")
                    notify.updateWidget()
                }
            }
        }

        Rectangle {
            height: 1
            anchors { left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: vars.textColor
            opacity: 0.2
        }

        Item {
            width: parent.width
            height: showStatus.height + platformStyle.paddingSmall
            Text {
                id: showStatus
                property string color2: main.platformInverted ? "#333333" : "#888888"
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: showStatusSw.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: vars.textColor
                text: qsTr("Show my status") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("If disabled, status icon will be replaced with your account icon.")  + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: showStatusSw
                checked: settings.gBool("widget","showStatus")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"widget","showStatus")
                    notify.updateWidget()
                }
            }
        }

        Rectangle {
            height: 1
            anchors { left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: vars.textColor
            opacity: 0.2
        }
        SelectionListItem {
            platformInverted: main.platformInverted
            subTitle: selectionDialog.selectedIndex >= 0
                      ? selectionDialog.model.get(selectionDialog.selectedIndex).name
                      : "Default"
            anchors { left: parent.left; right: parent.right }
            title: "Data to display"

            onClicked: selectionDialog.open()

            SelectionDialog {
                id: selectionDialog
                titleText: "Available options"
                selectedIndex: settings.gInt("widget","data")
                platformInverted: main.platformInverted
                model: ListModel {
                    ListElement { name: "Latest chats" }
                    ListElement { name: "Online contacts" }
                    ListElement { name: "Status changes" }
                }
                onSelectedIndexChanged: {
                    settings.sInt(selectedIndex,"widget","data")
                    notify.updateWidget()
                }
            }
        }

    }
}

