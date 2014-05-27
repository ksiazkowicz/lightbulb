// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Component {
    id: componentRosterItem

    Rectangle {
        id: wrapper
        width: rosterView.width
        color: "transparent"
        visible: rosterSearch.text !== "" ? (txtJid.contact.toLowerCase().indexOf(rosterSearch.text.toLowerCase()) != -1 ? true : false ) : presence === "qrc:/presence/offline" ? !vars.hideOffline : true
        height: vars.rosterItemHeight - txtJid.font.pixelSize > txtJid.height ? vars.rosterItemHeight : txtJid.height + txtJid.font.pixelSize

        gradient: gr_free
        Gradient {
            id: gr_free
            GradientStop { id: gr1; position: 0; color: "transparent" }
            GradientStop { id: gr3; position: 1; color: "transparent" }
        }
        Gradient {
            id: gr_press
            GradientStop { position: 0; color: "#1C87DD" }
            GradientStop { position: 1; color: "#51A8FB" }
        }

        states: [State {
                name: "Current"
                when: vars.selectedJid == jid
                PropertyChanges { target: wrapper; gradient: gr_press }
            },State {
                name: "Not current"
                when: !vars.selectedJid == jid
                PropertyChanges { target: wrapper; gradient: gr_free }
            }]

        Image {
            id: imgPresence
            source: vars.rosterLayoutAvatar ? avatar : presence
            sourceSize.height: vars.rosterItemHeight-4
            sourceSize.width: vars.rosterItemHeight-4
            anchors { top: parent.top; topMargin: (vars.rosterItemHeight-sourceSize.height)/2; left: parent.left; leftMargin: 10 }
            height: vars.rosterItemHeight-4
            width: vars.rosterItemHeight-4
            Image {
                id: imgUnreadMsg
                source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                sourceSize.height: imgPresence.height
                sourceSize.width: imgPresence.height
                smooth: true
                visible: vars.markUnread ? unreadMsg != 0 : false
                anchors.centerIn: parent
                opacity: unreadMsg != 0 ? 1 : 0
                Image {
                    id: imgUnreadCount
                    source: "qrc:/unread-count"
                    sourceSize.height: imgPresence.height
                    sourceSize.width: imgPresence.height
                    smooth: true
                    visible: vars.showUnreadCount ? unreadMsg != 0 : false
                    anchors.centerIn: parent
                    opacity: unreadMsg != 0 ? 1 : 0
                }
                Rectangle {
                    color: "transparent"
                    width: wrapper.height * 0.30
                    height: width
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    visible: vars.showUnreadCount ? unreadMsg != 0 : false
                    Text {
                        id: txtUnreadMsg
                        text: unreadMsg
                        font.pixelSize: 0.72*parent.width
                        anchors.centerIn: parent
                        z: 1
                        color: "white"
                    }
                }
            }
        } //imgPresence
        Text {
            id: txtJid
            property string contact: (name === "" ? jid : name)
            anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
            width: parent.width
            maximumLineCount: (vars.rosterItemHeight/22) > 1 ? (vars.rosterItemHeight/22) : 1
            text: (name === "" ? jid : name) + ((vars.showContactStatusText && statusText != "") ? (" · <font color='#aaaaaa'><i>" + statusText + "</i></font>") : "")
            onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
            wrapMode: Text.WordWrap
            font.pixelSize: (vars.showContactStatusText ? 16 : 0)
            color: vars.textColor
        }
        MouseArea {
            id: mouseAreaItem;
            anchors.fill: parent

            onClicked: {
                xmppConnectivity.chatJid = jid
                vars.selectedJid = jid
                vars.globalUnreadCount = vars.globalUnreadCount - unreadMsg
                notify.updateNotifiers()
                main.pageStack.push("qrc:/pages/Messages",{"contactName":txtJid.contact})
            }

            onPressAndHold: {
                vars.selectedJid = jid
                dialog.createWithProperties("qrc:/menus/Roster/Contact",{"contactName":txtJid.contact,"contactJid":jid})
            }
        }
        Image {
            id: imgPresenceR
            source: vars.rosterLayoutAvatar ? presence : ""
            sourceSize.height: (wrapper.height/3) - 4
            sourceSize.width: (wrapper.height/3) - 4
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: vars.rosterLayoutAvatar ? 10 : 0 }
            height: vars.rosterLayoutAvatar ? (vars.rosterItemHeight/3) - 4 : 0
            width: vars.rosterLayoutAvatar ? (vars.rosterItemHeight/3) - 4 : 0
        }
        Rectangle {
            height: 1
            anchors { top: parent.bottom; left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
            color: vars.textColor
            opacity: 0.2
        }
    } //Rectangle
}
