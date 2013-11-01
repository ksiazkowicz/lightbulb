// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
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
                        color: main.textColor
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "vibraMsgRecv"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Vibration"
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "soundMsgRecv"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Sound"
                            }
                        }
                    }

                    CheckBox {
                            id: notifyMsgReceived
                            text: qsTr("Info banner")
                            height: 64
                            checked: settings.gBool("notifications", "notifyMsgRecv")
                            platformInverted: main.platformInverted
                            onCheckedChanged: {
                                settings.sBool(checked,"notifications", "notifyMsgRecv")
                            }
                        }
                    CheckBox {
                           id: usePopupRecv
                           text: qsTr("Discreet Popup")
                           height: 64
                           checked: settings.gBool("notifications", "usePopupRecv")
                           platformInverted: main.platformInverted
                           onCheckedChanged: {
                              settings.sBool(checked,"notifications", "usePopupRecv")
                           }
                        }
                    CheckBox {
                           id: dontBLINK
                           text: qsTr("Blink screen when locked")
                           height: 64
                           checked: settings.gBool("notifications", "wibblyWobblyTimeyWimeyStuff")
                           platformInverted: main.platformInverted
                           onCheckedChanged: {
                              settings.sBool(checked,"notifications", "wibblyWobblyTimeyWimeyStuff")
                           }
                        }
                    //
                    Text {
                        text: "Message sent"
                        color: main.textColor
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "vibraMsgSent"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Vibration"
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "soundMsgSent"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Sound"
                            }
                        }
                    }

                    Text {
                        text: "Connecting changed"
                        color: main.textColor
                    }
                    CheckBox {
                        id: notifyOnline
                        text: qsTr("Info banner")
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "soundNotifyConn"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Sound"
                            }
                        }
                    }

                    Text {
                        text: "Subscription request"
                        color: main.textColor
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "soundMsgSub"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Sound"
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
                            iconSource: "qrc:/qml/images/settings.svg"
                            onClicked: {
                                main.nowEditing = "vibraMsgSub"
                                dialog.source = ""
                                dialog.source = "qrc:/dialogs/Settings/Vibration"
                            }
                        }
                    }

                    CheckBox {
                        id: subInfo
                        text: qsTr("Info banner")
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
                        color: main.textColor
                    }
                    CheckBox {
                        id: notifyBoxTyping
                        text: qsTr("Info banner")
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
                       id: invertPlatform
                       text: qsTr("Inverted colors")
                       checked: settings.gBool("ui", "invertPlatform")
                       platformInverted: main.platformInverted
                       onCheckedChanged: {
                          settings.sBool(checked,"ui", "invertPlatform")
                          main.platformInverted = checked
                          main.textColor = checked ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
                       }
                    }
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
                        color: main.textColor
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
                        color: main.textColor
                    }
                    TextField {
                        id: tiKeepAlive
                        anchors.horizontalCenter: parent.horizontalCenter
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
                            xmppClient.keepAlive = interval
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
                    CheckBox {
                        id: enableWidget
                        text: qsTr("Enable homescreen widget")
                        checked: settings.gBool("behavior","enableHsWidget")
                        platformInverted: main.platformInverted
                        onCheckedChanged: {
                            settings.sBool(checked,"behavior","enableHsWidget")
                            if (checked) {
                                notify.registerWidget()
                            } else {
                                notify.removeWidget()
                            }
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
            iconSource: "toolbar-back"
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
                 }
                 TabButton {
                     text: "UI"
                     tab: tabAppearance
                 }
                 TabButton {
                     text: "Behavior"
                     tab: tabBehavior
                 }
             }
    }
}
