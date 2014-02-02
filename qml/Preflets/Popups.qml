import QtQuick 1.1
import com.nokia.symbian 1.1

Item {

    function savePreferences() {
        settings.sBool(switch1.checked,"behavior","linkInDiscrPopup")
        settings.sBool(messageText.checked,"behavior","msgInDiscrPopup")
        settings.sBool(true,"notifications", "usePopupRecv")
    }

    Column {
        Image {
            id: image1
            width: 360
            height: 79
            smooth: true
            clip: false
            source: "qrc:/FirstRun/img/popup01"
        }

        RadioButton {
            id: messageText
            x: 10
            checked: settings.gBool("behavior","msgInDiscrPopup")
            platformInverted: main.platformInverted
            text: "Incoming message text"
            onCheckedChanged: {
                if (checked)
                    unreadCount.checked = false
            }
        }

        Image {
            id: image2
            width: 360
            height: 79
            source: "qrc:/FirstRun/img/popup02"
        }

        RadioButton {
            id: unreadCount
            x: 10
            text: "Unread count"
            checked: !messageText.checked
            platformInverted: main.platformInverted
            onCheckedChanged: {
                if (checked)
                    messageText.checked = false
            }
        }
        Row {
            Item {
                Text {
                    id: switchDescription
                    x: 10
                    width: 177
                    color: vars.textColor
                    text: qsTr("Switch to app on interaction")
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: 20
                }

                Text {
                    id: switchDescriptionSubtitle
                    x: switchDescription.x
                    anchors { top: switchDescription.bottom }
                    width: 252
                    height: 32
                    color: main.platformInverted ? "#333333" : "#888888"
                    text: qsTr("Tapping on popup would instantly switch you to this app.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
            Switch {
                id: switch1
                checked: settings.gBool("behavior","linkInDiscrPopup")
                anchors { right: parent.right; rightMargin: 10; }
            }
        }
    }
}

