import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    Text {
        id: chapter
        color: vars.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Popup notifications"
    }

    Text {
        id: text
        color: vars.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: "How do you like your popups?"
        horizontalAlignment: Text.AlignHCenter
    }

    function savePreferences() {
        settings.sBool(switch1.checked,"behavior","linkInDiscrPopup")
        settings.sBool(messageText.checked,"behavior","msgInDiscrPopup")
        settings.sBool(true,"notifications", "usePopupRecv")
    }

    Image {
        id: image1
        y: 159
        width: 360
        height: 79
        smooth: true
        clip: false
        source: "qrc:/FirstRun/img/popup01"
    }

    Image {
        id: image2
        y: 301
        width: 360
        height: 79
        source: "qrc:/FirstRun/img/popup02"
    }

    RadioButton {
        id: messageText
        x: 10
        y: 249
        checked: settings.gBool("behavior","msgInDiscrPopup")
        platformInverted: main.platformInverted
        text: "Incoming message text"
        onCheckedChanged: {
            if (checked) {
                unreadCount.checked = false
            }
        }
    }

    RadioButton {
        id: unreadCount
        x: 10
        y: 388
        text: "Unread count"
        checked: !messageText.checked
        platformInverted: main.platformInverted
        onCheckedChanged: {
            if (checked) {
                messageText.checked = false
            }
        }
    }

    Switch {
        id: switch1
        checked: settings.gBool("behavior","linkInDiscrPopup")
        x: 284
        y: 460
    }

    Text {
        id: switchDescription
        x: 10
        y: 453
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

