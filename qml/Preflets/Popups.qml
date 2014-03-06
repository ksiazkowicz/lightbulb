import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    height: content.height

    function savePreferences() {
        settings.sBool(switch1.checked,"behavior","linkInDiscrPopup")
        settings.sBool(messageText.checked,"behavior","msgInDiscrPopup")
    }

    Column {
        id: content
        spacing: 10;
        Image {
            width: 360
            height: 79
            anchors { horizontalCenter: parent.horizontalCenter }
            smooth: true
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
                    unreadCount.checked = false; else unreadCount.checked = true;
                savePreferences()
            }
        }

        Image {
            width: 360
            height: 79
            smooth: true
            anchors { horizontalCenter: parent.horizontalCenter }
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
                    messageText.checked = false; else messageText.checked = true;
                savePreferences()
            }
        }
        Item {
            width: parent.width
            height: switchDescription.height
            Text {
                id: switchDescription
                property string color2: main.platformInverted ? "#333333" : "#888888"
                anchors { left: parent.left; top: parent.top; topMargin: platformStyle.paddingSmall; right: switch1.left; leftMargin: platformStyle.paddingSmall; rightMargin: platformStyle.paddingSmall; }
                color: vars.textColor
                text: qsTr("Switch to app on interaction") + "<br /><font color='" + color2 + "' size='14px'>" + qsTr("Tapping on popup would instantly switch you to this app.")  + "</font>"
                font.pixelSize: 20
                wrapMode: Text.WordWrap
            }
            Switch {
                id: switch1
                checked: settings.gBool("behavior","linkInDiscrPopup")
                anchors { right: parent.right; rightMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
                onCheckedChanged: {
                    savePreferences()
                }
            }
        }
    }
}

