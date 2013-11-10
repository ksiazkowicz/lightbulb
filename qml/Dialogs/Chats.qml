// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: dlgChats
    titleText: qsTr("Chats")
    privateCloseIcon: true
    height: 320

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
            gradient: unreadMsg > 0 ? incomingMsg : nihilNovi

            Gradient {
                id: incomingMsg
                GradientStop { position: 0; color: "red" }
                GradientStop { position: 1; color: "darkred" }
            }

            Gradient {
                id: nihilNovi
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: "transparent" }
            }

            height: rosterItemHeight

            Image {
                id: imgPresence
                source: rosterLayoutAvatar ? (avatarPath == "" ? "qrc:/avatar" : avatarPath) : presence
                sourceSize.height: rosterItemHeight-4
                sourceSize.width: rosterItemHeight-4
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                height: rosterItemHeight-4
                width: rosterItemHeight-4
            } //imgPresence
            Text {
                    id: txtJid
                    property string contact: name
                    anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    width: parent.width
                    maximumLineCount: (rosterItemHeight/22) > 1 ? (rosterItemHeight/22) : 1
                    text: (name === "" ? jid : name) + (unreadMsg > 0 ? " [" + unreadMsg + "]" : "")
                    onLinkActivated: { main.url=link; linkContextMenu.open()}
                    wrapMode: Text.Wrap
                    font.pixelSize: 16
                    color: "white"
                    opacity: unreadMsg > 0 ? 1 : 0.7
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    listViewChats.currentIndex = index
                    xmppClient.chatJid = jid
                    xmppClient.contactName = name
                    main.globalUnreadCount = main.globalUnreadCount - unreadMsg
                    xmppClient.resetUnreadMessages( jid )
                    if (settings.gBool("behavior","enableHsWidget")) {
                        notify.postHSWidget()
                    }
                    main.openChat()
                } //onClicked
            }
            Image {
                id: imgPresenceR
                source: rosterLayoutAvatar ? presence : ""
                sourceSize.height: (wrapper.height/3) - 4
                sourceSize.width: (wrapper.height/3) - 4
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: rosterLayoutAvatar ? 10 : 0 }
                height: rosterLayoutAvatar ? (rosterItemHeight/3) - 4 : 0
                width: rosterLayoutAvatar ? (rosterItemHeight/3) - 4 : 0
            }
            Rectangle {
                height: 1
                anchors { top: parent.bottom; left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
                color: "white"
                opacity: 0.2
            }
        } //Rectangle
    }


    content: ListView {
                id: listViewChats
                anchors.fill: parent
                height: (xmppClient.sqlChats.count*rosterItemHeight)+1
                highlightFollowsCurrentItem: false
                model: xmppClient.sqlChats
                delegate: componentRosterItem
            }
}
