import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    height: content.height

    Column {
        id: content
        width: parent.width
        spacing: 5

        Item {
            width: parent.width
            height: msgRecvSettings.height * 2
            Column {
                anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; top: parent.top; topMargin: platformStyle.paddingSmall }
                width: parent.width - msgRecvSettings.width - 20
                height: content.height
                Text {
                    width: parent.width
                    color: vars.textColor
                    text: qsTr("Incoming message")
                    font.pixelSize: 20
                }
                Text {
                    width: parent.width
                    color: main.platformInverted ? "#333333" : "#888888"
                    text: qsTr("Haptics feedback, sound notification or popup will happen when receiving an incoming message if enabled.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
            ButtonRow {
                id: msgRecvSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: vibrMsgRecv
                    iconSource: selected ? ":/Events/vibra" : ":/Events/vibra_disabled"
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
                    iconSource: selected ? ":/Events/popup" : ":/Events/popup_disabled"
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
                    height: button.height
                    width: parent.width/3
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
            height: msgSentSettings.height * 2

            Column {
                anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; top: parent.top; topMargin: platformStyle.paddingSmall }
                width: parent.width - msgSentSettings.width - 20
                height: content.height
                Text {
                    width: parent.width
                    color: vars.textColor
                    text: qsTr("Outgoing message")
                    font.pixelSize: 20
                }
                Text {
                    width: parent.width
                    color: main.platformInverted ? "#333333" : "#888888"
                    text: qsTr("Haptics feedback or sound notification will happen when your message is sent.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }

            ButtonRow {
                id: msgSentSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: vibrMsgSent
                    iconSource: selected ? ":/Events/vibra" : ":/Events/vibra_disabled"
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
                        settings.sBool(selected,"notifications","soundMsgRecv")
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
                    onClicked: {
                        vars.nowEditing = "vibraMsgSent"
                        dialog.create("qrc:/dialogs/Settings/Vibration")
                    }
                }
                ToolButton {
                    width: parent.width/3
                    iconSource: "toolbar-settings"
                    platformInverted: main.platformInverted
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
            color: vars.textColor
            opacity: 0.2
        }

        Item {
            width: parent.width
            height: msgRecvSettings.height * 2

            Column {
                anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; top: parent.top; topMargin: platformStyle.paddingSmall }
                width: parent.width - notifyConnectionSettings.width - 20
                height: content.height
                Text {
                    width: parent.width
                    color: vars.textColor
                    text: qsTr("Connection")
                    font.pixelSize: 20
                }
                Text {
                    width: parent.width
                    color: main.platformInverted ? "#333333" : "#888888"
                    text: qsTr("Sound notification will be played or popup will appear when connection state changes, if enabled.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }

            ButtonRow {
                id: notifyConnectionSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
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
                    iconSource: selected ? ":/Events/popup" : ":/Events/popup_disabled"
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
                }
                ToolButton {
                    enabled: false
                    height: parent.height
                    width: parent.width/2
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
            height: msgRecvSettings.height * 2

            Column {
                anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; top: parent.top; topMargin: platformStyle.paddingSmall }
                width: parent.width - msgSubSettings.width - 20
                height: content.height
                Text {
                    width: parent.width
                    color: vars.textColor
                    text: qsTr("Subscription")
                    font.pixelSize: 20
                }
                Text {
                    width: parent.width
                    color: main.platformInverted ? "#333333" : "#888888"
                    text: qsTr("Haptics feedback, sound notification or popup will happen when receiving a subscription request, if enabled.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }


            ButtonRow {
                id: msgSubSettings
                anchors { right: parent.right; rightMargin: 10; top: parent.top }
                ToolButton {
                    id: vibrMsgSub
                    iconSource: selected ? ":/Events/vibra" : ":/Events/vibra_disabled"
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
                    iconSource: selected ? ":/Events/popup" : ":/Events/popup_disabled"
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
                    height: button2.height
                    width: parent.width/3
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
            height: column.height

            Column {
                id: column
                anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; top: parent.top; topMargin: platformStyle.paddingSmall }
                width: parent.width - notifyTyping.width - 20
                height: notifyTyping.height+20+2*platformStyle.paddingSmall
                Text {
                    width: parent.width
                    color: vars.textColor
                    text: qsTr("Typing notifications")
                    font.pixelSize: 20
                }
                Text {
                    width: parent.width
                    color: main.platformInverted ? "#333333" : "#888888"
                    text: qsTr("If enabled, popup will appear when contact started/stopped typing.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
            Switch {
                id: notifyTyping
                checked: settings.gBool("notifications","notifyTyping")
                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","notifyTyping")
                }
            }
        }
    }
}

