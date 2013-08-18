import QtQuick 1.0
import com.nokia.symbian 1.1

Page {
    id: pageOpenChats

    tools: toolBarLayout
    anchors.fill: parent
    clip: true

    property string clickedItem

    property int __selectedContactItemType: 0

    Component.onCompleted: {
        statusBarText.text = qsTr("Chats")
    }

    Connections {
        target: xmppClient
    }

    Component {
        id: componentRosterItem
        Rectangle {
            id: wrapper
            clip: true
            width: listViewRoster.width
            height: 75
            color: "transparent"

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
                    source: "images/message_mark.png"
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
                    color: main.platformInverted ? "black" : "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                }
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    wrapper.ListView.view.currentIndex = index
                    xmppClient.chatJid = contactJid
                    xmppClient.contactName = contactName
                    __selectedContactItemType = contactItemType
                    main.globalUnreadCount = main.globalUnreadCount - contactUnreadMsg
                    xmppClient.resetUnreadMessages( contactJid )
                    if (settings.gBool("behavior","enableHsWidget")) {
                        notify.postHSWidget()
                    }
                    pageStack.replace( "qrc:/qml/MessagesPage.qml" )
                }

                onPressAndHold: {
                    wrapper.ListView.view.currentIndex = index
                    xmppClient.chatJid = contactJid
                    xmppClient.contactName = contactName
                    selectedName = contactName
                    __selectedContactItemType = contactItemType
                    contactMenu.open()
                }
            }
        } //Rectangle
    }

    ListView {
            id: listViewRoster
            anchors.fill: parent
            flickDeceleration: 1720
            snapMode: ListView.NoSnap
            cacheBuffer: 0
            width: 316
            highlightResizeSpeed: 20
            highlightMoveSpeed: 20
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.DragAndOvershootBounds
            clip: true
            delegate: componentRosterItem
            model: xmppClient.openChats
    }

    /*****************************************************************************/

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.replace( "qrc:/qml/RosterPage.qml")
            }
        }
    }


}
