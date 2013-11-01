// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: dlgChats
    titleText: qsTr("Chats")
    privateCloseIcon: true

    Connections {
        target: xmppClient
    }

    Component.onCompleted: {
        open()
        main.splitscreenY = 0
    }

    content: ListView {
                id: listViewResources
                anchors.fill: parent
                height: (xmppClient.openChats.count*48)+1
                highlightFollowsCurrentItem: false
                model: xmppClient.openChats
                delegate: Component {
                    id: componentRosterItem
                    Rectangle {
                        id: wrapper
                        height: 48
                        width: parent.width
                        gradient: gr_normal
                        Gradient {
                            id: gr_normal
                            GradientStop { position: 0; color: "transparent" }
                            GradientStop { position: 1; color: "transparent" }
                        }
                        Gradient {
                            id: gr_press
                            GradientStop { position: 0; color: "#1C87DD" }
                            GradientStop { position: 1; color: "#51A8FB" }
                        }
                        states: State {
                            name: "Current"
                            when: wrapper.ListView.view.currentIndex
                            PropertyChanges { target: wrapper; gradient: gr_press }
                            PropertyChanges { target: wrapper; font.bold: true }
                        }

                        Image {
                            id: imgPresence
                            source: contactPicStatus
                            sourceSize.height: wrapper.height
                            sourceSize.width: wrapper.height
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 7

                            Image {
                                id: imgMarkUnread
                                source: "qrc:/qml/images/message_mark.png"
                                opacity: contactUnreadMsg != 0 ? 1 : 0
                                anchors.centerIn: parent
                                smooth: true
                                scale: 1
                            }
                        } //imgPresence

                        Rectangle {
                            z: 1
                            id: wrapperTxtJid
                            anchors.left: imgPresence.right
                            anchors.leftMargin: 5
                            anchors.top: parent.top
                            anchors.topMargin: 0
                            color: "transparent"
                            height: parent.height - 2
                            width: contactItemType == 0 ? parent.width - (imgPresence.width + imgPresence.anchors.leftMargin) - 5 : parent.width - (imgPresence.width + imgPresence.anchors.leftMargin)
                        }
                        Item {
                            anchors.verticalCenter: wrapperTxtJid.verticalCenter
                            anchors.left: wrapperTxtJid.left
                            height: wrapperTxtJid.height
                            width: wrapperTxtJid.width
                            clip: true
                            Text {
                                id: txtJid
                                clip: true
                                text: contactUnreadMsg != 0 ? (contactName === "" ? contactJid : contactName) + "\n" + (contactUnreadMsg==1 ? contactUnreadMsg + qsTr(" new message") : contactUnreadMsg + qsTr(" new messages") ) : (contactName === "" ? contactJid : contactName)
                                font.pixelSize: 16
                                color: main.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                wrapper.ListView.view.currentIndex = index
                                xmppClient.chatJid = contactJid
                                xmppClient.contactName = contactName
                                main.globalUnreadCount = main.globalUnreadCount - contactUnreadMsg
                                xmppClient.resetUnreadMessages( contactJid )
                                if (settings.gBool("behavior","enableHsWidget")) {
                                    notify.postHSWidget()
                                }
                                pageStack.replace( "qrc:/pages/Messages" )
                                dlgChats.close()
                            } //onClicked
                        } //MouseArea
                    }
                } //Component
            }
}
