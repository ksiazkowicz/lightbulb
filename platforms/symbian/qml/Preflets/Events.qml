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

Item {
    height: content.height

    property string invertStuff: main.platformInverted ? "_inverse" : ""

    Column {
        id: content
        width: parent.width
        spacing: 5

        Item {
            width: parent.width
            height: msgRecvSettings.height * 2
            Text {
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: msgRecvSettings.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: main.textColor
                property string color2: main.platformInverted ? "#333333" : "#888888"
                text: qsTr("Incoming message") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("Haptics feedback, sound notification or popup will happen when receiving an incoming message if enabled.") + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            ButtonRow {
                id: msgRecvSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: vibrMsgRecv
                    iconSource: selected ? ":/Events/vibra" + invertStuff : ":/Events/vibra_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","vibraMsgRecv")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","vibraMsgRecv")
                    }
                }
                ToolButton {
                    id: soundMsgRecv
                    iconSource: selected ? ":/Events/alarm" + invertStuff : ":/Events/alarm_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","soundMsgRecv")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","soundMsgRecv")
                    }
                }
                ToolButton {
                    id: usePopupRecv
                    iconSource: selected ? ":/Events/popup" + invertStuff : ":/Events/popup_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","usePopupRecv")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","usePopupRecv")
                    }
                }
            }
            ButtonRow {
                width: msgRecvSettings.width
                anchors { right: parent.right; rightMargin: 10; top: msgRecvSettings.bottom }
                ToolButton {
                    id: button
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onClicked: dialog.createWithProperties("qrc:/dialogs/Settings/Vibration", {"currentlyEditedParameter" : "vibraMsgRecv"})
                }
                ToolButton {
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onClicked: {
                        var filename = avkon.openFileSelectionDlg();
                        if (filename != "") settings.sStr(filename,"notifications","soundMsgRecvFile")
                    }
                    onPlatformPressAndHold: {
                        var filename = avkon.openFileSelectionDlg(true,true,"Z:\\data\\sounds\\digital");
                        if (filename != "") settings.sStr(filename,"notifications","soundMsgRecvFile")
                    }
                }
                ToolButton {
                    enabled: false
                    platformInverted: main.platformInverted
                    height: button.height
                    width: parent.width/3
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
            height: msgSentSettings.height * 2

            Text {
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: msgSentSettings.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: main.textColor
                property string color2: main.platformInverted ? "#333333" : "#888888"
                text: qsTr("Outgoing message") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("Haptics feedback or sound notification will happen when your message is sent.") + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }

            ButtonRow {
                id: msgSentSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: vibrMsgSent
                    iconSource: selected ? ":/Events/vibra" + invertStuff : ":/Events/vibra_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","vibraMsgSent")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","vibraMsgSent")
                    }
                }
                ToolButton {
                    id: soundMsgSent
                    iconSource: selected ? ":/Events/alarm" + invertStuff : ":/Events/alarm_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","soundMsgSent")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","soundMsgSent")
                    }
                }
            }
            ButtonRow {
                width: msgSentSettings.width
                anchors { right: parent.right; rightMargin: 10; top: msgSentSettings.bottom }
                ToolButton {
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onClicked: dialog.createWithProperties("qrc:/dialogs/Settings/Vibration", {"currentlyEditedParameter" : "vibraMsgSent"})
                }
                ToolButton {
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onPlatformPressAndHold: {
                        var filename = avkon.openFileSelectionDlg(true,true,"Z:\\data\\sounds\\digital");
                        if (filename != "") settings.sStr(filename,"notifications","soundMsgSentFile")
                    }
                    onClicked: {
                        var filename = avkon.openFileSelectionDlg();
                        if (filename != "") settings.sStr(filename,"notifications","soundMsgSentFile")
                    }
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
            height: msgRecvSettings.height * 2

            Text {
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: notifyConnectionSettings.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: main.textColor
                property string color2: main.platformInverted ? "#333333" : "#888888"
                text: qsTr("Connection") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("Sound notification will be played or popup will appear when connection state changes, if enabled.") + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }

            ButtonRow {
                id: notifyConnectionSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: soundNotifyConn
                    iconSource: selected ? ":/Events/alarm" + invertStuff : ":/Events/alarm_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","soundNotifyConn")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","soundNotifyConn")
                    }
                }
                ToolButton {
                    id: notifyOnline
                    iconSource: selected ? ":/Events/popup" + invertStuff : ":/Events/popup_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","notifyConnection")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","notifyConnection")
                    }
                }
            }
            ButtonRow {
                width: notifyConnectionSettings.width
                anchors { right: parent.right; rightMargin: 10; top: notifyConnectionSettings.bottom }
                ToolButton {
                    width: parent.width/2
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onClicked: {
                        var filename = avkon.openFileSelectionDlg();
                        if (filename != "") settings.sStr(filename,"notifications","soundNotifyConnFile")
                    }
                    onPlatformPressAndHold: {
                        var filename = avkon.openFileSelectionDlg(true,true,"Z:\\data\\sounds\\digital");
                        if (filename != "") settings.sStr(filename,"notifications","soundNotifyConnFile")
                    }
                }
                ToolButton {
                    enabled: false
                    platformInverted: main.platformInverted
                    height: parent.height
                    width: parent.width/2
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
            height: msgRecvSettings.height * 2

            Text {
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: msgSubSettings.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: main.textColor
                property string color2: main.platformInverted ? "#333333" : "#888888"
                text: qsTr("Subscription") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("Haptics feedback, sound notification or popup will happen when receiving a subscription request, if enabled.") + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }

            ButtonRow {
                id: msgSubSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: vibrMsgSub
                    iconSource: selected ? ":/Events/vibra" + invertStuff : ":/Events/vibra_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","vibraMsgSub")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","vibraMsgSub")
                    }
                }
                ToolButton {
                    id: soundMsgSub
                    iconSource: selected ? ":/Events/alarm" + invertStuff : ":/Events/alarm_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","soundMsgSub")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","soundMsgSub")
                    }
                }
                ToolButton {
                    id: subInfo
                    iconSource: selected ? ":/Events/popup" + invertStuff : ":/Events/popup_disabled" + invertStuff
                    property bool selected: settings.gBool("notifications","notifySubscription")
                    platformInverted: main.platformInverted
                    onClicked: {
                        if (selected) selected = false; else selected = true;
                        settings.sBool(selected,"notifications","notifySubscription")
                    }
                }
            }
            ButtonRow {
                width: msgSubSettings.width
                anchors { right: parent.right; rightMargin: 10; top: msgSubSettings.bottom }
                ToolButton {
                    id: button2
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onClicked: dialog.createWithProperties("qrc:/dialogs/Settings/Vibration", {"currentlyEditedParameter" : "vibraMsgSub"})
                }
                ToolButton {
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
                    onClicked: {
                        var filename = avkon.openFileSelectionDlg();
                        if (filename != "") settings.sStr(filename,"notifications","soundMsgSubFile")
                    }
                    onPlatformPressAndHold: {
                        var filename = avkon.openFileSelectionDlg(true,true,"Z:\\data\\sounds\\digital");
                        if (filename != "") settings.sStr(filename,"notifications","soundMsgSubFile")
                    }
                }
                ToolButton {
                    enabled: false
                    height: button2.height
                    platformInverted: main.platformInverted
                    width: parent.width/3
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
                checked: settings.gBool("notifications","notifyStatusChange")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","notifyStatusChange")
                }
            }
        }

    }
}

