import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    height: cbNeedReconnect.height + 20 + tiKeepAlive.height + 3*content.spacing

    Column {
        id: content
        spacing: 5
        width: 360
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
            width: content.width-20
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
    }
}

