import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    height: content.height

    Column {
        id: content
        width: parent.width
        spacing: 5

        Text {
            text: "Message received"
            color: vars.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ButtonRow {
            id: msgRecvSettings
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                id: vibrMsgRecv
                text: selected ? qsTr("Vibration") : qsTr("[x] Vibration")
                property bool selected: settings.gBool("notifications","vibraMsgRecv")
                platformInverted: main.platformInverted
                onClicked: {
                    if (selected) selected = false; else selected = true;
                    settings.sBool(selected,"notifications","vibraMsgRecv")
                }
            }
            ToolButton {
                id: soundMsgRecv
                iconSource: selected ? ":/Events/alarm" : ":/Events/alarm_disabled"
                property bool selected: settings.gBool("notifications","soundMsgRecv")
                platformInverted: main.platformInverted
                onClicked: {
                    if (selected) selected = false; else selected = true;
                    settings.sBool(selected,"notifications","soundMsgRecv")
                }
            }
            ToolButton {
                id: usePopupRecv
                text: selected ? qsTr("Popup") : qsTr("[x] Popup")
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
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                width: parent.width/3
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    vars.nowEditing = "vibraMsgRecv"
                    dialog.create("qrc:/dialogs/Settings/Vibration")
                }
            }
            ToolButton {
                width: parent.width/3
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    var filename = avkon.openFileSelectionDlg();
                    if (filename != "") settings.sStr(filename,"notifications","soundMsgRecvFile")
                }
            }
            ToolButton {
                enabled: false
                height: parent.height
                width: parent.width/3
            }
        }
        Text {
            text: "Message sent"
            color: vars.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ButtonRow {
            id: msgSentSettings
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                id: vibrMsgSent
                text: selected ? qsTr("Vibration") : qsTr("[x] Vibration")
                property bool selected: settings.gBool("notifications","vibraMsgSent")
                platformInverted: main.platformInverted
                onClicked: {
                    if (selected) selected = false; else selected = true;
                    settings.sBool(selected,"notifications","vibraMsgSent")
                }
            }
            ToolButton {
                id: soundMsgSent
                iconSource: selected ? ":/Events/alarm" : ":/Events/alarm_disabled"
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
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                width: parent.width/2
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    vars.nowEditing = "vibraMsgSent"
                    dialog.create("qrc:/dialogs/Settings/Vibration")
                }
            }
            ToolButton {
                width: parent.width/2
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    var filename = avkon.openFileSelectionDlg();
                    if (filename != "") settings.sStr(filename,"notifications","soundMsgSentFile")
                }
            }
        }
        Text {
            text: "Connecting changed"
            color: vars.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ButtonRow {
            id: notifyConnectionSettings
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                id: soundNotifyConn
                iconSource: selected ? ":/Events/alarm" : ":/Events/alarm_disabled"
                property bool selected: settings.gBool("notifications","soundNotifyConn")
                platformInverted: main.platformInverted
                onClicked: {
                    if (selected) selected = false; else selected = true;
                    settings.sBool(selected,"notifications","soundNotifyConn")
                }
            }
            ToolButton {
                id: notifyOnline
                text: selected ? qsTr("Popup") : qsTr("[x] Popup")
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
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                width: parent.width/2
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    var filename = avkon.openFileSelectionDlg();
                    if (filename != "") settings.sStr(filename,"notifications","soundNotifyConnFile")
                }
            }
            ToolButton {
                enabled: false
                height: parent.height
                width: parent.width/2
            }
        }

        Text {
            text: "Subscription request"
            color: vars.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ButtonRow {
            id: msgSubSettings
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                id: vibrMsgSub
                text: selected ? qsTr("Vibration") : qsTr("[x] Vibration")
                property bool selected: settings.gBool("notifications","vibraMsgSub")
                platformInverted: main.platformInverted
                onClicked: {
                    if (selected) selected = false; else selected = true;
                    settings.sBool(selected,"notifications","vibraMsgSub")
                }
            }
            ToolButton {
                id: soundMsgSub
                iconSource: selected ? ":/Events/alarm" : ":/Events/alarm_disabled"
                property bool selected: settings.gBool("notifications","soundMsgSub")
                platformInverted: main.platformInverted
                onClicked: {
                    if (selected) selected = false; else selected = true;
                    settings.sBool(selected,"notifications","soundMsgSub")
                }
            }
            ToolButton {
                id: subInfo
                text: selected ? qsTr("Popup") : qsTr("[x] Popup")
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
            anchors.horizontalCenter: parent.horizontalCenter
            ToolButton {
                width: parent.width/3
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    vars.nowEditing = "vibraMsgSub"
                    dialog.create("qrc:/dialogs/Settings/Vibration")
                }
            }
            ToolButton {
                width: parent.width/3
                iconSource: "toolbar-settings"
                platformInverted: main.platformInverted
                onClicked: {
                    var filename = avkon.openFileSelectionDlg();
                    if (filename != "") settings.sStr(filename,"notifications","soundMsgSubFile")
                }
            }
            ToolButton {
                enabled: false
                height: parent.height
                width: parent.width/3
            }
        }

        Text {
            text: "Contact is typing"
            color: vars.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        CheckBox {
            id: notifyBoxTyping
            text: qsTr("Popup")
            height: 64
            checked: settings.gBool("notifications", "notifyTyping")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"notifications", "notifyTyping")
            }
        }
    }
}

