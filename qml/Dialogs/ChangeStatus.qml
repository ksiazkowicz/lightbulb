// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0

CommonDialog {
        titleText: qsTr("Set status")
        buttonTexts: ["OK"]
        privateCloseIcon: true

        property bool storeStatus: settings.gBool("behavior","storeLastStatus")

        platformInverted: main.platformInverted

        Component.onCompleted: {
            open()
            main.splitscreenY = 0
            colStatus.selectedIndex = main.lastUsedStatus
        }

        onButtonClicked: {
            xmppClient.keepAlive = settings.gBool("behavior","keepAliveInterval")
            xmppClient.reconnectOnError = settings.gBool("behavior","reconnectOnError")

            var ret = ""

            switch (colStatus.selectedIndex) {
                case 0: ret = XmppClient.Online; break;
                case 1: ret = XmppClient.Chat; break;
                case 2: ret = XmppClient.Away; break;
                case 3: ret = XmppClient.XA; break;
                case 4: ret = XmppClient.DND; break;
                case 5: ret = XmppClient.Offline; break;
                default: ret = XmppClient.Unknown; break;
            }

            if (notify.getStatusName() === "Offline" && ret !== XmppClient.Offline) {
                main.connecting = true;
            }

            xmppClient.setMyPresence( ret, wrapperTextEdit.text )
            main.lastStatus = wrapperTextEdit.text
            main.lastUsedStatus = colStatus.selectedIndex

            if (storeStatus) { settings.sStr(wrapperTextEdit.text,"behavior","lastStatusText") } else { settings.sStr("","behavior","lastStatusText") }
        }

        content: Rectangle {
            width: parent.width-20
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            TumblerColumn {
                id: colStatus

                items: ListModel {
                           ListElement {
                               value: "Online"
                           }
                           ListElement {
                               value: "Chatty"
                           }
                           ListElement {
                               value: "Away"
                           }
                           ListElement {
                               value: "Extended Away"
                           }
                           ListElement {
                               value: "Do not disturb"
                           }
                           ListElement {
                               value: "Offline"
                           }
                       }
            }

            Tumbler {
                platformInverted: main.platformInverted
                id: tumbler
                anchors { top: parent.top; topMargin: 5; left: parent.left; right: parent.right; bottom: wrapperTextEdit.top; bottomMargin: 5 }
                columns: [ colStatus ]
            }

            TextField {
                id: wrapperTextEdit
                height: 50
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                placeholderText: qsTr("Status text")
                text: main.lastStatus
            }
        }
    }
