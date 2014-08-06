// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0

Flickable {
    id: flick
    height: 56
    flickableDirection: Flickable.HorizontalFlick
    boundsBehavior: Flickable.DragOverBounds
    contentWidth: wrapper.width *2

    onContentXChanged: {
        wrapper.opacity = 1-(contentX/(wrapper.width))
        if (wrapper.opacity <= 0)
            xmppConnectivity.closeChat(account,jid)
    }

    Item {
        id: wrapper
        height: 56
        width: flick.width
        anchors.left: parent.left;
        Rectangle {
            anchors.fill: parent
            z: -1
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
        }
        Image {
            id: avatarIcon
            anchors { left: wrapper.left; verticalCenter: parent.verticalCenter }
            width: 48
            height: 48
            smooth: true
            source: xmppConnectivity.getAvatarByJid(jid)
            Rectangle { anchors.fill: parent; color: "black"; z: -1 }
            Image {
                anchors.fill: parent
                sourceSize { width: 48; height: 48 }
                smooth: true
                source: main.platformInverted ? "qrc:/avatar-mask_inverse" : "qrc:/avatar-mask"
            }
            opacity: wrapper.opacity

            Connections {
                target: xmppConnectivity
                onAvatarUpdatedForJid: if (bareJid == jid) avatarIcon.source = xmppConnectivity.getAvatarByJid(jid)
            }
        }
        Image {
            id: imgPresence
            source: chatType !== 3 ? xmppConnectivity.getPropertyByJid(account,"presence",jid) : ""
            sourceSize { height: 16; width: 16 }
            anchors { verticalCenter: parent.verticalCenter; right: wrapper.right; rightMargin: 5 }
            height: chatType !== 3 ? 16 : 0
            width: chatType !== 3 ? 16 : 0
            opacity: wrapper.opacity
        }
        Text {
            anchors { verticalCenter: parent.verticalCenter; left: avatarIcon.right; right: wrapper.right; leftMargin: 10 }
            text: name
            font.pixelSize: 22
            clip: true
            color: vars.textColor
            elide: Text.ElideRight
            opacity: wrapper.opacity
        }
        states: State {
            name: "Current"
            PropertyChanges { target: chatElement; gradient: gr_press }
        }
        MouseArea {
            id: maAccItem
            anchors { fill: parent }
            onClicked: main.openChat(account,name,jid,chatType)
        }

        Connections {
            target: xmppConnectivity
            onXmppPresenceChanged: {
                if (m_accountId == account && bareJid == jid)
                    imgPresence.source = picStatus
            }
        }
    }
    Item { height: 1; width: wrapper.width; anchors.right: parent.right; }
}
