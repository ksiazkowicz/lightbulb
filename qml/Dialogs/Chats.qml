// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: dlgChats
    titleText: qsTr("Chats")
    privateCloseIcon: true
    height: 480

    Connections {
        target: xmppClient
    }

    Component.onCompleted: {
        open()
        main.splitscreenY = 0
    }

    property int  rosterItemHeight: settings.gInt("ui","rosterItemHeight")
    property bool rosterLayoutAvatar: settings.gBool("ui","rosterLayoutAvatar")

  /*******************************************************************************/

    Component {
        id: componentRosterItem
        Rectangle {
            id: wrapper
            width: listViewChats.width
            color: "transparent"
            height: rosterItemHeight

            Image {
                id: imgPresence
                source: rosterLayoutAvatar ? (contactPicAvatar === "" ? "qrc:/qml/images/avatar.png" : contactPicAvatar) : contactPicStatus
                sourceSize.height: rosterItemHeight-4
                sourceSize.width: rosterItemHeight-4
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                height: rosterItemHeight-4
                width: rosterItemHeight-4
            } //imgPresence
            Text {
                    id: txtJid
                    property string contact: contactName
                    anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    width: parent.width
                    maximumLineCount: (rosterItemHeight/22) > 1 ? (rosterItemHeight/22) : 1
                    text: (contactName === "" ? contactJid : contactName) + (contactUnreadMsg > 0 ? " [" + contactUnreadMsg + "]" : "")
                    onLinkActivated: { main.url=link; linkContextMenu.open()}
                    wrapMode: Text.Wrap
                    font.pixelSize: 16
                    color: main.textColor
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    listViewChats.currentIndex = index
                    xmppClient.chatJid = contactJid
                    xmppClient.contactName = contactName
                    main.globalUnreadCount = main.globalUnreadCount - contactUnreadMsg
                    xmppClient.resetUnreadMessages( contactJid )
                    if (settings.gBool("behavior","enableHsWidget")) {
                        notify.postHSWidget()
                    }
                    main.openChat()
                } //onClicked
            }
            Image {
                id: imgPresenceR
                source: rosterLayoutAvatar ? contactPicStatus : ""
                sourceSize.height: (wrapper.height/3) - 4
                sourceSize.width: (wrapper.height/3) - 4
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: rosterLayoutAvatar ? 10 : 0 }
                height: rosterLayoutAvatar ? (rosterItemHeight/3) - 4 : 0
                width: rosterLayoutAvatar ? (rosterItemHeight/3) - 4 : 0
            }
            Rectangle {
                height: 1
                anchors { top: parent.bottom; left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
                color: main.textColor
                opacity: 0.2
            }
        } //Rectangle
    }


    content: ListView {
                id: listViewChats
                anchors.fill: parent
                height: (xmppClient.openChats.count*rosterItemHeight)+1
                highlightFollowsCurrentItem: false
                model: xmppClient.openChats
                delegate: componentRosterItem
            }
}
