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
