import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    height: content.contentHeight

    Column {
        id: content
        spacing: 5
        width: 340

        Text {
            text: "Message received"
            color: vars.textColor
        }
        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: vibrMsgRecv
                text: qsTr("Vibration")
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.gBool("notifications","vibraMsgRecv")
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","vibraMsgRecv")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "vibraMsgRecv"
                    dialog.create("qrc:/dialogs/Settings/Vibration")
                }
            }
        }
        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: soundMsgRecv
                text: qsTr("Sound effect")
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.gBool("notifications","soundMsgRecv")
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","soundMsgRecv")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "soundMsgRecv"
                    dialog.create("qrc:/dialogs/Settings/Sound")
                }
            }
        }
        CheckBox {
               id: usePopupRecv
               text: qsTr("Popup")
               height: 64
               checked: settings.gBool("notifications", "usePopupRecv")
               platformInverted: main.platformInverted
               onCheckedChanged: {
                  settings.sBool(checked,"notifications", "usePopupRecv")
               }
            }
        Rectangle {
            width: content.width-20
            height: 50
            color: "transparent"
            CheckBox {
                   id: dontBLINK
                   text: qsTr("Use notification LED")
                   height: 64
                   checked: settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")
                   platformInverted: main.platformInverted
                   onCheckedChanged: {
                      settings.sBool(checked,"notifications", "wibblyWobblyTimeyWimeyStuff")
                   }
                }
            TextField {
                id: blinkSpecificDevice
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                text: settings.gInt("notifications", "blinkScreenDevice")
                height: 50
                width: 50
                anchors.right: parent.right

                placeholderText: "1/2/3/4"


                Component.onCompleted: {
                    blinkSpecificDevice.text = settings.gInt("notifications", "blinkScreenDevice")
                }

                onTextChanged: {
                    var device = parseInt(blinkSpecificDevice.text)
                    settings.sInt(device, "notifications", "blinkScreenDevice")
                }
            }
        }
        //
        Text {
            text: "Message sent"
            color: vars.textColor
        }
        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: vibrMesgSent
                text: qsTr("Vibration")
                checked: settings.gBool("notifications", "vibraMsgSent")
                anchors.verticalCenter: parent.verticalCenter
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications", "vibraMsgSent")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "vibraMsgSent"
                    dialog.create("qrc:/dialogs/Settings/Vibration")
                }
            }
        }

        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: soundMsgSent
                text: qsTr("Sound effect")
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.gBool("notifications","soundMsgSent")
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","soundMsgSent")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "soundMsgSent"
                    dialog.create("qrc:/dialogs/Settings/Sound")
                }
            }
        }

        Text {
            text: "Connecting changed"
            color: vars.textColor
        }
        CheckBox {
            id: notifyOnline
            text: qsTr("Popup")
            height: 64
            checked: settings.gBool("notifications", "notifyConnection")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"notifications", "notifyConnection")
            }
        }
        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: soundNotifyConn
                text: qsTr("Sound effect")
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.gBool("notifications","soundNotifyConn")
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","soundNotifyConn")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "soundNotifyConn"
                    dialog.create("qrc:/dialogs/Settings/Sound")
                }
            }
        }

        Text {
            text: "Subscription request"
            color: vars.textColor
        }
        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: subSound
                text: qsTr("Sound effect")
                anchors.verticalCenter: parent.verticalCenter
                checked: settings.gBool("notifications","soundMsgSub")
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications","soundMsgSub")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "soundMsgSub"
                    dialog.create("qrc:/dialogs/Settings/Sound")
                }
            }
        }


        Rectangle {
            width: content.width-20
            height: 64
            color: "transparent"
            CheckBox {
                id: subVibra
                text: qsTr("Vibration")
                checked: settings.gBool("notifications", "vibraMsgSub")
                anchors.verticalCenter: parent.verticalCenter
                platformInverted: main.platformInverted
                onCheckedChanged: {
                    settings.sBool(checked,"notifications", "vibraMsgSub")
                }
            }
            ToolButton {
                anchors.right: parent.right
                iconSource: main.platformInverted ? "toolbar-settings_inverse" : "toolbar-settings"
                onClicked: {
                    vars.nowEditing = "vibraMsgSub"
                    dialog.create("qrc:/dialogs/Settings/Vibration")
                }
            }
        }

        CheckBox {
            id: subInfo
            text: qsTr("Popup")
            height: 64
            checked: settings.gBool("notifications", "notifySubscription")
            platformInverted: main.platformInverted
            onCheckedChanged: {
                settings.sBool(checked,"notifications", "notifySubscription")
            }
        }
        //
        Text {
            text: "Contact is typing"
            color: vars.textColor
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

