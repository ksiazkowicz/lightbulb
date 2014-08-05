// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0

Item {
    id: wrapper
    height: 56
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
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        width: 48
        height: 48
        smooth: true
        source: xmppConnectivity.getAvatarByJid(jid)
        Image {
            anchors.fill: parent
            sourceSize { width: 48; height: 48 }
            smooth: true
            source: "qrc:/avatar-mask"
        }
    }
    Image {
        id: imgPresence
        source: chatType !== 3 ? xmppConnectivity.getPropertyByJid(account,"presence",jid) : ""
        sourceSize { height: 16; width: 16 }
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 5 }
        height: chatType !== 3 ? 16 : 0
        width: chatType !== 3 ? 16 : 0
    }
    Text {
        anchors { verticalCenter: parent.verticalCenter; left: avatarIcon.right; right: parent.right; leftMargin: 10 }
        text: name
        font.pixelSize: 22
        clip: true
        color: vars.textColor
        elide: Text.ElideRight
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
