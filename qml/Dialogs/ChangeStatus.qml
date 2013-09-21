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

        Component.onCompleted: {
            open()
            main.splitscreenY = 0
        }

        onButtonClicked: {
             xmppClient.keepAlive = settings.gBool("behavior","keepAliveInterval")
             xmppClient.reconnectOnError = settings.gBool("behavior","reconnectOnError")

              var ret = ""

              if( colStatus.selectedIndex === 0 ) {
                       ret = XmppClient.Online
              } else if( colStatus.selectedIndex === 1 ) {
                       ret = XmppClient.Chat
              } else if( colStatus.selectedIndex === 2 ) {
                       ret = XmppClient.Away
              } else if( colStatus.selectedIndex === 3 ) {
                       ret = XmppClient.XA
              } else if( colStatus.selectedIndex === 4 ) {
                       ret = XmppClient.DND
              } else if( colStatus.selectedIndex === 5 ) {
                       ret = XmppClient.Offline
              }
              xmppClient.setMyPresence( ret, wrapperTextEdit.text )
              main.lastStatus = wrapperTextEdit.text

              if (storeStatus) { settings.sStr(wrapperTextEdit.text,"behavior","lastStatusText") } else { settings.sStr("","behavior","lastStatusText") }
        }

        content: Rectangle {
            width: parent.width-20
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Tumbler {
                id: tumbler
                anchors { top: parent.top; left: parent.left; right: parent.right; bottom: wrapperTextEdit.top }
                columns: TumblerColumn {
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
            }

            TextField {
                id: wrapperTextEdit
                height: 50
                anchors { bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right; topMargin: 5; }
                placeholderText: qsTr("Status text")
                text: main.lastStatus
            }
        }
    }
