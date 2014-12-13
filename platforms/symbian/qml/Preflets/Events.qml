/********************************************************************

qml/Preflets/Events.qml
-- Preflet with notification options

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
import "../Components"

Item {
    height: content.height

    property string invertStuff: main.platformInverted ? "_inverse" : ""

    ListModel {
        id: settingListModel
        ListElement {
            title: "Incoming message";
            description: "Haptics feedback, sound notification or popup will happen when receiving an incoming message if enabled.";
            eventSettingName: "MsgRecv";
            enableVibra: true
            enableSound: true
            enablePopup: true
        }
        ListElement {
            title: "Outgoing message";
            description: "Haptics feedback or sound notification will happen when your message is sent."
            eventSettingName: "MsgSent";
            enablePopup: false;
            enableVibra: true
            enableSound: true
        }
        ListElement {
            title: "Connection";
            description: "Sound notification will be played or popup will appear when connection state changes, if enabled.";
            eventSettingName: "NotifyConn";
            enableVibra: false;
            enablePopup: true;
            enableSound: true;
        }
        ListElement {
            title: "Subscription";
            description: "Haptics feedback, sound notification or popup will happen when receiving a subscription request, if enabled.";
            eventSettingName: "MsgSub";
            enableVibra: true
            enableSound: true
            enablePopup: true
        }
        ListElement {
            title: "Attention request";
            description: "Haptics feedback, sound notification or popup will happen when another user requests your attention if enabled.";
            eventSettingName: "Attention";
            enableVibra: true
            enableSound: true
            enablePopup: true
        }
        ListElement {
            title: "Application update";
            description: "Sound notification or popup will happen when app is updated.";
            eventSettingName: "AppUpdate";
            enableVibra: false
            enableSound: true
            enablePopup: true
        }
    }

    Column {
        id: content
        width: parent.width
        spacing: 5

        Repeater {
            id: eventsList
            model: settingListModel
            anchors { left: parent.left; right: parent.right }
            delegate: EventSettingDelegate { width: content.width }
        }

        Item {
            width: parent.width
            height: text.height+2*platformStyle.paddingSmall

            Text {
                id: text
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: notifyTyping.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: main.textColor
                property string color2: main.platformInverted ? "#333333" : "#888888"
                text: qsTr("Typing notifications") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("If enabled, popup will appear when contact started/stopped typing.") + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: notifyTyping
                checked: settings.gBool("notifications","notifyTyping")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","notifyTyping")
                }
            }
        }

        Rectangle {
            height: 1
            anchors { left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: main.textColor
            opacity: 0.2
        }

        Item {
            width: parent.width
            height: text.height+2*platformStyle.paddingSmall

            Text {
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: notifyStatusChange.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: main.textColor
                property string color2: main.platformInverted ? "#333333" : "#888888"
                text: qsTr("Status change notifications") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("If enabled, app will show status change notifications for fav. contacts") + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: notifyStatusChange
                checked: settings.gBool("notifications","notifyFavStatus")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","notifyFavStatus")
                }
            }
        }

    }
}

