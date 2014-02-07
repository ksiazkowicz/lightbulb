import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: settingsPage

    tools: toolBar

    Component.onCompleted: {
        statusBarText.text = "Settings"
    }

    /********************************************************************************/

    property bool shouldIreloadRoster: false

    /****************************************************/
    TabGroup {
        id: tabGroup

        anchors.fill: parent

        currentTab: tabNotifications
        Page {
            id: tabNotifications
            Flickable {
                id: flickArea
                anchors.fill: parent

                contentHeight: columnContent.height
                contentWidth: tabNotifications.width

                flickableDirection: Flickable.VerticalFlick

                Column {
                    id: columnContent
                    spacing: 5
                    anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }

                    Text {
                        text: "Message received"
                        color: vars.textColor
                    }
                    Rectangle {
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
                        width: tabNotifications.width-20
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
        }
        Page {
            id: tabAppearance
            Flickable {
                id: flickAreaAppearance
                anchors.fill: parent

                contentHeight: contentAppearance.height
                contentWidth: tabAppearance.width

                flickableDirection: Flickable.VerticalFlick
                Column {
                    id: contentAppearance
                    spacing: 5
                    anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                    CheckBox {
                       id: markUnread
                       text: qsTr("Mark contacts with unread msg.")
                       checked: settings.gBool("ui", "markUnread")
                       platformInverted: main.platformInverted
                       onCheckedChanged: {
                          settings.sBool(checked,"ui", "markUnread")
                           if (!checked) {
                               unreadCount.enabled = false;
                               unreadCount.checked = false;
                           } else unreadCount.enabled = true;
                           shouldIreloadRoster = true;
                       }
                    }
                    CheckBox {
                       id: unreadCount
                       text: qsTr("Show unread count")
                       enabled: markUnread.checked
                       checked: settings.gBool("ui", "showUnreadCount")
                       platformInverted: main.platformInverted
                       onCheckedChanged: {
                          settings.sBool(checked,"ui", "showUnreadCount")
                          shouldIreloadRoster = true;
                       }
                    }
                    CheckBox {
                       id: hideOffline
                       text: qsTr("Hide Offline contacts")
                       platformInverted: main.platformInverted
                       checked: settings.gBool("ui", "hideOffline")
                       onCheckedChanged: {
                          settings.sBool(checked,"ui", "hideOffline")
                          shouldIreloadRoster = true;
                       }
                    }
                    CheckBox {
                       id: showContactStatusText
                       text: qsTr("Show contacts status text")
                       platformInverted: main.platformInverted
                       checked: settings.gBool("ui", "showContactStatusText")
                       onCheckedChanged: {
                          settings.sBool(checked,"ui", "showContactStatusText")
                          shouldIreloadRoster = true;
                       }
                    }
                    CheckBox {
                       id: rosterLayout
                       text: qsTr("Show avatars (alternative layout)")
                       platformInverted: main.platformInverted
                       checked: settings.gBool("ui", "rosterLayoutAvatar")
                       onCheckedChanged: {
                          settings.sBool(checked,"ui", "rosterLayoutAvatar")
                          shouldIreloadRoster = true;
                       }
                    }
                    Text {
                        id: rosterItemHeightText
                        text: "Roster item height (" + rosterItemHeight.value + " px)"
                        color: vars.textColor
                    }
                    Slider {
                            id: rosterItemHeight
                            stepSize: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: tabBehavior.width-20
                            maximumValue: 128
                            //minimumValue: 24
                            value: settings.gInt("ui", "rosterItemHeight")
                            orientation: 1
                            platformInverted: main.platformInverted

                            onValueChanged: {
                                shouldIreloadRoster = true;
                                settings.sInt(value,"ui", "rosterItemHeight")
                            }
                        }
                }
            }
        }
        Page {
            id: tabBehavior
            Flickable {
                id: flickAreaConnection
                anchors.fill: parent

                contentHeight: contentNotification.height
                contentWidth: tabBehavior.width

                flickableDirection: Flickable.VerticalFlick
                Column {
                    id: contentNotification
                    spacing: 5
                    anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                    CheckBox {
                        id: cbNeedReconnect
                        text: qsTr("Reconnect on error")
                        checked: settings.gBool("behavior", "reconnectOnError")
                        platformInverted: main.platformInverted
                        onCheckedChanged: {
                            console.log("Reconnect on error: checked="+checked)
                            settings.sBool(checked,"behavior", "reconnectOnError")
                        }
                    }
                    Text {
                        text: qsTr("Keep alive interval (secs)")
                        font.pixelSize: 20
                        font.bold: true
                        color: vars.textColor
                    }
                    TextField {
                        id: tiKeepAlive
                        anchors.horizontalCenter: parent.horizontalCenter
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        width: tabBehavior.width-20
                        height: 50
                        Component.onCompleted: {
                            tiKeepAlive.text = settings.gInt("behavior", "keepAliveInterval")
                        }
                        onActiveFocusChanged: {
                            main.splitscreenY = 0
                        }

                        onTextChanged: {
                            var interval = parseInt(tiKeepAlive.text)
                            xmppConnectivity.client.keepAlive = interval
                            settings.sInt(interval,"behavior", "keepAliveInterval")
                        }
                    }

                    CheckBox {
                        id: saveLastStatus
                        text: qsTr("Remember last used status")
                        checked: settings.gBool("behavior","storeLastStatus")
                        platformInverted: main.platformInverted
                        onCheckedChanged: {
                            settings.sBool(checked,"behavior","storeLastStatus")
                            if (!checked) { settings.gStr("","behavior","lastStatusText") }
                        }
                    }
                    CheckBox {
                        id: goOnlineOnStart
                        text: qsTr("Go online on startup")
                        checked: settings.gBool("behavior","goOnlineOnStart")
                        platformInverted: main.platformInverted
                        onCheckedChanged: {
                            settings.sBool(checked,"behavior","goOnlineOnStart")
                        }
                    }
                }
            }
        }
    }


    /***************************************************/
    ToolBarLayout {
        id: toolBar
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                statusBarText.text = "Contacts"
                if (shouldIreloadRoster) {
                    pageStack.pop()
                    pageStack.replace("qrc:/pages/Roster")
                } else {
                    pageStack.pop()
                }
            }
        }
        ButtonRow {
                 TabButton {
                     text: "Notify"
                     tab: tabNotifications
                     platformInverted: main.platformInverted
                 }
                 TabButton {
                     text: "UI"
                     tab: tabAppearance
                     platformInverted: main.platformInverted
                 }
                 TabButton {
                     text: "Behavior"
                     tab: tabBehavior
                     platformInverted: main.platformInverted
                 }
             }
    }
}
